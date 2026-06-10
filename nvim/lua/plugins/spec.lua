local config = require "plugins.setup"

return {
    { "neovim-treesitter/treesitter-parser-registry" },
    { "neovim-treesitter/nvim-treesitter", config = config.treesitter },
    { "sainnhe/everforest", config = config.everforest },
    { "gaoDean/autolist.nvim", ft = { "markdown", "text", "gitcommit" }, config = config.autolist },
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
        "Kicamon/markdown-table-mode.nvim",
        ft = { "markdown" },
        cmd = {
            "Mtm",
        },
        config = config.markdown_table_mode,
    },
    { "lervag/vimtex", ft = { "tex", "bib" }, config = config.vimtex },
    { "williamboman/mason.nvim", config = config.mason },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            "williamboman/mason.nvim",
        },
        config = config.mason_tools,
    },
    {
        "stevearc/oil.nvim",
        cmd = { "Oil" },
        keys = {
            { "<Leader>e", desc = "Open parent directory" },
        },
        config = config.oil,
    },
    { "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" }, config = config.gitsigns },
    { "windwp/nvim-autopairs", event = "InsertEnter", config = config.autopairs },
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
    { "saghen/blink.cmp", version = "1.*", event = "InsertEnter", config = config.blink },
    { "folke/lazydev.nvim", config = config.lsp },
    { "stevearc/conform.nvim", event = { "BufReadPre", "BufNewFile" }, config = config.conform },
    { "nvim-treesitter/nvim-treesitter-textobjects", config = config.treesitter_textobjects },
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
}
