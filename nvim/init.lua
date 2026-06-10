---@type integer
local augroup = vim.api.nvim_create_augroup("vimrc", { clear = true })
_G.vimrc = {
    -- operator
    op = {},
    motion = {},
    omnifunc = {},
    state = {},
    debug = {},
}

vim.g.mapleader = " "
vim.g.maplocalleader = vim.g.mapleader

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.loader.enable()

require "plugins.bootstrap"
require "config.autocmd"
require "config.option"
require "config.abbr"
require "config.keymap"
require "config.filetype"
