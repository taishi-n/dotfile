local config = require "rc.plugin_config"

local disable_plugins = {
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
}

for _, name in ipairs(disable_plugins) do
    vim.g["loaded_" .. name] = 1
end

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local out = vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    }
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
        }, true, {})
        return false
    end
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
    -- tree-sitter
    { "neovim-treesitter/treesitter-parser-registry" },
    { "neovim-treesitter/nvim-treesitter", config = config.treesitter },

    -- color scheme
    { "sainnhe/everforest", config = config.everforest },

    -- old
    { "dkarter/bullets.vim", config = config.bullets },
    { "tpope/vim-commentary" },
    { "tpope/vim-surround" },
    { "tpope/vim-repeat" },
    { "nvim-lualine/lualine.nvim", config = config.lualine },

    -- general plugins
    { "lervag/vimtex", config = config.vimtex },
    { "mattn/vim-maketable" },
    { "stevearc/oil.nvim", config = config.oil },

    -- git
    { "lewis6991/gitsigns.nvim", config = config.gitsigns },

    -- paren
    { "windwp/nvim-autopairs", config = config.autopairs },

    -- telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "fannheyward/telescope-coc.nvim",
        },
        config = config.telescope,
    },

    -- coc
    {
        "neoclide/coc.nvim",
        branch = "release",
        dependencies = {
            "fannheyward/telescope-coc.nvim",
        },
        config = config.coc,
    },

    -- lsp/format
    { "folke/lazydev.nvim", config = config.lua_lsp },
    { "stevearc/conform.nvim", config = config.conform },

    -- filetype
    { "justinmk/vim-syntax-extra" },
    { "vim-python/python-syntax", config = config.python },

    -- misc
    { "monaqa/dial.nvim", config = config.dial },
    { "johmsalas/text-case.nvim", config = config.textcase },
    { "lambdalisue/pastefix.vim" },
    { "wakatime/vim-wakatime" },
}, {
    defaults = {
        lazy = false,
    },
    install = {
        missing = true,
    },
    checker = {
        enabled = false,
    },
})

return true
