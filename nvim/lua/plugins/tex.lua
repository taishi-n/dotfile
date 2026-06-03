local M = {}

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
end

return M
