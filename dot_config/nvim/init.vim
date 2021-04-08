call plug#begin('~/.local/share/nvim/plugged')
    Plug 'morhetz/gruvbox'
    Plug 'itchyny/lightline.vim'
    Plug 'preservim/nerdtree'
    Plug 'luochen1990/rainbow'
    Plug 'chase/vim-ansible-yaml'
    Plug 'junegunn/fzf.vim'
    Plug 'HerringtonDarkholme/yats.vim' " TypeScipt syntax
    Plug 'airblade/vim-gitgutter'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'tpope/vim-commentary'
    Plug 'ron89/thesaurus_query.vim'
    Plug 'janko/vim-test'
    Plug 'rhysd/git-messenger.vim'
    Plug 'mbbill/undotree'
    Plug 'dyng/ctrlsf.vim'
    Plug 'rhysd/vim-grammarous'
    Plug 'airblade/vim-rooter'
    Plug 'alvan/vim-closetag'
    Plug 'ntpeters/vim-better-whitespace'
call plug#end()

set background=dark
colorscheme gruvbox
let g:gruvbox_hls_cursor="red"

syntax on

let mapleader=' '

set re=0
set updatetime=300
set cmdheight=2
set shortmess+=c
set signcolumn=yes
set backspace=indent,eol,start
set hidden
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
set showtabline=2
set expandtab
set smartcase
set ignorecase
set noshowmode

" allow using the mouse
set mouse=a
" always show statusline
set laststatus=2
" show invisible characters
set list
" som alternatives: tab:▸\,eol:¬
set listchars=tab:\|\ ,trail:…

vnoremap < <gv
vnoremap > >gv

nnoremap <M-j>  :resize -2<CR>
nnoremap <M-k>  :resize +2<CR>
nnoremap <M-h>  :vertical resize -2<CR>
nnoremap <M-l>  :vertical resize +2<CR>

map ZW :w<CR>

" undotree
let g:undotree_WindowLayout = 2
let g:undotree_SetFocusWhenToggle = 1
nnoremap <leader>u :UndotreeToggle<cr>

" spelling
autocmd BufRead,BufNewFile *.md setlocal spell
autocmd BufRead,BufNewFile *.txt setlocal spell
set complete+=kspell
autocmd FileType gitcommit setlocal spell

" test
nmap <silent> <Leader>rt :TestNearest<CR>

" Use system clipboard
map <Leader>p "+p
map <Leader>P "+P
map <Leader>]p "+]p
map <Leader>]P "+]P
map <Leader>y "+y
vmap <Leader>y "+y
map <Leader>d "+d
vmap <Leader>d "+d

" FZF
let g:fzf_layout = { 'window': 'let g:launching_fzf = 1 | keepalt topleft enew' }
nnoremap <silent> <Leader>N :Files<CR>
nnoremap <silent> <Leader>o :Buffers<CR>
nnoremap <silent> <Leader>n :GFiles --cached --others --exclude-standard<CR>
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }

" CtrlSF

nnoremap <Leader>f :CtrlSF 

let g:ctrlsf_auto_preview = 1
let g:ctrlsf_auto_focus = {
  \ "at": "start",
  \ }
let g:ctrlsf_mapping = {
    \ "next": "n",
    \ "prev": "N",
    \ }

" Nerdtree

map <Leader>e :NERDTreeToggleVCS<CR>
map <Leader>E :NERDTreeToggle<CR>
" close if only window
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

autocmd FileType nerdtree let t:nerdtree_winnr = bufwinnr('%')
autocmd BufWinEnter * call PreventBuffersInNERDTree()

function! PreventBuffersInNERDTree()
  if bufname('#') =~ 'NERD_tree' && bufname('%') !~ 'NERD_tree'
    \ && exists('t:nerdtree_winnr') && bufwinnr('%') == t:nerdtree_winnr
    \ && &buftype == '' && !exists('g:launching_fzf')
    let bufnum = bufnr('%')
    close
    exe 'b ' . bufnum
  endif
  if exists('g:launching_fzf') | unlet g:launching_fzf | endif
