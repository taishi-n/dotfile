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
            theme = "dracula",
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

return M
