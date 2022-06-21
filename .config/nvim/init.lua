keymap = vim.api.nvim_set_keymap

local install_path = vim.fn.stdpath('data') ..
                         '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    Packer_bootstrap = vim.fn.system({
        'git', 'clone', '--depth', '1',
        'https://github.com/wbthomason/packer.nvim', install_path
    })
end

vim.cmd([[
    augroup Packer
        autocmd!
        autocmd BufWritePost init.lua source ~/.config/nvim/init.lua
        autocmd BufWritePost init.lua PackerCompile
    augroup end
]], false)

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim' -- Package manager

    use 'airblade/vim-rooter' -- change cwd to git root
    use 'rhysd/vim-grammarous' -- languagetool spellcheck
    use { -- undo tree
        'mbbill/undotree',
        config = function()
            vim.g.undotree_WindowLayout = 2
            vim.g.undetree_SetFocusWhenToggle = 1
            keymap("n", "<leader>au", ':UndotreeToggle<CR>',
                   {silent = true, noremap = true})
        end
    }
    use 'tpope/vim-fugitive' -- Git commands in nvim
    use { -- format everything
        'sbdchd/neoformat',
        config = function()
            keymap("n", "<leader>af", ':Neoformat<CR> ', {noremap = true})
        end
    }

    use { -- theme
        'morhetz/gruvbox',
        config = function()
            if vim.fn.has('termguicolors') then
                vim.o.termguicolors = true
            end

            vim.cmd [[colorscheme gruvbox]]
        end
    }

    use { -- status line
        'nvim-lualine/lualine.nvim',
        requires = {'arkav/lualine-lsp-progress'},
        config = function()
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
                            sources = {'nvim_diagnostic'},
                            symbols = {
                                error = 'E',
                                warn = 'W',
                                info = 'I',
                                hint = 'H'
                            }
                        }, {
                            'lsp_progress',
                            color = {use = false},
                            display_components = {
                                {'title', 'percentage', 'message'}
                            }
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
        end
    }

    use { -- show spaces / tabs everywhere
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            require'indent_blankline'.setup {
                show_current_context = true,
                use_treesitter = true
            }
        end
    }

    use { -- show git signs at the left side
        'lewis6991/gitsigns.nvim',
        requires = {'nvim-lua/plenary.nvim'},
        config = function()
            require('gitsigns').setup({
                on_attach = function(bufnr)
                    local function map(mode, lhs, rhs, opts)
                        opts = vim.tbl_extend('force',
                                              {noremap = true, silent = true},
                                              opts or {})
                        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
                    end

                    -- Navigation
                    map('n', ']c',
                        "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'",
                        {expr = true})
                    map('n', '[c',
                        "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'",
                        {expr = true})

                    -- Actions
                    map('n', '<leader>hs', ':Gitsigns stage_hunk<CR>')
                    map('v', '<leader>hs', ':Gitsigns stage_hunk<CR>')
                    map('n', '<leader>hr', ':Gitsigns reset_hunk<CR>')
                    map('v', '<leader>hr', ':Gitsigns reset_hunk<CR>')
                    map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>')
                    map('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>')
                    map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>')
                    map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>')
                    map('n', '<leader>hb',
                        '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
                    map('n', '<leader>tb',
                        '<cmd>Gitsigns toggle_current_line_blame<CR>')
                    map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>')
                    map('n', '<leader>hD',
                        '<cmd>lua require"gitsigns".diffthis("~")<CR>')
                    map('n', '<leader>td', '<cmd>Gitsigns toggle_deleted<CR>')

                    -- Text object
                    map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                    map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                end
            })
        end
    }

    -- navigation
    use {
        'junegunn/fzf.vim',
        requires = {'junegunn/fzf'},
        config = function()
            vim.g.fzf_layout = {down = '50%'}
            keymap("n", "<leader>f", ':Rg<CR>', {silent = true, noremap = true})
            keymap("n", "<leader>n",
                   ':GFiles --cached --others --exclude-standar<CR>',
                   {silent = true, noremap = true})
            keymap("n", "<leader>N", ':Files<CR>',
                   {silent = true, noremap = true})
            keymap("n", "<leader>b", ':Buffers<CR>',
                   {silent = true, noremap = true})
        end
    }
    use 'christoomey/vim-tmux-navigator' -- move between tmux & vim windows with same shortcuts

    -- find string in whole project
    use {
        'dyng/ctrlsf.vim',
        config = function()
            vim.g.ctrlsf_auto_preview = 1
            vim.g.ctrlsf_auto_focus = {at = 'start'}
            vim.g.ctrlsf_mapping = {next = 'n', prev = 'N'}
            keymap("n", "<leader>as", ':CtrlSF ', {noremap = true})
        end
    }
    use {
        'kyazdani42/nvim-tree.lua',
        requires = {'kyazdani42/nvim-web-devicons'},
        config = function()
            local tree_cb = require'nvim-tree.config'.nvim_tree_callback
            require'nvim-tree'.setup {
                filters = {custom = {".git", "node_modules", ".cache"}},
                view = {
                    side = "left",
                    width = 30,
                    mappings = {
                        list = {
                            {
                                key = {"<CR>", "o", "<2-LeftMouse>"},
                                cb = tree_cb "edit"
                            },
                            {
                                key = {"<2-RightMouse>", "<C-]>"},
                                cb = tree_cb "cd"
                            }, {key = "<C-v>", cb = tree_cb "vsplit"},
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
                            {key = "R", cb = tree_cb "refresh"},
                            {key = "a", cb = tree_cb "create"},
                            {key = "d", cb = tree_cb "remove"},
                            {key = "r", cb = tree_cb "rename"},
                            {key = "<C-r>", cb = tree_cb "full_rename"},
                            {key = "x", cb = tree_cb "cut"},
                            {key = "c", cb = tree_cb "copy"},
                            {key = "p", cb = tree_cb "paste"},
                            {key = "y", cb = tree_cb "copy_name"},
                            {key = "Y", cb = tree_cb "copy_path"},
                            {key = "gy", cb = tree_cb "copy_absolute_path"},
                            {key = "[c", cb = tree_cb "prev_git_item"},
                            {key = "}c", cb = tree_cb "next_git_item"},
                            {key = "-", cb = tree_cb "dir_up"},
                            {key = "q", cb = tree_cb "close"},
                            {key = "g?", cb = tree_cb "toggle_help"}
                        }
                    }
                },
                renderer = {
                    icons = {show = {git = false, file = false, folder = true}}
                },
                update_focused_file = {enable = true}
            }

            vim.cmd [[
                autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif
            ]]
            keymap("n", "<leader>e", ':NvimTreeFindFileToggle<CR>',
                   {silent = true, noremap = true})
        end
    }
    use {'kevinhwang91/nvim-bqf', ft = 'qf'}

    -- typing stuff
    use 'tpope/vim-commentary' -- Code Comment stuff, f.ex gc
    use { -- show trailing whitespaces in red
        'ntpeters/vim-better-whitespace',
        config = function() vim.g.better_whitespace_enabled = 1 end
    }
    use 'windwp/nvim-autopairs' -- autoclose ()
    use 'tpope/vim-surround' -- surround operations
    use 'tpope/vim-unimpaired'
    use 'editorconfig/editorconfig-vim' -- use tabstop / tabwidth from .editorconfig
    use { -- autocomplete
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path',
            'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip'
        },
        config = function()
            require('nvim-autopairs').setup {check_ts = true}

            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require 'cmp'

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end
                },
                mapping = {
                    ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item(),
                                             {'i'}),
                    ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'i'}),
                    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4),
                                            {'i', 'c'}),
                    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4),
                                            {'i', 'c'}),
                    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(),
                                                {'i', 'c'}),
                    ['<CR>'] = cmp.mapping.confirm({select = true})
                },
                sources = cmp.config.sources({
                    {name = 'nvim_lsp'}, {name = 'path'}
                })
            })
            cmp.event:on('confirm_done',
                         cmp_autopairs.on_confirm_done({map_chrr = {tex = ''}}))
        end
    }

    use { -- lsp
        'neovim/nvim-lspconfig',
        requires = {
            'iamcco/diagnostic-languageserver', -- show inline diagnostics
            'creativenull/diagnosticls-configs-nvim',
            'simrat39/rust-tools.nvim', -- extra rust inline stuff
            'folke/lsp-colors.nvim', -- better lsp colors
            'ray-x/lsp_signature.nvim', -- lsp signature
            'gfanto/fzf-lsp.nvim', -- fzf lsp
            {
                -- omnisharp stuff
                -- Remove after https://github.com/OmniSharp/omnisharp-roslyn/issues/2238 is fixed
                'Hoffs/omnisharp-extended-lsp.nvim',
                disable = true,
                requires = {'nvim-telescope/telescope.nvim'}
            }
        },
        config = function()
            local nvim_lsp = require 'lspconfig'
            local on_attach = function(client, bufnr)
                local function buf_keymap(...)
                    vim.api.nvim_buf_set_keymap(bufnr, ...)
                end

                vim.api.nvim_buf_set_option(bufnr, 'omnifunc',
                                            'v:lua.vim.lsp.omnifunc')

                require'lsp_signature'.on_attach({
                    bind = true,
                    doc_lines = 0,
                    floating_window = true,
                    hint_enable = false,
                    handler_opts = {border = "none"},
                    extra_trigger_chars = {"(", ","}
                })

                buf_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', '<C-k>',
                           '<cmd>lua vim.lsp.buf.signature_help()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', 'gi',
                           '<cmd>lua vim.lsp.buf.implementation()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', 'gm',
                           '<cmd>lua vim.lsp.buf.document_symbol()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', 'gM',
                           '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', '<leader>ar',
                           '<cmd>lua vim.lsp.buf.rename()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', '<leader>ad',
                           '<cmd>lua vim.lsp.buf.definition()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', '<leader>aa',
                           '<cmd>lua vim.lsp.buf.code_action()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', '<leader>aF',
                           '<cmd>lua vim.lsp.buf.formatting()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', '<leader>dl',
                           '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', '<leader>dn',
                           '<cmd>lua vim.diagnostic.goto_next()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', '<leader>dN',
                           '<cmd>lua vim.diagnostic.goto_prev()<CR>',
                           {silent = true, noremap = true})
            end

            local eslint = require 'diagnosticls-configs.linters.eslint'
            require'diagnosticls-configs'.setup {
                ['typescript'] = {linter = eslint},
                ['typescriptreact'] = {linter = eslint}
            }
            require'diagnosticls-configs'.init {on_attach = on_attach}

            vim.lsp.handlers["textDocument/documentSymbol"] =
                require'fzf_lsp'.document_symbol_handler
            vim.lsp.handlers["textDocument/codeAction"] =
                require'fzf_lsp'.code_action_handler

            -- Enable the following language servers
            local servers = {
                'gopls', 'rust_analyzer', 'tsserver', 'jsonls', 'yamlls', 'zk'
            }
            local caps = vim.lsp.protocol.make_client_capabilities()
            caps = require('cmp_nvim_lsp').update_capabilities(caps)
            for _, lsp in ipairs(servers) do
                nvim_lsp[lsp].setup {
                    on_attach = on_attach,
                    capabilities = caps,
                    settings = {
                        yaml = {
                            schemas = {
                                ['http://json.schemastore.org/gitlab-ci.json'] = '*.gitlab-ci.*{yml,yaml}',
                                ['https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json'] = 'openapi.yaml'
                            }
                        }
                    }
                }
            end

            -- omnisharp garbage
            -- local omnisharp_bin = "/usr/bin/omnisharp"
            -- local pid = vim.fn.getpid()
            -- require'lspconfig'.omnisharp.setup {
            --     on_attach = on_attach,
            --     capabilities = caps,
            --     handlers = {
            --         ["textDocument/definition"] = require('omnisharp_extended').handler
            --     },
            --     cmd = {
            --         omnisharp_bin, "--languageserver", "--hostPID",
            --         tostring(pid)
            --     }
            -- }

            require'rust-tools'.setup({
                server = {on_attach = on_attach, capabilities = caps}
            })

        end
    }
    use { -- diagnostic list
        'folke/trouble.nvim',
        config = function()
            require'trouble'.setup {
                padding = false,
                indent_lines = false,
                icons = false,
                signs = {
                    error = "E",
                    warning = "W",
                    hint = "H",
                    information = "I",
                    other = "?"
                }
            }

            keymap('n', '<leader>da', ':TroubleToggle<CR>',
                   {silent = true, noremap = true})
        end
    }

    use {
        'mickael-menu/zk-nvim',
        config = function()
            require"zk".setup {
                picker = "fzf",
                lsp = {auto_attach = {enabled = false}}
            }
        end
    }

    use { -- tree sitter
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        requires = {
            'windwp/nvim-ts-autotag', -- close html tags via treesitter
            'nvim-treesitter/nvim-treesitter-refactor',
            'nvim-treesitter/nvim-treesitter-textobjects',
            'JoosepAlviste/nvim-ts-context-commentstring'
        },
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = "all",
                highlight = {enable = true},
                autotag = {enable = true},
                indent = {enable = false},
                context_commentstring = {enable = true},
                refactor = {highlight_definitions = {enable = true}},
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_incremental = ".",
                        scope_incremental = ";",
                        node_decremental = "g."
                    }
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ['af'] = '@function.outer',
                            ['if'] = '@function.inner',
                            ['ab'] = '@block.outer',
                            ['ib'] = '@block.inner',
                            ['ac'] = '@conditional.outer',
                            ['ic'] = '@conditional.inner',
                            ['al'] = '@loop.outer',
                            ['il'] = '@loop.inner'
                        }
                    },
                    swap = {
                        enable = true,
                        swap_next = {['<Leader><Right>'] = '@parameter.inner'},
                        swap_previous = {
                            ['<Leader><Left>'] = '@parameter.inner'
                        }
                    }
                }
            }
        end
    }

    -- cool but really slow
    -- use 'haringsrob/nvim_context_vt' -- show context on closing brackets
    -- use 'romgrk/nvim-treesitter-context' -- show method context
    if Packer_bootstrap then require'packer'.sync() end
