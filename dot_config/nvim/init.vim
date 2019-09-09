call plug#begin('~/.local/share/nvim/plugged')
    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug 'chase/vim-ansible-yaml'
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'lifepillar/vim-solarized8'
    Plug 'morhetz/gruvbox'
call plug#end()

set background=dark
colorscheme gruvbox
"colorscheme solarized8
let g:gruvbox_hls_cursor="red"

syntax on

let mapleader=' '

set backspace=indent,eol,start
set history=1000
set undofile
set undolevels=1000
set undoreload=1000
set undodir=$HOME/.vimundo
set ruler
set showcmd
set showmode
set incsearch
set hlsearch
set number
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set smartcase

" allow using the mouse
set mouse=a
" always show statusline
set laststatus=2
" show invisible characters
set list
" som alternatives: tab:▸\,eol:¬
set listchars=tab:\|\ ,trail:…

map <Leader>n :NERDTreeToggle<CR>
map <Leader>rf :NERDTreeFind<CR>

map <Leader>p "+p
map <Leader>P "+P
map <Leader>]p "+]p
map <Leader>]P "+]P
map <Leader>y "+y
vmap <Leader>y "+y
map <Leader>d "+d

map ZW :w<CR>
vmap <Leader>d "+d

" https://github.com/morhetz/gruvbox/wiki/Usage
map  <silent> <F4> :call gruvbox#hls_toggle()<CR>
imap <silent> <F4> <ESC>:call gruvbox#hls_toggle()<CR>a
vmap <silent> <F4> <ESC>:call gruvbox#hls_toggle()<CR>gv

nnoremap <silent> <CR> :call gruvbox#hls_hide()<CR><CR>

nnoremap * :let @/ = ""<CR>:call gruvbox#hls_show()<CR>*
nnoremap / :let @/ = ""<CR>:call gruvbox#hls_show()<CR>/
nnoremap ? :let @/ = ""<CR>:call gruvbox#hls_show()<CR>?
