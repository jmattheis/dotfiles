-- Plugins
local execute = vim.api.nvim_command

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
    use 'morhetz/gruvbox' -- Theme
    use 'itchyny/lightline.vim' -- Statusbar
    use 'tpope/vim-commentary' -- Code Comment stuff, f.ex gc
    use 'airblade/vim-gitgutter' -- git diff in sign column
    use 'junegunn/fzf.vim' -- fuzzy finder
    use 'junegunn/fzf' -- fuzzy finder
    use 'neovim/nvim-lspconfig' -- lsp configs for builtin language server client
    use 'ojroques/nvim-lspfuzzy' -- fuzzy goto definition etc
    use 'nvim-lua/lsp-status.nvim' -- Show lsp status, used in Statusbar
    use 'hrsh7th/nvim-compe' -- Autocompletion
    use 'ntpeters/vim-better-whitespace' -- show trailing whitespaces in red
    use 'airblade/vim-rooter' -- change cwd to git root
    use 'luochen1990/rainbow' -- rainbow ()
    use 'christoomey/vim-tmux-navigator' -- move between tmux & vim windows with same shortcuts
    use 'rhysd/vim-grammarous' -- languagetool spellcheck
    use 'mbbill/undotree' -- undo tree
    use 'folke/which-key.nvim' -- keymapping
    use 'cohama/lexima.vim' -- auto close ()
    use 'ray-x/lsp_signature.nvim' -- show signature while typing method
    use 'tpope/vim-fugitive' -- Git commands in nvim
    use 'dyng/ctrlsf.vim' -- find string in whole project
    use 'tpope/vim-surround' -- surround operations
    use {'lambdalisue/fern.vim', requires = {'antoinemadec/FixCursorHold.nvim'}} -- file drawer
    use 'nvim-treesitter/nvim-treesitter'
    use 'sbdchd/neoformat'
    use 'Yggdroot/indentLine'
    use 'editorconfig/editorconfig-vim'
end)

-- https://github.com/hrsh7th/nvim-compe#how-to-remove-pattern-not-found
vim.o.shortmess = vim.o.shortmess .. 'c'

-- Incremental live completion
vim.o.inccommand = "nosplit"

-- tabs
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noinsert"

-- Map blankline
vim.o.list = true;
vim.o.listchars = 'tab:| ,trail:•'

-- Set highlight on search
vim.o.hlsearch = false
vim.o.incsearch = true

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
vim.cmd [[colorscheme gruvbox]]

-- Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', {noremap = true, silent = true})
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
local wk = require("which-key")

wk.register({
    Y = {'y$', 'yank till end of line'},
    ZW = {':w<CR>', "write file"},
    ['<leader>'] = {
        a = {
            u = {':UndotreeToggle<CR>', 'open undo tree'},
            s = {':CtrlSF ', 'find string in all files'},
            f = {':Neoformat<CR>', 'format'}
        },
        p = {'"+p', "paste from clipboard"},
        P = {'"+P', "paste from clipboard"},
        y = {'"+y', "yank to clipboard"},
        d = {'"+d', "delete to clipboard"},
        n = {
            ':GFiles --cached --others --exclude-standar<CR>', 'show git files'
        },
        N = {':Files<CR>', 'show files'},
        b = {':Buffers<CR>', 'show buffers'},
        e = {':Fern . -drawer -reveal=% -width=35 -toggle<CR>', 'show fern'}
    }
})
wk.register({
    ['<leader>'] = {
        y = {'"+y', "yank to clipboard"},
        d = {'"+d', "delete to clipboard"}
    }
}, {mode = 'v'})

wk.register({
    ['<C-Space>'] = {'<cmd>compe#complete()'},
    ['<CR>'] = {"compe#confirm(lexima#expand('<LT>CR>', 'i'))"},
    ['<C-e>'] = {"compe#close('<C-e>')"}
}, {mode = 'i'})

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

    source = {
        nvim_lsp = {priority = 1000},
        ultisnips = {priority = 800},
        path = true
    }
}

-- file drawer

vim.g['fern#disable_default_mappings'] = 1
vim.g['fern#disable_drawer_auto_quit'] = 1

function fern_init()
    wk.register({
        ['<CR>'] = {'<Plug>(fern-open-or-expand)', 'open or expand'},
        m = {'<Plug>(fern-action-mark:toggle)', 'toggle mark'},
        ['<leader>'] = {
            r = {'<Plug>(fern-action-rename)', 'move'},
            n = {'<Plug>(fern-action-new-path)', 'new path'},
            t = {'<Plug>(fern-action-hidden-toggle)', 'toggle hidden'},
            d = {'<Plug>(fern-action-remove)', 'delete'},
            v = {'<Plug>(fern-action-open:vsplit)', 'open vsplit'},
            h = {'<Plug>(fern-action-open:split)', 'open hsplit'},
            R = {'<Plug>(fern-action-reload)', 'reload'}
        }
    }, {buffer = 0})
end

vim.api.nvim_exec([[
    augroup FernEvents
        autocmd!
        autocmd FileType fern lua fern_init()
    augroup END
]], false)

-- noremap <silent> <Leader>d :Fern . -drawer -width=35 -toggle<CR><C-w>=

-- statusbar

local lsp_diagnostics = require('lsp-status/diagnostics')
local lsp_messages = require('lsp-status/messaging').messages

local function statusline_make_diagnostic(prefix, diagnostics_key)
    return function()
        local count = lsp_diagnostics(0)[diagnostics_key]
        if count and count > 0 then
            return prefix .. count
        else
            return ''
        end
    end
