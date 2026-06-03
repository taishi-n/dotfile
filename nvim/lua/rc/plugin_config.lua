local M = {}

local util = require "rc.util"

function M.vimtex()
    vim.g.tex_flavor = "latex"
    vim.g.vimtex_view_method = "sioyek"
    vim.g.vimtex_view_sioyek_exe = "sioyek"
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_compiler_latexmk = {
        executable = "latexmk",
        options = {
            "-pdf",
            "-interaction=nonstopmode",
            "-synctex=1",
        },
    }

    vim.lsp.config("texlab", {
        cmd = { "texlab" },
        filetypes = { "tex", "bib" },
        root_markers = {
            ".latexmkrc",
            "latexmkrc",
            ".git",
        },
        settings = {
            texlab = {
                build = {
                    executable = "latexmk",
                    args = {
                        "-pdf",
                        "-interaction=nonstopmode",
                        "-synctex=1",
                        "%f",
                    },
                    onSave = false,
                    forwardSearchAfter = false,
                },
                forwardSearch = {
                    executable = "sioyek",
                    args = {
                        "--reuse-window",
                        "--forward-search-file",
                        "%f",
                        "--forward-search-line",
                        "%l",
                        "%p",
                    },
                },
                latexFormatter = "latexindent",
            },
        },
    })
    vim.lsp.enable "texlab"
end

--  old
--  TODO: translate into lua
function M.bullets()
    vim.g.bullets_enabled_file_types = {'markdown', 'text', 'gitcommit'}
    vim.g.bullets_checkbox_markers = ' x'
    vim.g.bullets_outline_levels = {}
end

function M.textcase()
    vim.api.nvim_set_keymap('n', 'gat', "<cmd>lua require('textcase').quick_replace('to_title_case')<CR>", { desc = "Telescope Quick Change" })
    vim.api.nvim_set_keymap('v', 'gat', "<cmd>lua require('textcase').quick_replace('to_title_case')<CR>", { desc = "Telescope Quick Change" })
end

function M.lualine()
    _G.debug_lualine = {}
    require("lualine").setup {
        sections = {
            lualine_b = {
                function()
                    return [[%f %m]]
                end,
            },
            lualine_y = {
                function()
                    local branch = vim.fn["gina#component#repo#branch"]()
                    local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
                    if branch == "" then
                        return cwd
                    else
                        return cwd .. " │ " .. vim.fn["gina#component#repo#branch"]()
                    end
                end,
            },
            lualine_z = {
                function()
                    local n = #tostring(vim.fn.line "$")
                    n = math.max(n, 3)
                    return "%" .. n .. [[l/%-3L:%-2c]]
                end,
            },
        },
        options = {
            theme = "everforest",
            section_separators = { "", "" },
            component_separators = { "", "" },
            globalstatus = true,
            refresh = {
                statusline = 10000,
                -- statusline = 1000,
                tabline = 10000,
                winbar = 10000,
            },
        },
    }
end

function M.oil()
    require("oil").setup {
        default_file_explorer = true,
        columns = {
            "icon",
        },
        view_options = {
            show_hidden = true,
        },
    }

    vim.keymap.set("n", "<Leader>e", "<Cmd>Oil<CR>", { desc = "Open parent directory" })
end

