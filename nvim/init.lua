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

require "rc.plugin_loader"
require "rc.autocmd"
require "rc.option"
require "rc.abbr"
require "rc.keymap"
require "rc.filetype"
