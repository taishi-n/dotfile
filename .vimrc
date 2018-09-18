" Basic Settings
set encoding=utf-8
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
set fileformats=unix,dos,mac
syntax on
set number
set autoindent
set wildmenu
set showcmd
set title
set expandtab
"set cursorline
filetype on
set hlsearch
set mouse=a
set clipboard+=unnamed
set backspace=start,eol,indent
set matchpairs& matchpairs+=<:>
set synmaxcol=200
scriptencoding utf-8
"colorscheme solarized
highlight Search ctermbg=82 ctermfg=18

" Omni completion setting
filetype plugin on
set omnifunc=syntaxcomplete#Complete

" Deactivate SwapFile etc..
set nowritebackup
set noswapfile
set nobackup

" Shell Setting
if $SHELL =~ 'fish'
  set shell=/bin/sh
endif

"不可視文字表示
set list
set listchars=tab:⇢-
hi SpecialKey cterm=NONE ctermfg=252

" Coloring tab
"autocmd VimEnter,Colorscheme * highlight SpecialKey cterm=NONE ctermfg=244 ctermbg=222


" Macro
inoremap jj <Esc>
nmap <silent> <Esc><Esc> :nohlsearch<CR>

"TABで対応ペアにジャンプ
nnoremap <Tab> %
vnoremap <Tab> %

"インデント関係==============================
set tabstop=3
set shiftwidth=3
"let g:indent_guides_enable_on_vim_startup = 1
"let g:indent_guides_auto_colors = 0
"let g:indent_guides_color_change_percent = 30
"let g:indent_guides_start_level=2
"let g:indent_guides_exclude_filetypes = ['help', 'nerdtree']
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#2e9afe ctermbg=gray
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#0040ff ctermbg=darkgray
"============================================

"Color setting=================================
set t_Co=256
set background=light
"==============================================

"NeoBundleSetting==============================
set runtimepath+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'
"NeoBundle 'scrooloose/nerdtree'
NeoBundle 'tpope/vim-endwise' " Ruby向けにendを自動挿入
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'tpope/vim-commentary'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'lervag/vimtex'

call neobundle#end()

filetype plugin indent on

NeoBundleCheck
"==============================================
" https://sites.google.com/site/fudist/Home/vim-nihongo-ban/-vimrc-sample

" snipett setting
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
let g:neosnippet#snippets_directory='~/.vim/bundle/neosnippet-snippets/mysnippets/'


""""""Automatic Binary file reading"""""""
""""""vim -b -> xxd mode""""""""""""""""""""""
augroup BinaryXXD
	autocmd!
	autocmd BufReadPre *.bin let &binary =1
	autocmd BufReadPost * if &binary | silent %!xxd -g 1
	autocmd BufReadPost * set ft=xxd | endif
	autocmd BufWritePre * if &binary | %!xxd -r | endif
	autocmd BufWritePost * if &binary | silent %!xxd -g 1
	autocmd BufWritePost * set nomod | endif
augroup END
"reference:http://d.hatena.ne.jp/rdera/20081022/1224682665


"=========================
"===FileType SETTINGS
"=========================
augroup fileTypeIndent
	autocmd!
	autocmd BufNewFile,BufRead *.py  setl tabstop=4 softtabstop=4 shiftwidth=4 commentstring=#%s
	autocmd BufNewFile,BufRead *.rb  setl tabstop=2 softtabstop=2 shiftwidth=2
" 	autocmd BufNewFile,BufRead *.tex setl tabstop=2 softtabstop=2 shiftwidth=2 smarttab 2 commentstring=%%s
augroup END

"=========================
"=====Python SETTINGS
"=========================
autocmd FileType python setl autoindent
autocmd FileType python setl smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
if version < 600
	syntax clear
elseif exists('b:current_after_syntax')
	finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn match pythonOperator "\(+\|=\|-\|\^\|\*\)"
syn match pythonDelimiter "\(,\|\.\|:\)"
syn keyword pythonSpecialWord self

hi link pythonSpecialWord    Special
hi link pythonDelimiter      Special

let b:current_after_syntax = 'python'

let &cpo = s:cpo_save
unlet s:cpo_save

"=========================
"=======Ruby SETTINGS
"=========================
" au FileType ruby setlocal makeprg=ruby\ -c\ %
" au FileType ruby setlocal errorformat=%m\ in\ %f\ on\ line\ %l

" vimtex setting
let g:tex_flavor = "latex"
let g:vimtex_compiler_latexmk = {
         \ 'callback' : 0,
         \ 'options' : [
         \   '-pdfdvi',
         \   '-latex=uplatex',
         \   '-synctex=1',
         \   '-halt-on-error',
         \   '-e "$dvipdf=q/dvipdfmx %O -o %D %S/;$bibtex=q/upbibtex/;$biber=q/biber --bblencoding=utf8 -u -U --output_safechars/;$makeindex=q/mendex %O -o %D %S/;"',
         \ ],
         \}
let g:latex_latexmk_enabled = 1
let g:vimtex_view_general_viewer
      \ = '/Applications/Preview.app/Contents/MacOS/Preview'
"let g:vimtex_view_general_options = '-ga'
"let g:latex_latexmk_options = '-pdfdvi -latex=uplatex -synctex=1 -halt-on-error'
let g:latex_view_method = 'general'
"let g:latex_view_general_viewer = 'open'
" vimtex for neocomplete
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
let g:neocomplete#sources#omni#input_patterns.tex = '\\ref{\s*[0-9A-Za-z_:]*'
let g:neocomplete#sources#omni#input_patterns.tex = '\\cite{\s*[0-9A-Za-z_:]*\|\\ref{\s*[0-9A-Za-z_:]*'
