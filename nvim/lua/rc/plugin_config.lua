local M = {}

local util = require "rc.util"

function M.vimtex()
    vim.g.tex_flavor = "latex"
end

--  old
--  TODO: translate into lua
function M.bullets()
    vim.g.bullets_enabled_file_types = {'markdown', 'text', 'gitcommit'}
    vim.g.bullets_checkbox_markers = ' x'
    vim.g.bullets_outline_levels = {}
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
            lualine_c = {
                function()
                    return (vim.fn["coc#status"]()):gsub("%%", "%%%%")
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

-- §§1 paren
function M.lexima()
    vim.g["lexima_enable_endwise_rules"] = 1
    vim.g["lexima_enable_space_rules"] = 0
    vim.g["lexima_no_default_rules"] = 1
    vim.fn["lexima#set_default_rules"]()

    -- シングルクォート補完の無効化
    vim.fn["lexima#add_rule"] {
        filetype = { "latex", "tex", "satysfi" },
        char = "'",
        input = "'",
    }

    vim.fn["lexima#add_rule"] {
        char = "{",
        at = [=[\%#[-0-9a-zA-Z_]]=],
        input = "{",
    }

    -- TeX/LaTeX
    vim.fn["lexima#add_rule"] {
        filetype = { "latex", "tex" },
        char = "{",
        input = "{",
        at = [[\%#\\]],
    }
    vim.fn["lexima#add_rule"] {
        filetype = { "latex", "tex" },
        char = "$",
        input_after = "$",
    }
    vim.fn["lexima#add_rule"] {
        filetype = { "latex", "tex" },
        char = "$",
        at = [[$\%#\$]],
        leave = 1,
    }
    vim.fn["lexima#add_rule"] {
        filetype = { "latex", "tex" },
        char = "<BS>",
        at = [[\$\%#\$]],
        leave = 1,
    }

    -- SATySFi
    vim.fn["lexima#add_rule"] {
        filetype = { "satysfi" },
        char = "$",
        input = "${",
        input_after = "}",
    }
    vim.fn["lexima#add_rule"] {
        filetype = { "satysfi" },
        char = "$",
        at = [[\\\%#]],
        leave = 1,
    }

    -- reST
    vim.fn["lexima#add_rule"] {
        filetype = { "rst" },
        char = "``",
        input_after = "``",
    }
end

-- §§1 textedit

-- §§1 coc
local function coc_config()
    local function coc_service_names(arglead, cmdline, cursorpos)
        return vim.tbl_map(function(service)
            return service["id"]
        end, vim.fn.CocAction "services")
    end

    util.create_cmd("CocToggleService", function(meta)
        vim.fn.CocAction("toggleService", meta.args)
    end, { nargs = 1, complete = coc_service_names })

    vim.opt.tagfunc = "CocTagFunc"

    vim.g["coc_global_extensions"] = {
        "coc-json",
        "coc-marketplace",
        "coc-pyright",
        "coc-rust-analyzer",
        "coc-snippets",
        "coc-sumneko-lua",
        "coc-toml",
        "coc-yaml",
    }

    vim.keymap.set("n", "gd", "<C-]>")

    vim.keymap.set("n", "t", "<Nop>")

    vim.keymap.set("i", "<C-l>", "<Plug>(coc-snippets-expand)")  -- old

    vim.keymap.set("n", "td", util.cmdcr "Telescope coc definitions")
    vim.keymap.set("n", "ti", util.cmdcr "Telescope coc implementations")
    vim.keymap.set("n", "tr", util.cmdcr "Telescope coc references")
    vim.keymap.set("n", "ty", util.cmdcr "Telescope coc type_definitions")
    vim.keymap.set("n", "tn", "<Plug>(coc-rename)")
    vim.keymap.set("n", "ta", "<Plug>(coc-codeaction-cursor)")
    vim.keymap.set("x", "ta", "<Plug>(coc-codeaction-selected)")
    vim.keymap.set("n", "tw", "<Plug>(coc-float-jump)")
    vim.keymap.set("n", "K", util.cmdcr "call CocActionAsync('doHover')")

    -- coc#_select_confirm などは Lua 上では動かないので、 <Plug> にマッピングして使えるようにする
    vim.cmd [[
        inoremap <expr> <Plug>(vimrc-coc-select-confirm) coc#_select_confirm()
        inoremap <expr> <Plug>(vimrc-lexima-expand-cr) lexima#expand('<LT>CR>', 'i')
    ]]

    vim.keymap.set("i", "<CR>", function()
        if util.to_bool(vim.fn["coc#pum#visible"]()) then
            -- 補完候補をセレクトしていたときのみ、補完候補の内容で確定する
            -- （意図せず補完候補がセレクトされてしまうのを抑止）
            if vim.fn["coc#pum#info"]()["index"] >= 0 then
                return "<Plug>(vimrc-coc-select-confirm)"
            end
            return "<C-y><Plug>(vimrc-lexima-expand-cr)"
        end
        return "<Plug>(vimrc-lexima-expand-cr)"
    end, { expr = true, remap = true })

    vim.cmd [[
      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~ '\s'
      endfunction

      " Insert <tab> when previous text is space, refresh completion if not.
      inoremap <silent><expr> <TAB>
        \ coc#pum#visible() ? coc#pum#next(1):
        \ pumvisible() ? "\<C-n>":
        \ <SID>check_back_space() ? "\<Tab>" :
        \ coc#refresh()
      inoremap <expr><S-TAB>
        \ coc#pum#visible() ? coc#pum#prev(1) :
        \ pumvisible() ? "\<C-p>":
        \ "\<C-h>"
    ]]

    vim.g.coc_snippet_next = "<C-g><C-j>"
    vim.g.coc_snippet_prev = "<C-g><C-k>"

    -- coc の diagnostics の内容を QuiciFix に流し込む。
    local function coc_diag_to_quickfix()
        local diags = vim.fn["CocAction"] "diagnosticList"
        ---@type any[]
        local entries = vim.tbl_map(function(diag)
            return {
                filename = diag.file,
                lnum = diag.lnum,
                end_lnum = diag.end_lnum,
                col = diag.col,
                end_col = diag.end_col,
                text = diag.message,
                type = diag.severity:sub(1, 1),
            }
        end, diags)

        vim.fn.setqflist(entries)
        vim.fn.setqflist({}, "a", { title = "Coc diagnostics" })
    end

    util.create_cmd("CocQuickfix", function()
        coc_diag_to_quickfix()
        vim.cmd [[cwindow]]
    end)

    ---diagnostics のある位置にジャンプする。ただし種類に応じて優先順位を付ける。
    ---つまり、エラーがあればまずエラーにジャンプする。
    ---エラーがなく警告があれば、警告にジャンプする。みたいな。
    ---@param forward boolean
    local function jump_diag(forward)
        local action_name = util.ifexpr(forward, "diagnosticNext", "diagnosticPrevious")
        util.motion_autoselect {
            function()
                vim.fn.CocAction(action_name, "error")
            end,
            function()
                vim.fn.CocAction(action_name, "warning")
            end,
            function()
                vim.fn.CocAction(action_name, "information")
            end,
            function()
                vim.fn.CocAction(action_name, "hint")
            end,
        }
    end

    vim.keymap.set("n", ")", function()
        jump_diag(true)
    end)
    vim.keymap.set("n", "(", function()
        jump_diag(false)
    end)
end

function M.python()
    vim.g.python_highlight_all = 1
end

function M.coc()
    -- nvim_lsp を明示的に読み込む場合のみ skip
    if util.to_bool(vim.fn.filereadable ".local_ignore_use_nvim_lsp") then
        return
    end
    vim.cmd.packadd "coc.nvim"
    vim.cmd.packadd "coc-nvim-lua"
    vim.cmd.packadd "telescope-coc.nvim"
    require('telescope').load_extension "coc"
    coc_config()
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
    local parser_install_dir = vim.fn.stdpath "data" .. "/treesitter"
    vim.opt.runtimepath:prepend(parser_install_dir)

    require("nvim-treesitter.configs").setup {
        parser_install_dir = parser_install_dir,
        ensure_installed = {
            "bash",
            "css",
            "dot",
            "html",
            "json",
            "latex",
            "lua",
            "markdown",
            "markdown_inline",
            "python",
            "query",
            "rust",
            "toml",
            "yaml",
        },
        highlight = {
            enable = true,
            -- disable = { "help" },
            disable = function(lang, buf)
                if lang == "help" then
                    return true
                end
                local max_filesize = 256 * 1024 -- 256 KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    util.print_error("File too large: tree-sitter disabled.", "WarningMsg")
                    return true
                end
            end,
            additional_vim_regex_highlighting = false,
        },
        indent = {
            enable = true,
            disable = {
                "bash",
                "css",
                "html",
                "json",
                "lua",
                "python",
                "query",
                "toml",
                "typescript",
                "yaml",
            },
        },
        incremental_selection = {
            enable = true,
        },
        query_linter = {
            enable = true,
            use_virtual_text = true,
            lint_events = { "BufWrite", "CursorHold", "InsertLeave" },
        },
    }

    vim.keymap.set("x", "v", function()
        if vim.fn.mode() == "v" then
            return ":lua require'nvim-treesitter.incremental_selection'.node_incremental()<CR>"
        else
            return "v"
        end
    end, { expr = true })

    vim.keymap.set("x", "<C-o>", function()
        return ":lua require'nvim-treesitter.incremental_selection'.node_decremental()<CR>"
    end, { expr = true })

    vim.keymap.set("n", "ts", "<Cmd>TSHighlightCapturesUnderCursor<CR>")
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
