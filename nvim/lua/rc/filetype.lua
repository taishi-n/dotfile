-- vim:fdm=marker:fmr=§§,■■
local util = require "rc.util"

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

-- LaTeX
util.autocmd_vimrc { "BufRead", "BufNewFile" } {
    pattern = "*.tex",
    callback = function()
        vim.opt.tabstop = 2
        vim.opt.softtabstop = 2
        vim.opt.shiftwidth = 2
    end,
}
