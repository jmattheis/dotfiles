-- Plugins
local execute = vim.api.nvim_command
local keymap = vim.api.nvim_set_keymap

local install_path = vim.fn.stdpath('data') ..
                         '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    execute('!git clone https://github.com/wbthomason/packer.nvim ' ..
                install_path)
end

vim.api.nvim_exec([[
    augroup Packer
        autocmd!
        autocmd BufWritePost init.lua PackerCompile
    augroup end
]], false)

local use = require('packer').use
require('packer').startup(function()
    use 'wbthomason/packer.nvim' -- Package manager

    use 'airblade/vim-rooter' -- change cwd to git root
    use 'rhysd/vim-grammarous' -- languagetool spellcheck
    use 'mbbill/undotree' -- undo tree
    use 'tpope/vim-fugitive' -- Git commands in nvim
    use 'sbdchd/neoformat' -- format everything

    -- ui
    use 'morhetz/gruvbox' -- Theme
    use 'hoob3rt/lualine.nvim' -- status line
    use 'Yggdroot/indentLine' -- show spaces / tabs everywhere
    use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'}} -- git signs

    -- navigation
    use 'junegunn/fzf.vim' -- fuzzy finder
    use 'junegunn/fzf' -- fuzzy finder
    use 'christoomey/vim-tmux-navigator' -- move between tmux & vim windows with same shortcuts
    use 'dyng/ctrlsf.vim' -- find string in whole project
    use {'kyazdani42/nvim-tree.lua'} -- file explorer

    -- autocomplete / typing stuff
    use 'tpope/vim-commentary' -- Code Comment stuff, f.ex gc
    use 'hrsh7th/nvim-compe' -- Autocompletion
    use 'ntpeters/vim-better-whitespace' -- show trailing whitespaces in red
    use 'cohama/lexima.vim' -- auto close ()
    use 'tpope/vim-surround' -- surround operations
    use 'editorconfig/editorconfig-vim' -- use tabstop / tabwidth from .editorconfig

    -- lsp
    use 'neovim/nvim-lspconfig' -- lsp configs for builtin language server client
    use { -- show diagnostics, f.ex. eslint
        'iamcco/diagnostic-languageserver',
        requires = {'creativenull/diagnosticls-configs-nvim'}
    }
    use 'simrat39/rust-tools.nvim' -- additional rust analyzer tools, f.ex show types in method chain
    use 'ray-x/lsp_signature.nvim' -- show signature while typing method
    use 'gfanto/fzf-lsp.nvim' -- fzf lsp definitions etc
    use 'arkav/lualine-lsp-progress' -- lsp progress in statusline
    use 'folke/lsp-colors.nvim' -- better inline diagnostics

    -- tree sitter
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'} -- syntax tree parser
    use 'windwp/nvim-ts-autotag' -- close html tags via treesitter
    use 'JoosepAlviste/nvim-ts-context-commentstring'
    -- cool but really slow
    -- use 'haringsrob/nvim_context_vt' -- show context on closing brackets
    -- use 'romgrk/nvim-treesitter-context' -- show method context
end)

-- https://github.com/hrsh7th/nvim-compe#how-to-remove-pattern-not-found
vim.o.shortmess = vim.o.shortmess .. 'c'

-- Incremental live completion
vim.o.inccommand = "nosplit"

-- tabs
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- Map blankline
vim.o.list = true;
vim.o.listchars = 'tab:| ,trail:•'

-- Set highlight on search
vim.o.hlsearch = false
vim.o.incsearch = true

-- hide default mode
vim.o.showmode = false

-- Make line numbers default
vim.wo.number = true

-- Do not save when switching buffers
vim.o.hidden = true

-- Cooler backspace
vim.o.backspace = 'indent,eol,start'

-- Enable mouse mode
vim.o.mouse = "a"

-- Enable break indent
vim.o.breakindent = true

-- coller tabs
vim.o.expandtab = true

-- Save undo history
vim.o.undofile = true
vim.o.undolevels = 1000
vim.o.undoreload = 1000
vim.o.undodir = vim.fn.expand('$HOME') .. '/.vimundo'

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"

-- gruvbox masterrace
if vim.fn.has('termguicolors') then vim.o.termguicolors = true end

vim.cmd [[colorscheme gruvbox]]

-- Remap space as leader key
keymap('', '<Space>', '<Nop>', {noremap = true, silent = true})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Highlight on yank
vim.api.nvim_exec([[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]], false)

-- indentline

vim.g.indentLine_char = '┊'
vim.g.indentLine_enabled = 1
vim.g.indentLine_leadingSpaceEnabled = 1
vim.g.indentLine_leadingSpaceChar = '•'

-- ctrlsf
vim.g.ctrlsf_auto_preview = 1
vim.g.ctrlsf_auto_focus = {at = 'start'}
vim.g.ctrlsf_mapping = {next = 'n', prev = 'N'}

-- () auto close
vim.g.lexima_no_default_rules = true
vim.cmd 'call lexima#set_default_rules()'

-- key mapping

