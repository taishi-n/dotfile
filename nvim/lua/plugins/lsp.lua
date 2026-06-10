local M = {}

local util = require "utils.util"

function M.blink()
    local function should_trigger_completion()
        local ft = vim.bo.filetype
        local col = vim.api.nvim_win_get_cursor(0)[2]
        if col == 0 then
            return false
        end

        local line = vim.api.nvim_get_current_line()
        local before_cursor = line:sub(1, col)
        if before_cursor:match "^%s*$" then
            return false
        end

        if ft == "markdown" then
            if before_cursor:match "^%s*[%-%*+]%s*$" then
                return false
            end
            if before_cursor:match "^%s*%d+%.%s*$" then
                return false
            end
        end

        return true
    end

    require("blink.cmp").setup {
        keymap = {
            preset = "default",
            ["<C-Space>"] = {
                function(cmp)
                    return cmp.show()
                end,
                "fallback",
            },
            ["<Tab>"] = {
                function(cmp)
                    if cmp.is_visible() then
                        return cmp.select_next({ on_ghost_text = true })
                    end
                    if cmp.snippet_active() then
                        return nil
                    end
                    if should_trigger_completion() then
                        return cmp.show_and_insert()
                    end
                    return false
                end,
                "snippet_forward",
                "fallback",
            },
            ["<S-Tab>"] = {
                function(cmp)
                    if cmp.is_visible() then
                        return cmp.select_prev({ on_ghost_text = true })
                    end
                    if cmp.snippet_active() then
                        return nil
                    end
                    return false
                end,
                "snippet_backward",
                "fallback",
            },
            ["<CR>"] = {
                function(cmp)
                    if cmp.is_visible() then
                        return cmp.select_and_accept()
                    end
                    return false
                end,
                "fallback",
            },
        },
        completion = {
            menu = {
                auto_show = false,
            },
            list = {
                selection = {
                    preselect = false,
                    auto_insert = false,
                },
            },
            trigger = {
                show_on_backspace = false,
                show_on_backspace_in_keyword = false,
                show_on_backspace_after_accept = false,
                show_on_backspace_after_insert_enter = false,
                show_on_keyword = false,
                show_on_trigger_character = false,
                show_on_insert_on_trigger_character = false,
                show_on_accept_on_trigger_character = false,
            },
            ghost_text = {
                enabled = true,
                show_with_selection = true,
                show_without_selection = true,
                show_with_menu = true,
                show_without_menu = true,
            },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer", "omni", "bibtex" },
            providers = {
                bibtex = {
                    module = "blink-cmp-bibtex",
                    name = "BibTeX",
                    min_keyword_length = 2,
                    score_offset = 10,
                    async = true,
                },
            },
        },
    }
end

function M.mason()
    require("mason").setup {
        PATH = "prepend",
    }
end

function M.mason_tools()
    require("mason-tool-installer").setup {
        ensure_installed = {
            "harper-ls",
            "markdownlint-cli2",
            "prettier",
            "ty",
            "ruff",
        },
        auto_update = false,
        run_on_start = true,
    }
end