function M.gitsigns()
    require("gitsigns").setup {
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns
            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end

            vim.keymap.set("n", "]c", function()
                if vim.wo.diff then
                    return "]c"
                end
                vim.schedule(gs.next_hunk)
                return "<Ignore>"
            end, { buffer = bufnr, desc = "Next git hunk", expr = true })
            vim.keymap.set("n", "[c", function()
                if vim.wo.diff then
                    return "[c"
                end
                vim.schedule(gs.prev_hunk)
                return "<Ignore>"
            end, { buffer = bufnr, desc = "Previous git hunk", expr = true })

            map({ "n", "v" }, "<Leader>gs", gs.stage_hunk, "Stage git hunk")
            map({ "n", "v" }, "<Leader>gr", gs.reset_hunk, "Reset git hunk")
            map("n", "<Leader>gS", gs.stage_buffer, "Stage buffer")
            map("n", "<Leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
            map("n", "<Leader>gR", gs.reset_buffer, "Reset buffer")
            map("n", "<Leader>gp", gs.preview_hunk, "Preview git hunk")
            map("n", "<Leader>gb", function()
                gs.blame_line { full = true }
            end, "Blame line")
            map("n", "<Leader>gd", gs.diffthis, "Diff against index")
            map("n", "<Leader>gD", function()
                gs.diffthis "~"
            end, "Diff against previous commit")
            map("n", "<Leader>gt", gs.toggle_current_line_blame, "Toggle line blame")
        end,
    }
end

-- §§1 paren
function M.autopairs()
    local npairs = require "nvim-autopairs"
    local Rule = require "nvim-autopairs.rule"
    local cond = require "nvim-autopairs.conds"

    npairs.setup {
        check_ts = true,
        enable_check_bracket_line = false,
        ignored_next_char = "[%w%.%-_]",
    }

    npairs.remove_rule "'"

    npairs.add_rules {
        Rule("$", "$", { "latex", "tex" })
            :with_pair(cond.not_before_regex [[\\]]),
        Rule("`", "`", { "rst" }),
    }
end

-- §§1 textedit

function M.python()
    vim.g.python_highlight_all = 1
end

function M.blink()
    require("blink.cmp").setup {
        keymap = {
            preset = "default",
        },
        completion = {
            list = {
                selection = {
                    preselect = false,
                    auto_insert = false,
                },
            },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },
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
        filetypes = { "markdown", "text", "tex", "latex", "typst" },
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

    vim.lsp.config("jsonls", {
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json", "jsonc" },
        root_markers = { ".git" },
    })

    vim.lsp.config("yamlls", {
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml", "yaml.docker-compose" },
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

    vim.lsp.enable {
        "lua_ls",
        "rust_analyzer",
        "ruff",
        "harper_ls",
        "jsonls",
        "yamlls",
        "taplo",
    }

    util.create_cmd("LspQuickfix", function()
        vim.diagnostic.setqflist()
        vim.cmd [[cwindow]]
    end)

    vim.keymap.set("n", "gd", vim.lsp.buf.definition)
    vim.keymap.set("n", "t", "<Nop>")
    vim.keymap.set("n", "td", util.cmdcr "Telescope lsp_definitions")
    vim.keymap.set("n", "ti", util.cmdcr "Telescope lsp_implementations")
    vim.keymap.set("n", "tr", util.cmdcr "Telescope lsp_references")
    vim.keymap.set("n", "ty", util.cmdcr "Telescope lsp_type_definitions")
    vim.keymap.set("n", "tn", vim.lsp.buf.rename)
    vim.keymap.set({ "n", "x" }, "ta", vim.lsp.buf.code_action)
    vim.keymap.set("n", "tw", vim.diagnostic.open_float)
    vim.keymap.set("n", "K", vim.lsp.buf.hover)
    vim.keymap.set("n", ")", function()
        vim.diagnostic.jump { count = 1, float = true }
    end)
    vim.keymap.set("n", "(", function()
        vim.diagnostic.jump { count = -1, float = true }
    end)
end

function M.conform()
    require("conform").setup {
        formatters_by_ft = {
            html = { "prettierd" },
            css = { "prettierd" },
            tex = { "latexindent" },
            latex = { "latexindent" },
            markdown = { "prettier" },
            json = { "prettier" },
            jsonc = { "prettier" },
            yaml = { "prettier" },
            toml = { "taplo" },
        },
        format_on_save = function(bufnr)
            local ft = vim.bo[bufnr].filetype
            if ft == "html" or ft == "css" or ft == "tex" or ft == "latex" or ft == "markdown" or ft == "json" or ft == "jsonc" or ft == "yaml" or ft == "toml" then
                return { timeout_ms = 3000, lsp_format = "fallback" }
            end
            return nil
        end,
    }
end

function M.dial()
    local augend = require "dial.augend"

    local function concat(tt)
        local v = {}
        for _, t in ipairs(tt) do
            vim.list_extend(v, t)
        end
        return v
    end

    local basic = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.integer.alias.binary,
        augend.date.new {
            pattern = "%Y/%m/%d",
            default_kind = "day",
            clamp = true,
            end_sensitive = true,
        },
        augend.date.new {
            pattern = "%Y-%m-%d",
            default_kind = "day",
            clamp = true,
            end_sensitive = true,
        },
        augend.date.new {
            pattern = "%Y年%-m月%-d日",
            default_kind = "day",
            clamp = true,
            end_sensitive = true,
        },
        augend.date.new {
            pattern = "%-m月%-d日",
            default_kind = "day",
            clamp = true,
            end_sensitive = true,
        },
        augend.date.new {
            pattern = "%-m月%-d日(%J)",
            default_kind = "day",
            clamp = true,
            end_sensitive = true,
        },
        augend.date.new {
            pattern = "%-m月%-d日（%J）",
            default_kind = "day",
            clamp = true,
            end_sensitive = true,
        },
        augend.date.new {
            pattern = "%m/%d",
            default_kind = "day",
            only_valid = true,
            word = true,
            clamp = true,
            end_sensitive = true,
        },
        augend.date.new {
            pattern = "%Y/%m/%d (%J)",
            default_kind = "day",
            clamp = true,
            end_sensitive = true,
        },
        augend.date.new {
            pattern = "%Y/%m/%d（%J）",
            default_kind = "day",
            clamp = true,
            end_sensitive = true,
        },
        augend.date.new {
            pattern = "%a %b %-d %Y",
            default_kind = "day",
            clamp = true,
            end_sensitive = true,
        },
        augend.date.new {
            pattern = "%H:%M",
            default_kind = "min",
            only_valid = true,
            word = true,
        },
        augend.constant.new {
            elements = { "true", "false" },
            word = true,
            cyclic = true,
        },
        augend.constant.new {
            elements = { "True", "False" },
            word = true,
            cyclic = true,
        },
        augend.constant.alias.ja_weekday,
        augend.constant.alias.ja_weekday_full,
        augend.hexcolor.new { case = "lower" },
        augend.semver.alias.semver,
    }

    require("dial.config").augends:register_group {
        default = basic,
        markdown = concat {
            basic,
            { augend.misc.alias.markdown_header },
        },
        visual = concat {
            basic,
            {
                augend.constant.alias.alpha,
                augend.constant.alias.Alpha,
            },
        },
    }

    vim.api.nvim_set_keymap("n", "<C-a>", require("dial.map").inc_normal(), { noremap = true })
    vim.api.nvim_set_keymap("n", "<C-x>", require("dial.map").dec_normal(), { noremap = true })
    vim.api.nvim_set_keymap("v", "<C-a>", require("dial.map").inc_visual "visual", { noremap = true })
    vim.api.nvim_set_keymap("v", "<C-x>", require("dial.map").dec_visual "visual", { noremap = true })
    vim.api.nvim_set_keymap("v", "g<C-a>", require("dial.map").inc_gvisual "visual", { noremap = true })
    vim.api.nvim_set_keymap("v", "g<C-x>", require("dial.map").dec_gvisual "visual", { noremap = true })

    util.autocmd_vimrc { "FileType" } {
        pattern = "markdown",
        callback = function()
            vim.api.nvim_set_keymap("n", "<C-a>", require("dial.map").inc_normal "markdown", { noremap = true })
            vim.api.nvim_set_keymap("n", "<C-x>", require("dial.map").dec_normal "markdown", { noremap = true })
            vim.api.nvim_set_keymap("v", "<C-a>", require("dial.map").inc_visual "markdown", { noremap = true })
            vim.api.nvim_set_keymap("v", "<C-x>", require("dial.map").dec_visual "markdown", { noremap = true })
            vim.api.nvim_set_keymap("v", "g<C-a>", require("dial.map").inc_gvisual "markdown", { noremap = true })
            vim.api.nvim_set_keymap("v", "g<C-x>", require("dial.map").dec_gvisual "markdown", { noremap = true })
        end,
    }
end

function M.treesitter()
    local install_dir = vim.fn.stdpath "data" .. "/treesitter"
    local parsers = {
        "bash",
        "css",
        "dot",
        "html",
        "html_tags",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "rust",
        "toml",
        "yaml",
    }

    local ft_to_parser = {
        sh = "bash",
        zsh = "bash",
    }
    for ft, parser in pairs(ft_to_parser) do
        vim.treesitter.language.register(parser, ft)
    end

    local ok, treesitter = pcall(require, "nvim-treesitter")
    if not ok then
        util.print_error("nvim-treesitter is not available.", "WarningMsg")
        return
    end

    treesitter.setup {
        install_dir = install_dir,
    }
    if type(treesitter.install) == "function" then
        treesitter.install(parsers)
    else
        vim.opt.runtimepath:prepend(install_dir)
        util.print_error("nvim-treesitter is outdated; update plugins to enable parser installation.", "WarningMsg")
    end

    local indent_disabled = {
        bash = true,
        css = true,
        html = true,
        json = true,
        lua = true,
        python = true,
        query = true,
        toml = true,
        typescript = true,
        yaml = true,
    }

    local function large_file(buf)
        local max_filesize = 256 * 1024 -- 256 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            util.print_error("File too large: tree-sitter disabled.", "WarningMsg")
            return true
        end
        return false
    end

    util.autocmd_vimrc "FileType" {
        pattern = {
            "css",
            "dot",
            "html",
            "json",
            "lua",
            "markdown",
            "python",
            "query",
            "rust",
            "sh",
            "toml",
            "yaml",
            "zsh",
        },
        callback = function(meta)
            local buf = meta.buf
            if large_file(buf) then
                return
            end

            local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
            if not lang then
                return
            end

            local ok = pcall(vim.treesitter.start, buf, lang)
            if not ok then
                return
            end

            if not indent_disabled[lang] then
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end,
    }

    util.autocmd_vimrc { "BufWrite", "CursorHold", "InsertLeave" } {
        pattern = "*/queries/*/*.scm",
        callback = function(meta)
            pcall(vim.treesitter.query.lint, meta.buf)
        end,
    }

    vim.keymap.set("x", "v", "an", { remap = true })
    vim.keymap.set("x", "<C-o>", "in", { remap = true })
    vim.keymap.set("n", "ts", "<Cmd>Inspect<CR>")
end

function M.everforest()
    -- 色の微調整など
end

function M.telescope()
    local actions = require "telescope.actions"
    local builtin = require "telescope.builtin"

    -- Global remapping
    require("telescope").setup {
        defaults = {
            vimgrep_arguments = {
                "rg",
                "--line-number",
                "--no-heading",
                "--color=never",
                "--hidden",
                "--with-filename",
                "--column",
                -- '--smart-case'
            },
            prompt_prefix = "𝜻",
            find_command = {
                "rg",
                "--ignore",
                "--hidden",
                "--files",
            },
            mappings = {
                n = {
                    ["<Esc>"] = actions.close,
                },
            },
        },
    }

    vim.keymap.set("n", "so", "<Cmd>Telescope git_files<cr>")
    vim.keymap.set("n", "sO", "<Cmd>Telescope find_files<cr>")
    vim.keymap.set("n", "sb", "<Cmd>Telescope buffers<cr>")
    vim.keymap.set("n", "sg", "<Cmd>Telescope live_grep<cr>")
    vim.keymap.set("n", "tq", "<Cmd>Telescope quickfix<cr>")
end

return M