keymap("n", "Y", 'y$', {silent = true, noremap = true})
keymap("n", "ZW", ':w<CR>', {silent = true, noremap = true})
keymap("n", "<leader>f", ':Rg<CR>', {silent = true, noremap = true})
keymap("n", "<leader>au", ':UndotreeToggle<CR>', {silent = true, noremap = true})
keymap("n", "<leader>as", ':CtrlSF ', {noremap = true})
keymap("n", "<leader>af", ':Neoformat<CR> ', {noremap = true})
keymap("n", "<leader>p", '"+p', {noremap = true})
keymap("n", "<leader>P", '"+P', {noremap = true})
keymap("v", "<leader>p", '"+p', {noremap = true})
keymap("v", "<leader>P", '"+P', {noremap = true})
keymap("n", "<leader>y", '"+y', {noremap = true})
keymap("n", "<leader>d", '"+d', {noremap = true})
keymap("n", "<leader>n", ':GFiles --cached --others --exclude-standar<CR>',
       {silent = true, noremap = true})
keymap("n", "<leader>N", ':Files<CR>', {silent = true, noremap = true})
keymap("n", "<leader>b", ':Buffers<CR>', {silent = true, noremap = true})
keymap("n", "<leader>e", ':NvimTreeToggle<CR>', {silent = true, noremap = true})
keymap("v", "<leader>y", '"+y', {silent = true, noremap = true})
keymap("v", "<leader>d", '"+d', {silent = true, noremap = true})
keymap("i", "<C-Space>", "compe#complete()",
       {expr = true, silent = true, noremap = true})
keymap("i", "<CR>", "compe#confirm('<CR>')",
       {expr = true, silent = true, noremap = true})
keymap("i", "<C-e>", "compe#close('<C-e>')",
       {expr = true, silent = true, noremap = true})

-- luochen1990/rainbow
vim.g.rainbow_active = 1

-- ntpeters/vim-better-whitespace
vim.g.better_whitespace_enabled = 1

-- undo tree
vim.g.undotree_WindowLayout = 2
vim.g.undetree_SetFocusWhenToggle = 1

-- completion

require'compe'.setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = 'always',
    throttle_time = 80,
    source_timeout = 200,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = true,

    source = {nvim_lsp = {priority = 1000}, path = true}
}

-- file drawer

vim.g.nvim_tree_side = "left"
vim.g.nvim_tree_width = 30
vim.g.nvim_tree_ignore = {".git", "node_modules", ".cache"}
vim.g.nvim_tree_gitignore = 1
vim.g.nvim_tree_auto_ignore_ft = {"dashboard"} -- don't open tree on specific fiypes.
vim.g.nvim_tree_auto_open = 0
vim.g.nvim_tree_auto_close = 1
vim.g.nvim_tree_quit_on_open = 0 -- closes tree when file's opened
vim.g.nvim_tree_follow = 1
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_hide_dotfiles = 1
vim.g.nvim_tree_git_hl = 0
vim.g.nvim_tree_highlight_opened_files = 0
vim.g.nvim_tree_root_folder_modifier = table.concat {
    ":t:gs?$?/..", string.rep(" ", 1000), "?:gs?^??"
}
vim.g.nvim_tree_tab_open = 0
vim.g.nvim_tree_allow_resize = 1
vim.g.nvim_tree_add_trailing = 0 -- append a trailing slash to folder names
vim.g.nvim_tree_disable_netrw = 1
vim.g.nvim_tree_hijack_netrw = 0
vim.g.nvim_tree_update_cwd = 0
vim.g.nvim_tree_show_icons = {git = 0, folders = 1, files = 0}

local tree_cb = require'nvim-tree.config'.nvim_tree_callback
vim.g.nvim_tree_bindings = {
    {key = {"<CR>", "o", "<2-LeftMouse>"}, cb = tree_cb "edit"},
    {key = {"<2-RightMouse>", "<C-]>"}, cb = tree_cb "cd"},
    {key = "<C-v>", cb = tree_cb "vsplit"},
    {key = "<C-x>", cb = tree_cb "split"},
    {key = "<C-t>", cb = tree_cb "tabnew"},
    {key = "<", cb = tree_cb "prev_sibling"},
    {key = ">", cb = tree_cb "next_sibling"},
    {key = "P", cb = tree_cb "parent_node"},
    {key = "<BS>", cb = tree_cb "close_node"},
    {key = "<S-CR>", cb = tree_cb "close_node"},
    {key = "<Tab>", cb = tree_cb "preview"},
    {key = "K", cb = tree_cb "first_sibling"},
    {key = "J", cb = tree_cb "last_sibling"},
    {key = "I", cb = tree_cb "toggle_ignored"},
    {key = "H", cb = tree_cb "toggle_dotfiles"},
    {key = "R", cb = tree_cb "refresh"}, {key = "a", cb = tree_cb "create"},
    {key = "d", cb = tree_cb "remove"}, {key = "r", cb = tree_cb "rename"},
    {key = "<C-r>", cb = tree_cb "full_rename"},
    {key = "x", cb = tree_cb "cut"}, {key = "c", cb = tree_cb "copy"},
    {key = "p", cb = tree_cb "paste"}, {key = "y", cb = tree_cb "copy_name"},
    {key = "Y", cb = tree_cb "copy_path"},
    {key = "gy", cb = tree_cb "copy_absolute_path"},
    {key = "[c", cb = tree_cb "prev_git_item"},
    {key = "}c", cb = tree_cb "next_git_item"},
    {key = "-", cb = tree_cb "dir_up"}, {key = "q", cb = tree_cb "close"},
    {key = "g?", cb = tree_cb "toggle_help"}
}
vim.g.nvim_tree_icons = {
    folder = {
        default = "",
        open = "",
        empty = "",
        empty_open = "",
        symlink = "",
        symlink_open = ""
    }
}