function M.lsp()
    require("lazydev").setup {}

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
        capabilities = blink.get_lsp_capabilities(capabilities)
    end

    local ok_bibtex, blink_bibtex = pcall(require, "blink-cmp-bibtex")
    if ok_bibtex then
        blink_bibtex.setup {
            filetypes = { "tex", "plaintex", "markdown", "rmd", "typst" },
        }
    end

    local markdownlint_ns = vim.api.nvim_create_namespace "markdownlint-cli2"
    local markdownlint_formatter = vim.fs.normalize(
        vim.fn.stdpath "config" .. "/lua/plugins/markdownlint_formatter.mjs"
    )
    local markdownlint_state = {}

    local function markdownlint_message(result)
        local function as_text(value, fallback)
            if value == nil then
                return fallback
            end
            local text = tostring(value)
            if text == "" or text == "nil" then
                return fallback
            end
            return text
        end

        local rule_name = as_text(result.ruleName, "markdownlint")
        local message = as_text(result.ruleDescription, "markdownlint violation")
        local error_detail = as_text(result.errorDetail, "")
        if error_detail ~= "" then
            message = message .. ": " .. error_detail
        end
        return ("[%s] %s"):format(rule_name, message)
    end

    local function markdownlint_diagnostics(output, bufnr)
        local diagnostics = {}
        local function to_index(value, default)
            if type(value) == "number" then
                return value
            end
            local n = tonumber(value)
            if n ~= nil then
                return n
            end
            return default
        end

        for line in (output or ""):gmatch "[^\r\n]+" do
            local ok_json, item = pcall(vim.json.decode, line)
            if ok_json and type(item) == "table" then
                local severity = vim.diagnostic.severity.ERROR
                if item.severity == "warning" then
                    severity = vim.diagnostic.severity.WARN
                end
                table.insert(diagnostics, {
                    bufnr = bufnr,
                    lnum = math.max(to_index(item.lineNumber, 1) - 1, 0),
                    col = math.max(to_index(item.columnNumber, 1) - 1, 0),
                    severity = severity,
                    source = "markdownlint-cli2",
                    message = markdownlint_message(item),
                })
            end
        end
        return diagnostics
    end

    local function run_markdownlint(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "markdown" then
            return
        end

        local filename = vim.api.nvim_buf_get_name(bufnr)
        if filename == "" or vim.fn.filereadable(filename) ~= 1 then
            vim.diagnostic.reset(markdownlint_ns, bufnr)
            return
        end

        if vim.fn.executable "markdownlint-cli2" ~= 1 then
            return
        end

        local stat = vim.uv.fs_stat(filename)
        if stat and stat.size > 256 * 1024 then
            return
        end

        local state = markdownlint_state[bufnr] or { generation = 0 }
        state.generation = state.generation + 1
        markdownlint_state[bufnr] = state
        local generation = state.generation

        local config_path = vim.fn.tempname() .. ".json"
        local config = {
            noBanner = true,
            noProgress = true,
            outputFormatters = {
                { markdownlint_formatter },
            },
        }
        vim.fn.writefile({ vim.json.encode(config) }, config_path)

        vim.system(
            {
                "markdownlint-cli2",
                "--config",
                config_path,
                "--no-globs",
                filename,
            },
            { cwd = vim.fs.dirname(filename), text = true },
            function(result)
                vim.schedule(function()
                    pcall(vim.fn.delete, config_path)

                    if not vim.api.nvim_buf_is_valid(bufnr) then
                        return
                    end
                    if markdownlint_state[bufnr] == nil or markdownlint_state[bufnr].generation ~= generation then
                        return
                    end

                    if result.code == 0 or result.code == 1 then
                        vim.diagnostic.set(markdownlint_ns, bufnr, markdownlint_diagnostics(result.stdout, bufnr))
                        return
                    end

                    vim.diagnostic.reset(markdownlint_ns, bufnr)
                    local stderr = vim.trim(result.stderr or "")
                    if stderr ~= "" then
                        util.print_error("markdownlint-cli2: " .. stderr, "WarningMsg")
                    end
                end)
            end
        )
    end

    local function setup_markdownlint(bufnr)
        if vim.b[bufnr].markdownlint_cli2_enabled then
            return
        end
        vim.b[bufnr].markdownlint_cli2_enabled = true

        vim.api.nvim_create_autocmd({ "BufWritePost", "CursorHold", "InsertLeave" }, {
            group = vim.api.nvim_create_augroup("markdownlint_cli2_" .. bufnr, { clear = true }),
            buffer = bufnr,
            callback = function()
                run_markdownlint(bufnr)
            end,
        })
        run_markdownlint(bufnr)
    end

    vim.diagnostic.config {
        virtual_text = {
            prefix = " ",
        },
        float = {
            border = "single",
        },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = "E",
                [vim.diagnostic.severity.WARN] = "W",
                [vim.diagnostic.severity.INFO] = "I",
                [vim.diagnostic.severity.HINT] = "H",
            },
        },
    }

    vim.lsp.config("*", {
        capabilities = capabilities,
    })

    vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = {
            ".luarc.json",
            ".luarc.jsonc",
            ".luacheckrc",
            ".stylua.toml",
            "stylua.toml",
            "selene.toml",
            "selene.yml",
            ".git",
        },
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                workspace = {
                    checkThirdParty = false,
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    })

    vim.lsp.config("rust_analyzer", {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = {
            "Cargo.toml",
            "rust-project.json",
            ".git",
        },
        settings = {
            ["rust-analyzer"] = {
                completion = {
                    privateEditable = {
                        enable = true,
                    },
                },
                lens = {
                    enable = false,
                },
                procMacro = {
                    enable = true,
                },
                updates = {
                    channel = "stable",
                },
            },
        },
    })

    vim.lsp.config("ty", {
        cmd = { "ty", "server" },
        filetypes = { "python" },
        root_markers = {
            "pyproject.toml",
            "uv.lock",
            "ty.toml",
            ".git",
        },
    })

    vim.lsp.config("ruff", {
        cmd = { "ruff", "server" },
        filetypes = { "python" },
        root_markers = {
            "pyproject.toml",
            "ruff.toml",
            ".ruff.toml",
            ".git",
        },
    })

    vim.lsp.config("harper_ls", {
        cmd = { "harper-ls", "--stdio" },
        filetypes = { "markdown", "text", "tex", "typst" },
        root_markers = { ".git" },
        settings = {
            ["harper-ls"] = {
                diagnosticSeverity = "hint",
                isolateEnglish = true,
                dialect = "American",
                linters = {
                    SpellCheck = true,
                    SpelledNumbers = false,
                    AnA = true,
                    SentenceCapitalization = true,
                    UnclosedQuotes = true,
                    WrongApostrophe = false,
                    LongSentences = true,
                    RepeatedWords = true,
                    Spaces = true,
                    CorrectNumberSuffix = true,
                },
            },
        },
    })

    if vim.fn.executable "tinymist" == 1 then
        vim.lsp.config("tinymist", {
            cmd = { "tinymist" },
            filetypes = { "typst" },
            single_file_support = true,
            root_markers = {
                "typst.toml",
                ".git",
            },
        })
    end

    vim.lsp.config("jsonls", {
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json", "jsonc" },
        root_markers = { ".git" },
    })

    vim.lsp.config("yamlls", {
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml" },
        root_markers = { ".git" },
    })

    vim.lsp.config("taplo", {
        cmd = { "taplo", "lsp", "--no-auto-config", "stdio" },
        filetypes = { "toml" },
        root_markers = {
            ".taplo.toml",
            "taplo.toml",
            ".git",
        },
    })

    local enabled_lsp = {
        "lua_ls",
        "rust_analyzer",
        "ty",
        "ruff",
        "harper_ls",
        "jsonls",
        "yamlls",
        "taplo",
    }
    if vim.fn.executable "tinymist" == 1 then
        table.insert(enabled_lsp, "tinymist")
    end
    vim.lsp.enable(enabled_lsp)

    util.autocmd_vimrc { "FileType" } {
        pattern = "markdown",
        callback = function(meta)
            setup_markdownlint(meta.buf)
        end,
    }

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == "markdown" then
            setup_markdownlint(buf)
        end
    end

    util.create_cmd("LspQuickfix", function()
        vim.diagnostic.setqflist()
        vim.cmd [[cwindow]]
    end)

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to LSP definition" })
    vim.keymap.set("n", "t", "<Nop>", { desc = "Disable t prefix for LSP mappings" })
    vim.keymap.set("n", "td", util.cmdcr "Telescope lsp_definitions", { desc = "Search LSP definitions" })
    vim.keymap.set("n", "ti", util.cmdcr "Telescope lsp_implementations", { desc = "Search LSP implementations" })
    vim.keymap.set("n", "tr", util.cmdcr "Telescope lsp_references", { desc = "Search LSP references" })
    vim.keymap.set("n", "ty", util.cmdcr "Telescope lsp_type_definitions", { desc = "Search LSP type definitions" })
    vim.keymap.set("n", "tn", vim.lsp.buf.rename, { desc = "Rename symbol" })
    vim.keymap.set({ "n", "x" }, "ta", vim.lsp.buf.code_action, { desc = "Code action" })
    vim.keymap.set("n", "tw", vim.diagnostic.open_float, { desc = "Show diagnostics float" })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover documentation" })
    vim.keymap.set("n", ")", function()
        vim.diagnostic.jump { count = 1, float = true }
    end, { desc = "Next diagnostic" })
    vim.keymap.set("n", "(", function()
        vim.diagnostic.jump { count = -1, float = true }
    end, { desc = "Previous diagnostic" })
end

function M.conform()
    require("conform").setup {
        formatters_by_ft = {
            html = { "prettierd" },
            css = { "prettierd" },
            markdown = { "prettier" },
            json = { "prettier" },
            jsonc = { "prettier" },
            yaml = { "prettier" },
            toml = { "taplo" },
        },
        format_on_save = function(bufnr)
            local ft = vim.bo[bufnr].filetype
            if ft == "html" or ft == "css" or ft == "markdown" or ft == "json" or ft == "jsonc" or ft == "yaml" or ft == "toml" then
                return { timeout_ms = 3000, lsp_format = "fallback" }
            end
            return nil
        end,
    }
end

return M
