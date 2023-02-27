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

vim.cmd [[
  filetype plugin indent on
  syntax enable
]]

require "rc.plugin_loader"
require "rc.autocmd"
require "rc.option"
require "rc.abbr"
require "rc.keymap"
require "rc.filetype"
