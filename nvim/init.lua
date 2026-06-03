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

vim.loader.enable()

require "plugins.bootstrap"
require "config.autocmd"
require "config.option"
require "config.abbr"
require "config.keymap"
require "config.filetype"
