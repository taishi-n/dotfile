local M = {}

local util = require "utils.util"

function M.treesitter()
    local install_dir = vim.fn.stdpath "data" .. "/treesitter"
    local parsers = {
        "c",
        "bash",
        "css",
        "dot",
        "ecma",
        "html",
        "html_tags",
        "javascript",
        "jsx",
        "tsx",
        "typescript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "svelte",
        "query",
        "rust",
        "toml",
        "vue",
        "yaml",
    }

    local ft_to_parser = {
        javascriptreact = "tsx",
        typescriptreact = "tsx",
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
        query = true,
        toml = true,
        typescript = true,
        yaml = true,
    }

    local function large_file(buf)
        local max_filesize = 256 * 1024 -- 256 KB
        local ok_stat, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok_stat and stats and stats.size > max_filesize then
            util.print_error("File too large: tree-sitter disabled.", "WarningMsg")
            return true
        end
        return false
    end

    util.autocmd_vimrc "FileType" {
        pattern = {
            "c",
            "css",
            "dot",
            "html",
            "javascript",
            "javascriptreact",
            "json",
            "lua",
            "markdown",
            "python",
            "query",
            "rust",
            "sh",
            "svelte",
            "toml",
            "tsx",
            "typescript",
            "typescriptreact",
            "yaml",
            "vue",
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

            local ok_start = pcall(vim.treesitter.start, buf, lang)
            if not ok_start then
                return
            end

            if lang == "python" then
                vim.wo.foldmethod = "expr"
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
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

    vim.keymap.set("x", "v", "an", { remap = true, desc = "Select around node" })
    vim.keymap.set("x", "<C-o>", "in", { remap = true, desc = "Select inside node" })
    vim.keymap.set("n", "ts", "<Cmd>Inspect<CR>", { desc = "Inspect tree-sitter node" })
end

function M.treesitter_textobjects()
    local move = require "nvim-treesitter-textobjects.move"

    vim.keymap.set({ "n", "x", "o" }, "]m", function()
        move.goto_next_start("@function.outer", "textobjects")
    end, { desc = "Next function" })
    vim.keymap.set({ "n", "x", "o" }, "[m", function()
        move.goto_previous_start("@function.outer", "textobjects")
    end, { desc = "Previous function" })
    vim.keymap.set({ "n", "x", "o" }, "]]", function()
        move.goto_next_start("@class.outer", "textobjects")
    end, { desc = "Next class" })
    vim.keymap.set({ "n", "x", "o" }, "[[", function()
        move.goto_previous_start("@class.outer", "textobjects")
    end, { desc = "Previous class" })
    vim.keymap.set({ "n", "x", "o" }, "]o", function()
        move.goto_next_start("@loop.outer", "textobjects")
    end, { desc = "Next loop" })
    vim.keymap.set({ "n", "x", "o" }, "[o", function()
        move.goto_previous_start("@loop.outer", "textobjects")
    end, { desc = "Previous loop" })
end

return M
