set nocompatible
filetype plugin indent on
syntax on

set backspace=indent,eol,start

set autoindent
set cindent

set expandtab
set smarttab
set tabstop=4
set shiftwidth=4

set ignorecase
set smartcase

set incsearch
set hlsearch

set modeline
set modelines=10

" Colors
set background=dark
colorscheme solarized

" Columns
2mat ErrorMsg '\%81v.'

" Filetypes
autocmd BufNewFile,BufRead *.json set ft=javascript
autocmd BufNewFile,BufRead *.md set ft=markdown

autocmd FileType ruby setlocal ts=2 sw=2 expandtab
autocmd FileType eruby setlocal ts=2 sw=2 expandtab
autocmd FileType json setlocal ts=2 sw=2 expandtab
autocmd FileType yaml setlocal ts=2 sw=2 expandtab
