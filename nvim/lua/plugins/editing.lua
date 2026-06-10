local M = {}

local util = require "utils.util"

-- list editing
function M.autolist()
    local ok, autolist = pcall(require, "autolist")
    if not ok then
        util.print_error("autolist.nvim is not available.", "WarningMsg")
        return
    end

    autolist.setup()

    local function setup_autolist_keymaps(buf)
        vim.keymap.set("i", "<Tab>", "<cmd>AutolistTab<CR>", { buffer = buf, desc = "Indent markdown list item" })
        vim.keymap.set("i", "<S-Tab>", "<cmd>AutolistShiftTab<CR>", { buffer = buf, desc = "Dedent markdown list item" })
        vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<CR>", { buffer = buf, desc = "Continue markdown list" })
        vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<CR>", { buffer = buf, desc = "Continue markdown list" })
        vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<CR>", { buffer = buf, desc = "Insert markdown list item above" })
        vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<CR><CR>", { buffer = buf, desc = "Toggle markdown checkbox" })
        vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<CR>", { buffer = buf, desc = "Recalculate markdown list" })
    end

    util.autocmd_vimrc { "FileType" } {
        pattern = { "markdown", "text", "gitcommit" },
        callback = function(meta)
            setup_autolist_keymaps(meta.buf)
        end,
    }

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.tbl_contains({ "markdown", "text", "gitcommit" }, vim.bo[buf].filetype) then
            setup_autolist_keymaps(buf)
        end
    end
end

function M.comment()
    local ok_ctx, ts_context_commentstring = pcall(require, "ts_context_commentstring")
    if ok_ctx then
        ts_context_commentstring.setup {}
    end

    local ok, comment = pcall(require, "Comment")
    if not ok then
        util.print_error("Comment.nvim is not available.", "WarningMsg")
        return
    end

    comment.setup {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
    }
end

function M.surround()
    require("nvim-surround").setup {}
end

function M.markdown_table_mode()
    local ok, markdown_table_mode = pcall(require, "markdown-table-mode")
    if not ok then
        util.print_error("markdown-table-mode.nvim is not available.", "WarningMsg")
        return
    end

    markdown_table_mode.setup {
        filetype = {
            "*.md",
        },
        options = {
            insert = true,
            insert_leave = true,
            pad_separator_line = false,
            alig_style = "default",
        },
    }
end

function M.textcase()
    vim.keymap.set({ "n", "v" }, "gat", function()
        require("textcase").quick_replace("to_title_case")
    end, { desc = "Quick change to title case" })
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

function M.dial()
    local augend = require "dial.augend"
    local dial_map = require "dial.map"

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

    local function setup_markdown_keymaps(buf)
        vim.keymap.set("n", "<C-a>", dial_map.inc_normal "markdown", { buffer = buf, desc = "Increment markdown heading level" })
        vim.keymap.set("n", "<C-x>", dial_map.dec_normal "markdown", { buffer = buf, desc = "Decrement markdown heading level" })
        vim.keymap.set("v", "<C-a>", dial_map.inc_visual "markdown", { buffer = buf, desc = "Increment number in visual selection" })
        vim.keymap.set("v", "<C-x>", dial_map.dec_visual "markdown", { buffer = buf, desc = "Decrement number in visual selection" })
        vim.keymap.set("v", "g<C-a>", dial_map.inc_gvisual "markdown", { buffer = buf, desc = "Increment number by gvisual selection" })
        vim.keymap.set("v", "g<C-x>", dial_map.dec_gvisual "markdown", { buffer = buf, desc = "Decrement number by gvisual selection" })
    end

    vim.keymap.set("n", "<C-a>", dial_map.inc_normal(), { desc = "Increment number" })
    vim.keymap.set("n", "<C-x>", dial_map.dec_normal(), { desc = "Decrement number" })
    vim.keymap.set("v", "<C-a>", dial_map.inc_visual "visual", { desc = "Increment number in visual selection" })
    vim.keymap.set("v", "<C-x>", dial_map.dec_visual "visual", { desc = "Decrement number in visual selection" })
    vim.keymap.set("v", "g<C-a>", dial_map.inc_gvisual "visual", { desc = "Increment number by gvisual selection" })
    vim.keymap.set("v", "g<C-x>", dial_map.dec_gvisual "visual", { desc = "Decrement number by gvisual selection" })

    util.autocmd_vimrc { "FileType" } {
        pattern = "markdown",
        callback = function(meta)
            setup_markdown_keymaps(meta.buf)
        end,
    }

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == "markdown" then
            setup_markdown_keymaps(buf)
        end
    end
end

return M