end)

-- https://github.com/hrsh7th/nvim-compe#how-to-remove-pattern-not-found
vim.o.shortmess = vim.o.shortmess .. 'c'

-- Incremental live completion
vim.o.inccommand = "nosplit"

-- tabs
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- lua filetype
vim.g.do_filetype_lua = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menu,menuone,noselect"

-- Map blankline
vim.o.list = true;
vim.o.listchars = 'tab:┊ ,trail:•,space:⋅'

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

-- restore view

vim.api.nvim_exec([[
  augroup LoadView
    autocmd!
    autocmd BufWinLeave *.* mkview
    autocmd BufWinEnter *.* silent! loadview
  augroup end
]], false)

-- key mapping

keymap("n", "Y", 'y$', {silent = true, noremap = true})
keymap("n", "ZW", ':w<CR>', {silent = true, noremap = true})
keymap("n", "<leader>p", '"+p', {noremap = true})
keymap("n", "<leader>P", '"+P', {noremap = true})
keymap("v", "<leader>p", '"+p', {noremap = true})
keymap("v", "<leader>P", '"+P', {noremap = true})
keymap("n", "<leader>y", '"+y', {noremap = true})
keymap("n", "<leader>d", '"+d', {noremap = true})
keymap("v", "<leader>y", '"+y', {silent = true, noremap = true})
keymap("v", "<leader>d", '"+d', {silent = true, noremap = true})
