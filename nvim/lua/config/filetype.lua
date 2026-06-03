-- vim:fdm=marker:fmr=§§,■■
local util = require "utils.util"

vim.filetype.add {
    extension = {
        tex = "tex",
        bib = "bib",
    },
}

local function set_buffer_options(buf, opts)
    for key, value in pairs(opts) do
        vim.bo[buf][key] = value
    end
end

util.autocmd_vimrc { "FileType" } {
    pattern = "markdown",
    callback = function(meta)
        set_buffer_options(meta.buf, {
            tabstop = 2,
            softtabstop = 2,
            shiftwidth = 2,
            smartindent = true,
        })
    end,
}

util.autocmd_vimrc { "FileType" } {
    pattern = "tex",
    callback = function(meta)
        set_buffer_options(meta.buf, {
            tabstop = 2,
            softtabstop = 2,
            shiftwidth = 2,
        })
    end,
}

util.autocmd_vimrc { "FileType" } {
    pattern = "bib",
    callback = function(meta)
        vim.bo[meta.buf].formatprg = "bibclean --max-width 180 -no-check-values"
    end,
}
