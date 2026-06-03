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

    -- editing
    { "dkarter/bullets.vim", ft = { "markdown", "text", "gitcommit" }, config = config.bullets },
    { "nvim-lualine/lualine.nvim", event = "VeryLazy", config = config.lualine },
    {
        "numToStr/Comment.nvim",
        keys = {
            { "gc", mode = { "n", "x", "o" } },
            { "gb", mode = { "n", "x", "o" } },
            { "gcc", mode = "n" },
            { "gcu", mode = "n" },
        },
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        config = config.comment,
    },
    {
        "kylechui/nvim-surround",
        keys = {
            { "cs", mode = "n" },
            { "ds", mode = "n" },
            { "cS", mode = "n" },
            { "gS", mode = "x" },
            { "S", mode = "x" },
            { "ys", mode = "n" },
            { "yS", mode = "n" },
            { "yss", mode = "n" },
            { "ySs", mode = "n" },
            { "ySS", mode = "n" },
        },
        config = config.surround,
    },
    {
        "dhruvasagar/vim-table-mode",
        ft = { "markdown" },
        cmd = {
            "Tableize",
            "TableModeEnable",
            "TableModeDisable",
            "TableModeToggle",
        },
        config = config.table_mode,
    },

    -- general plugins
    { "lervag/vimtex", ft = { "tex", "bib" }, config = config.vimtex },
    {
        "stevearc/oil.nvim",
        cmd = { "Oil" },
        keys = {
            { "<Leader>e", desc = "Open parent directory" },
        },
        config = config.oil,
    },

    -- git
    { "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" }, config = config.gitsigns },

    -- paren
    { "windwp/nvim-autopairs", event = "InsertEnter", config = config.autopairs },

    -- telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        cmd = { "Telescope" },
        keys = {
            { "so", desc = "Telescope git files" },
            { "sO", desc = "Telescope find files" },
            { "sb", desc = "Telescope buffers" },
            { "sg", desc = "Telescope live grep" },
            { "tq", desc = "Telescope quickfix" },
        },
        config = config.telescope,
    },

    -- lsp/completion/format
    { "saghen/blink.cmp", version = "1.*", event = "InsertEnter", config = config.blink },
    { "folke/lazydev.nvim", config = config.lsp },
    { "stevearc/conform.nvim", event = { "BufReadPre", "BufNewFile" }, config = config.conform },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = config.treesitter_textobjects,
    },

    -- tree-sitter / filetype

    -- misc
    {
        "monaqa/dial.nvim",
        keys = {
            { "<C-a>", mode = { "n", "v" }, desc = "Increment number" },
            { "<C-x>", mode = { "n", "v" }, desc = "Decrement number" },
            { "g<C-a>", mode = "v", desc = "Increment number by gvisual" },
            { "g<C-x>", mode = "v", desc = "Decrement number by gvisual" },
        },
        config = config.dial,
    },
    {
        "johmsalas/text-case.nvim",
        keys = {
            { "gat", mode = { "n", "v" }, desc = "Quick change to title case" },
        },
        config = config.textcase,
    },
    { "wakatime/vim-wakatime" },
}, {
    install = {
        missing = true,
    },
    checker = {
        enabled = false,
    },
})

return true
