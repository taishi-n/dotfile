local util = require "rc.util"
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

vim.cmd [[
    packadd vim-jetpack
]]

local callbacks = {}
require("jetpack.packer").startup(function(use)
    ---`use` 関数を wrap して、hook 系が渡せるようにする。
    --- * hook_before: プラグインをロードする前に読み込む。ほとんど使わない。
    --- * hook_after: プラグインをロードした後に読み込む。
    --- * unless_cwd: 特定のディレクトリ上で Vim を開いたときは、そのプラグインを読み込まない。
    ---@param t {hook_before?: fun(), hook_after?: fun(), unless_cwd?: string}
    local function add(t)
        local packname = vim.fn.fnamemodify(t[1], ":t")
        if t.hook_before ~= nil then
            t.hook_before()
        end
        if t.unless_cwd ~= nil then
            t.opt = true
            table.insert(callbacks, function()
                if vim.fn.expand(t.unless_cwd) ~= vim.fn.getcwd() then
                    vim.cmd.packadd(packname)
                    if t.hook_after ~= nil then
                        t.hook_after()
                    end
                else
                    util.print_error(([[WARNING: package '%s' is not loaded.]]):format(packname), "WarningMsg")
                end
            end)
        elseif t.hook_after ~= nil then
            table.insert(callbacks, t.hook_after)
        end
        use(t)
    end

    -- bootstrap
    add { "tani/vim-jetpack", commit = "c6ee097413951604c6719927f5e69a1b83b03759", opt = 1 }

    -- tree-sitter
    add { "nvim-treesitter/nvim-treesitter", hook_after = config.treesitter }

    -- color scheme
    add { "sainnhe/everforest", hook_after = config.everforest }

    -- old
    add { "dkarter/bullets.vim", hook_after = config.bullets }
    add { "tpope/vim-commentary" }
    add { "tpope/vim-surround" }
    add { "tpope/vim-repeat" }
    add { "nvim-lualine/lualine.nvim", hook_after = config.lualine }

    -- general plugins
    add { "lervag/vimtex", hook_after = config.vimtex }
    add { "mattn/vim-maketable" }

    -- paren
    add { "cohama/lexima.vim", hook_after = config.lexima }

    -- coc
    add { "neoclide/coc.nvim", branch = "release", hook_after = config.coc, opt = 1 }
    add { "rafcamlet/coc-nvim-lua", opt = 1 }
    add { "fannheyward/telescope-coc.nvim", opt = 1 }

    -- filetype
    add { "cespare/vim-toml" }
    add { "ekalinin/Dockerfile.vim" }
    add { "justinmk/vim-syntax-extra" }
    add { "vim-python/python-syntax", hook_after = config.python }

    -- telescope
    add { "nvim-telescope/telescope.nvim", hook_after = config.telescope }
    add { "nvim-lua/popup.nvim" }
    add { "nvim-lua/plenary.nvim" }

    -- misc
    add { "monaqa/dial.nvim", hook_after = config.dial }
end)

for _, name in ipairs(vim.fn["jetpack#names"]()) do
    if not util.to_bool(vim.fn["jetpack#tap"](name)) then
        vim.fn["jetpack#sync"]()
        return false
    end
end

for _, callback in ipairs(callbacks) do
    callback()
end

return true
