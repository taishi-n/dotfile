set number
set clipboard+=unnamed
set clipboard+=unnamedplus
set hlsearch
set ignorecase
set smartcase
set wrapscan
set incsearch
set inccommand=split
set fileencodings=utf-8,sjis,iso-2022-jp,euc-jp
set fileformats=unix,dos,mac
set ambiwidth=double
set wildmenu
set showcmd
set backspace=start,eol,indent
set matchpairs& matchpairs+=<:>
set synmaxcol=200
set termguicolors
set matchpairs+=「:」,『:』,（:）,【:】,《:》,〈:〉,［:］,‘:’,“:”

" Indent setting
set autoindent
set expandtab

" Shell Setting
if $SHELL =~ 'fish'
  set shell=/bin/sh
endif
