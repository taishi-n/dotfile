return vim.tbl_extend(
    "force",
    require "plugins.tex",
    require "plugins.editing",
    require "plugins.git",
    require "plugins.lsp",
    require "plugins.tree_sitter",
    require "plugins.ui"
)