-- gitsigns

require('gitsigns').setup()

-- statusbar

require'lualine'.setup {
    options = {
        icons_enabled = false,
        theme = 'gruvbox',
        component_separators = {'|', '|'},
        section_separators = {'', ''},
        disabled_filetypes = {}
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {{'filename', file_status = true, path = 1}},
        lualine_c = {
            {
                'diagnostics',
                sources = {'nvim_lsp'},
                symbols = {error = 'E', warn = 'W', info = 'I', hint = 'H'}
            }, {
                'lsp_progress',
                color = {use = false},
                display_components = {{'title', 'percentage', 'message'}}
            }
        },
        lualine_x = {
            function()
                local clients = {}
                for _, client in pairs(vim.lsp.buf_get_clients()) do
                    table.insert(clients, client.name)
                end
                return table.concat(clients, ' ')
            end
        },
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    extensions = {}
}

local nvim_lsp = require 'lspconfig'
local on_attach = function(client, bufnr)
    local function buf_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    require'lsp_signature'.on_attach({
        fix_pos = true,
        hint_enable = false,
        handler_opts = {border = 'none', doc_lines = 0, floating_window = true}
    })

    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_exec([[
            augroup lsp_document_highlight
                autocmd! * <buffer>
                highlight LspReferenceText cterm=bold ctermbg=DarkGray gui=bold guibg=#a89984 guifg=#282828
                highlight LspReferenceRead cterm=bold ctermbg=DarkGray gui=bold guibg=#a89984 guifg=#282828
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
                autocmd CursorMovedI <buffer> lua vim.lsp.buf.clear_references()
            augroup END
        ]], false)
    end

    buf_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>',
               {silent = true, noremap = true})
    buf_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>',
               {silent = true, noremap = true})
    buf_keymap('n', 'gD', ':Declarations<CR>', {silent = true, noremap = true})
    buf_keymap('n', 'gd', ':Definitions<CR>', {silent = true, noremap = true})
    buf_keymap('n', 'gi', ':Implementations<CR>',
               {silent = true, noremap = true})
    buf_keymap('n', 'gr', ':References<CR>', {silent = true, noremap = true})
    buf_keymap('n', 'gm', ':DocumentSymbols<CR>',
               {silent = true, noremap = true})
    buf_keymap('n', 'gM', ':WorkspaceSymbols<CR>',
               {silent = true, noremap = true})
    buf_keymap('n', '<leader>ar', '<cmd>lua vim.lsp.buf.rename()<CR>',
               {silent = true, noremap = true})
    buf_keymap('n', '<leader>aa', ':CodeActions<CR>',
               {silent = true, noremap = true})
    buf_keymap('n', '<leader>aF', '<cmd>lua vim.lsp.buf.formatting()<CR>',
               {silent = true, noremap = true})
    buf_keymap('n', '<leader>dl',
               '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',
               {silent = true, noremap = true})
    buf_keymap('n', '<leader>dn', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>',
               {silent = true, noremap = true})
    buf_keymap('n', '<leader>dN', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>',
               {silent = true, noremap = true})
    buf_keymap('n', '<leader>da', ':Diagnostics<CR>',
               {silent = true, noremap = true})
end

require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained",
    highlight = {enable = true},
    autotag = {enable = true},
    indent = {enable = true},
    context_commentstring = {enable = true},
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = ".",
            scope_incremental = ";",
            node_decremental = "g."
        }
    }
}
local eslint = require 'diagnosticls-configs.linters.eslint'
require'diagnosticls-configs'.setup {
    ['typescript'] = {linter = eslint},
    ['typescriptreact'] = {linter = eslint}
}
require'diagnosticls-configs'.init {on_attach = on_attach}

-- Enable the following language servers
local servers = {'gopls', 'rust_analyzer', 'tsserver', 'jsonls'}
for _, lsp in ipairs(servers) do
    local caps = vim.lsp.protocol.make_client_capabilities()
    caps.textDocument.completion.completionItem.snippetSupport = true
    caps.textDocument.completion.completionItem.resolveSupport = {
        properties = {'documentation', 'detail', 'additionalTextEdits'}
    }

    nvim_lsp[lsp].setup {on_attach = on_attach, capabilities = caps}
end
require'rust-tools'.setup({
    server = {on_attach = on_attach, capabilities = caps}
})

vim.g.fzf_layout = {down = '50%'}
