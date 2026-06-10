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
            default = { "lsp", "path", "snippets", "buffer" },
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