endfunction


let g:rainbow_active = 1

" git messenger
let g:git_messenger_no_default_mappings = v:true
let g:git_messenger_always_into_popup = v:true
nmap <Leader>gb <Plug>(git-messenger)

" lightline

let g:lightline = {
\ 'colorscheme': 'gruvbox',
\ 'active': {
\   'left':   [ [ 'mode', 'paste' ], [  'readonly', 'filename' ] ],
\   'right': [ [ 'lineinfo' ], ['percent'], ['cocstatus', 'diagnostic'] ],
\ },
\ 'tab': {
\   'active': [ 'tabnum', 'cwd', 'filename', 'modified' ],
\   'inactive': [ 'tabnum', 'cwd', 'filename', 'modified' ]
\  },
\ 'component': {
\   'tagbar': '%{tagbar#currenttag("[%s]", "")}',
\  },
\ 'component_function': {
\   'cocstatus': 'LightlineCocStatus',
\   'filename': 'LightlineFilename',
\ },
\ 'component_expand': {
\   'diagnostic': 'LightlineDiagnostic',
\ },
\ 'component_type': {
\   'diagnostic': 'error',
\ },
\ }

function! LightlineFilename()
  return expand('%:t') !=# '' ? (expand('%') . (&modifiable && &modified ? '*' : '')) : '[No Name]'
endfunction

function! LightlineDiagnostic() abort
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info) | return '' | endif
  let msgs = []
  if get(info, 'error', 0)
    call add(msgs, 'E' . info['error'])
  endif
  if get(info, 'warning', 0)
    call add(msgs, 'W' . info['warning'])
  endif
  return join(msgs, ' ')
endfunction

function! LightlineCocStatus() abort
  return get(g:, 'coc_status', '')
endfunction

" CoC

inoremap <silent><expr> <c-space> coc#refresh()

if has('patch8.1.1068')
  " Use `complete_info` if your (Neo)Vim version supports it.
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

inoremap <silent><expr> <TAB>
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ pumvisible() ? coc#_select_confirm() :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
nnoremap <silent> <Leader>h :call <SID>show_documentation()<CR>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gD <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gu <Plug>(coc-references)
nmap <silent> gb <C-o>
nmap <silent> gf <C-i>
nnoremap <silent> gm  :<C-u>CocList outline<cr>
nnoremap <silent> gM  :<C-u>CocList -I symbols<cr>

nmap <silent> gE <Plug>(coc-diagnostic-prev)
nmap <silent> ge <Plug>(coc-diagnostic-next)
nmap <Leader>af :call CocAction('format')<CR>

" Use auocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
nmap <leader>ar <Plug>(coc-rename)
nmap <leader>ai :call     CocAction('runCommand', 'editor.action.organizeImport')<CR>

function! s:cocActionsOpenFromSelected(type) abort
  execute 'CocCommand actions.open ' . a:type
endfunction
xmap <silent> <a-cr> :<C-u>execute 'CocCommand actions.open ' . visualmode()<CR>
nmap <silent> <a-cr> :<C-u>set operatorfunc=<SID>cocActionsOpenFromSelected<CR>g@<CR>

" https://github.com/morhetz/gruvbox/wiki/Usage
map  <silent> <F4> :call gruvbox#hls_toggle()<CR>
imap <silent> <F4> <ESC>:call gruvbox#hls_toggle()<CR>a
vmap <silent> <F4> <ESC>:call gruvbox#hls_toggle()<CR>gv

nnoremap <silent> <CR> :call gruvbox#hls_hide()<CR><CR>

nnoremap * :let @/ = ""<CR>:call gruvbox#hls_show()<CR>*
nnoremap / :let @/ = ""<CR>:call gruvbox#hls_show()<CR>/
nnoremap ? :let @/ = ""<CR>:call gruvbox#hls_show()<CR>?

let g:better_whitespace_enabled=1
