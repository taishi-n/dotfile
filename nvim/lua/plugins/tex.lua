local M = {}
local util = require "utils.util"

local function setup_tex_buffer(buf)
    vim.bo[buf].omnifunc = "vimtex#complete#omnifunc"

    vim.keymap.set(
        "n",
        "<LocalLeader>cb",
        function()
            require("telescope").extensions.bibtex.bibtex()
        end,
        { buffer = buf, desc = "Search bibliography entries" }
    )
end

function M.vimtex()
    vim.g.tex_flavor = "latex"
    vim.g.vimtex_view_method = "sioyek"
    vim.g.vimtex_view_sioyek_exe = "sioyek"
    vim.g.vimtex_compiler_method = "latexmk"
    local latexindent_settings = vim.fn.expand "~/.config/latexindent/settings.yaml"
    vim.g.vimtex_compiler_latexmk = {
        executable = "latexmk",
        options = {
            "-pdf",
            "-interaction=nonstopmode",
            "-synctex=1",
        },
    }

    vim.lsp.config("texlab", {
        cmd = { "texlab" },
        filetypes = { "tex", "bib" },
        root_markers = {
            ".latexmkrc",
            "latexmkrc",
            ".git",
        },
        settings = {
            texlab = {
                forwardSearch = {
                    executable = "sioyek",
                    args = {
                        "--reuse-window",
                        "--forward-search-file",
                        "%f",
                        "--forward-search-line",
                        "%l",
                        "%p",
                    },
                },
                latexFormatter = "latexindent",
                latexindent = {
                    ["local"] = latexindent_settings,
                },
            },
        },
    })
    vim.lsp.enable "texlab"

    util.autocmd_vimrc { "FileType" } {
        pattern = { "tex", "bib" },
        callback = function(meta)
            setup_tex_buffer(meta.buf)
        end,
    }

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.tbl_contains({ "tex", "bib" }, vim.bo[buf].filetype) then
            setup_tex_buffer(buf)
        end
    end
end

return M
