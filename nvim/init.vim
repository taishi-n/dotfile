set number
set clipboard+=unnamed
set clipboard+=unnamedplus
set hlsearch
set ignorecase
set smartcase
set wrapscan
set incsearch
set inccommand=split
set encoding=utf-8
set fileencodings=utf-8,sjis,iso-2022-jp,euc-jp
set fileformats=unix,dos,mac
set wildmenu
set showcmd
set mouse=a
set backspace=start,eol,indent
set matchpairs& matchpairs+=<:>
set synmaxcol=200
scriptencoding utf-8
filetype on
highlight Search ctermbg=lightgreen ctermfg=black
nmap j gj
nmap k gk
vmap j gj
vmap k gk
imap jk <Esc>
imap kj <Esc>
nmap <silent> <Esc><Esc> :nohlsearch<CR>
nnoremap <Tab> %
vnoremap <Tab> %
nnoremap Y y$

function! ImInActivate()
  call system('fcitx-remote -c')
endfunction
inoremap <silent> <C-[> <ESC>:call ImInActivate()<CR>

" Deactivate SwapFile etc..
" set nowritebackup
" set noswapfile
" set nobackup


" Omni completion setting
filetype plugin on
set omnifunc=syntaxcomplete#Complete


" Shell Setting
if $SHELL =~ 'fish'
  set shell=/bin/sh
endif


" Indent setting
set tabstop=3
set shiftwidth=3
set autoindent
set expandtab


" Color setting
set t_Co=256
set background=light


" dein setting
if &compatible
 set nocompatible
endif
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim
if dein#load_state('~/.cache/dein')
 call dein#begin('~/.cache/dein')
 call dein#load_toml('~/.config/nvim/dein.toml', {'lazy': 0})
 call dein#load_toml('~/.config/nvim/dein_lazy.toml', {'lazy': 1})
 call dein#end()
 call dein#save_state()
endif
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif
let g:dein#auto_recache = 1


" Automatic Binary file reading
" vim -b -> xxd mode
augroup BinaryXXD
	autocmd!
	autocmd BufReadPre *.bin let &binary =1
	autocmd BufReadPost * if &binary | silent %!xxd -g 1
	autocmd BufReadPost * set ft=xxd | endif
	autocmd BufWritePre * if &binary | %!xxd -r | endif
	autocmd BufWritePost * if &binary | silent %!xxd -g 1
	autocmd BufWritePost * set nomod | endif
augroup END
"reference: http://d.hatena.ne.jp/rdera/20081022/1224682665


" FileType SETTINGS
augroup fileTypeIndent
	autocmd!
	autocmd BufNewFile,BufRead *.cpp setl tabstop=4 softtabstop=4 shiftwidth=4 smartindent
	autocmd BufNewFile,BufRead *.rb  setl tabstop=2 softtabstop=2 shiftwidth=2 smartindent
	autocmd BufNewFile,BufRead *.go  setl tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
	autocmd BufNewFile,BufRead *.tex setl tabstop=2 softtabstop=2 shiftwidth=2
augroup END


" Python SETTINGS
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

set statusline+=%#warningmsg#
set statusline^=%{coc#status()}
set statusline+=%*

let &cpo = s:cpo_save
unlet s:cpo_save

" tex setting
let g:tex_conceal=""
let g:vimtex_view_general_viewer = '/Applications/Skim.app/Contents/SharedSupport/displayline'
let g:vimtex_view_general_options = '@line @pdf @tex'

" deoplete のプレビューを自動で閉じる
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" deoplete のプレビューウインドウを出さない
set completeopt=menuone

" lightline setting
" let g:lightline = {
" \ 'mode_map': {
" \    '__' : '-',
" \    'n'  : 'N',
" \    'i'  : 'I',
" \    'R'  : 'R',
" \    'c'  : 'C',
" \    'v'  : 'V',
" \    'V'  : 'V',
" \    's'  : 'S',
" \    'S'  : 'S',
" \ },
" \ 'active': {
" \   'left': [ [ 'mode', 'paste' ],
" \             [ 'readonly', 'filename', 'modified' ],
" \             [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ] ],
" \   'right': [ ['coc'] ]
" \ },
" \ 'component_function': {
" \   'coc': 'coc#status'
" \ },
" \ }
