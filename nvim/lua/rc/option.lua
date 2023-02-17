-- §§1 表示設定
vim.cmd [[
    language messages en_US.UTF-8
]]

-- TODO: temporal
vim.cmd[[
    augroup texfile
       autocmd BufRead,BufNewFile *.tex set filetype=tex
       let md_to_latex  = "pandoc --from=markdown-auto_identifiers --to=beamer --wrap=preserve"
       autocmd Filetype tex let &formatprg=md_to_latex
    augroup END

    augroup bibfile
      autocmd BufRead,BufNewFile *.bib set filetype=bib
      autocmd Filetype bib let &formatprg="bibclean --max-width 180 -no-check-values"
    augroup END

    augroup pdfpc
      autocmd BufRead,BufNewFile *.pdfpc set filetype=pdfpc
      autocmd Filetype pdfpc let &formatprg="jq"
    augroup END
]]

vim.opt.belloff = "all"
vim.opt.lazyredraw = true
vim.opt.ttyfast = true
vim.opt.ambiwidth = "single"
vim.opt.wrap = true
-- vim.opt.colorcolumn = "80"
vim.opt.list = true
vim.opt.listchars = {
    tab = "▸▹┊",
    trail = "▫",
    extends = "❯",
    precedes = "❮",
}

vim.opt.scrolloff = 0
-- default は marker にしておく
vim.opt.foldmethod = "marker"
vim.opt.foldlevelstart = 99
-- あえて manual にしたときは、自動的に fold が保存されるようにしておく
vim.opt.viewoptions = {
    "folds",
}

vim.opt.matchpairs:append {
    "（:）",
    "「:」",
    "『:』",
    "【:】",
}

-- 下
vim.opt.showcmd = true
vim.opt.laststatus = 3

-- 左
vim.opt.number = true
vim.opt.foldcolumn = "0"
-- vim.opt.signcolumn = "yes:2"
vim.opt.signcolumn = "number"

-- misc
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.diffopt:append { "vertical", "algorithm:histogram" }

-- §§1 編集関係
vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.breakindent = true
vim.opt.smartindent = false
vim.opt.virtualedit = "block"
vim.opt.isfname = vim.opt.isfname - "="

vim.opt.backup = false
vim.opt.swapfile = false

vim.opt.autoread = true
vim.opt.confirm = true
vim.opt.modeline = true
vim.opt.modelines = 3

vim.opt.hidden = true
vim.opt.spelllang = { "en", "cjk" }
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.history = 10000

if vim.fn.has "persistent_undo" then
    vim.opt.undofile = true
end

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.wrapscan = true
vim.opt.hlsearch = true
vim.opt.inccommand = "split"

-- clipboard
vim.opt.clipboard:append{"unnamed"}
vim.opt.clipboard:append{"unnamedplus"}
