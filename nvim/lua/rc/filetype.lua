
-- vim:fdm=marker:fmr=§§,■■
local util = require "rc.util"
local obsidian = require "rc.obsidian"

-- §§1 SATySFi
util.autocmd_vimrc { "BufRead", "BufNewFile" } {
    pattern = "Satyristes",
    command = [[setfiletype lisp]],
}

util.autocmd_vimrc { "BufRead", "BufNewFile" } {
    pattern = {
        "*.saty",
        "*.satyh",
        "*.satyh-*",
        "*.satyg",
    },
    callback = function()
        if vim.fn.getline(1) == "%SATySFi v0.1.0" then
            vim.opt_local.filetype = "satysfi_v0_1_0"
        else
            vim.opt_local.filetype = "satysfi"
        end
    end,
}

-- Markdown
util.autocmd_vimrc { "BufRead", "BufNewFile" } {
    pattern = "*.md",
    callback = function()
        vim.opt.tabstop = 2
        vim.opt.softtabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.smartindent = true
    end,
}