end
function statusline_lsp()
    local buf_messages = lsp_messages()
    local msgs = {}

    for _, msg in ipairs(buf_messages) do
        local contents
        if msg.progress then
            contents = msg.title
            if msg.message then
                contents = contents .. ' ' .. msg.message
            end

            -- this percentage format string escapes a percent sign once to show a percentage and one more
            -- time to prevent errors in vim statusline's because of it's treatment of % chars
            if msg.percentage then
                contents = contents ..
                               string.format(" (%.0f%%%%)", msg.percentage)
            end
        else
            contents = msg.content
        end

        table.insert(msgs, msg.name .. ': ' .. contents)
    end
    if #msgs == 0 then
        local clients = {}
        for _, client in pairs(vim.lsp.buf_get_clients()) do
            clients[#clients + 1] = client.name
        end
        return table.concat(clients, ' ')
    else
        return table.concat(msgs, '|')
    end
end

statusline_lsp_error = statusline_make_diagnostic('E', 'errors')
statusline_lsp_warn = statusline_make_diagnostic('W', 'warnings')
statusline_lsp_info = statusline_make_diagnostic('I', 'info')
statusline_lsp_hint = statusline_make_diagnostic('?', 'hints')

function statusline_filename()
    if vim.fn.expand('%:t') == '' then
        return '[No Name]'
    else
        return vim.fn.expand('%')
    end
end

vim.g.lightline = {
    colorscheme = 'gruvbox',
    active = {
        left = {
            {'mode', 'paste'}, {'gitbranch', 'readonly', 'filename', 'modified'}
        },
        right = {
            {'lineinfo'}, {'percent'},
            {'lsp_error', 'lsp_warn', 'lsp_info', 'lsp_hint', 'lsp'}
        }
    },
    component_function = {gitbranch = 'fugitive#head'},
    component_expand = {
        lsp_error = 'v:lua.statusline_lsp_error',
        lsp_warn = 'v:lua.statusline_lsp_warn',
        lsp_info = 'v:lua.statusline_lsp_info',
        lsp_hint = 'v:lua.statusline_lsp_hint',
        lsp_status = 'v:lua.lsp_status',
        lsp = 'v:lua.statusline_lsp',
        filename = 'v:lua.statusline_filename'
    },
    component_type = {
        lsp_error = 'error',
        lsp_warn = 'warning',
        lsp_info = 'info',
        lsp_hint = 'hint'
    }
}

vim.cmd 'au User LspDiagnosticsChanged call lightline#update()'
vim.cmd 'au User LspMessageUpdate call lightline#update()'
vim.cmd 'au User LspStatusUpdate call lightline#update()'

-- Workaround to get progress inside the statusbar, apparently LspStatusUpdate
-- doesn't always get called
local function timed_statusbar_update()
    vim.cmd 'call lightline#update()'
    vim.defer_fn(timed_statusbar_update, 200)
end
vim.defer_fn(timed_statusbar_update, 200)

-- LSP stuff

local lsp_status = require('lsp-status')
lsp_status.register_progress()

local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    require"lsp_signature".on_attach({
        fix_pos = true,
        hint_enable = false,
        handler_opts = {border = 'none', doc_lines = 0, floating_window = true}
    })
    lsp_status.on_attach(client)

    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_exec([[
            augroup lsp_document_highlight
                autocmd! * <buffer>
                highlight LspReferenceText cterm=bold ctermbg=DarkGray gui=bold
                highlight LspReferenceRead cterm=bold ctermbg=DarkGray gui=bold
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
                autocmd CursorMovedI <buffer> lua vim.lsp.buf.clear_references()
            augroup END
        ]], false)
    end

    wk.register({
        K = {'<cmd>lua vim.lsp.buf.hover()<CR>', 'show documentation'},
        ['<C-k>'] = {
            '<cmd>lua vim.lsp.buf.signature_help()<CR>', 'show signature'
        },
        g = {
            name = 'go',
            D = {'<cmd>lua vim.lsp.buf.declaration()<CR>', 'goto declaration'},
            d = {'<cmd>lua vim.lsp.buf.definition()<CR>', 'goto definition'},
            i = {
                '<cmd>lua vim.lsp.buf.implementation()<CR>',
                'goto implementation'
            },
            r = {'<cmd>lua vim.lsp.buf.references()<CR>', 'goto references'},
            m = {'<cmd>lua vim.lsp.buf.document_symbol()<CR>', 'goto symbol'},
            M = {
                '<cmd>lua vim.lsp.buf.workspace_symbol("")<CR>',
                'goto workspace symbol'
            }
        },
        ['<leader>'] = {
            a = {
                r = {'<cmd>lua vim.lsp.buf.rename()<CR>', 'do rename'},
                a = {
                    '<cmd>lua vim.lsp.buf.code_action()<CR>',
                    'show code actions'
                },
                F = {'<cmd>lua vim.lsp.buf.formatting()<CR>', 'format'}
            },
            d = {
                name = 'diagnostic',
                l = {
                    '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',
                    'for line'
                },
                n = {'<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', 'goto next'},
                N = {
                    '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>',
                    'goto previous'
                },
                a = {'<cmd>LspDiagnostics 0<CR>', 'show all'}
            }
        }
    }, {buffer = bufnr})
end

require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained",
    highlight = {enable = true}
}

-- Enable the following language servers
local servers = {'gopls', 'rust_analyzer', 'tsserver'}
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = on_attach,
        capabilities = lsp_status.capabilities
    }
end

vim.g.fzf_layout = {down = '50%'}
require('lspfuzzy').setup {fzf_preview = {right = '50%'}}
