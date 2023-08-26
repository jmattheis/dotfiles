local keymap = vim.api.nvim_set_keymap
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", -- latest stable release
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Remap space as leader key
keymap('', '<Space>', '<Nop>', {noremap = true, silent = true})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local plugins = {
    'airblade/vim-rooter', -- change cwd to git root
    {'tpope/vim-fugitive', cmd = "Git"}, -- Git commands
    'tpope/vim-commentary', -- Code Comment stuff, f.ex gc
    'windwp/nvim-autopairs', -- autoclose ()
    'tpope/vim-surround', -- surround operations
    'editorconfig/editorconfig-vim', -- use tabstop / tabwidth from .editorconfig
    {'sindrets/diffview.nvim', cmd = {"DiffviewOpen", "DiffviewFileHistory"}}, -- file history
    'christoomey/vim-tmux-navigator', { -- undo tree
        'mbbill/undotree',
        keys = {
            {"<leader>au", ":UndotreeToggle<CR>", silent = true, noremap = true}
        },
        init = function()
            vim.g.undotree_WindowLayout = 2
            vim.g.undetree_SetFocusWhenToggle = 1
        end
    }, { -- startup tracking
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
        init = function() vim.g.startuptime_tries = 10 end
    }, { -- format everything
        'sbdchd/neoformat',
        keys = {{"<leader>af", ":Neoformat<CR>", noremap = true}},
        config = function()
            vim.g.neoformat_rust_rustfmt = {
                exe = 'rustfmt',
                args = {'--edition 2021'},
                stdin = 1
            }
        end
    }, { -- theme
        'morhetz/gruvbox',
        config = function()
            if vim.fn.has('termguicolors') then
                vim.o.termguicolors = true
            end

            vim.cmd [[colorscheme gruvbox]]
        end
    }, --
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {'arkav/lualine-lsp-progress'},
        config = function()
            require'lualine'.setup {
                options = {
                    theme = "gruvbox",
                    icons_enabled = false,
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
    }, { -- show spaces / tabs everywhere
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            require'indent_blankline'.setup {
                show_current_context = true,
                use_treesitter = true
            }
        end
    }, { -- show git signs at the left side
        'lewis6991/gitsigns.nvim',
        dependencies = {'nvim-lua/plenary.nvim'},
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
    }, -- navigation
    {
        'junegunn/fzf.vim',
        lazy = false,
        keys = {
            {"<leader>f", ":Rg<CR>", silent = true, noremap = true}, {
                "<leader>n",
                ':GFiles --cached --others --exclude-standar<CR>',
                silent = true,
                noremap = true
            }, {"<leader>N", ':Files<CR>', silent = true, noremap = true},
            {"<leader>b", ':Buffers<CR>', silent = true, noremap = true}
        },
        dependencies = {'junegunn/fzf'},
        init = function() vim.g.fzf_layout = {down = '35%'} end
    }, -- find string in whole project
    {
        'dyng/ctrlsf.vim',
        keys = {{"<leader>as", ":CtrlSF", noremap = true}},
        init = function()
            vim.g.ctrlsf_auto_preview = 1
            vim.g.ctrlsf_auto_focus = {at = 'start'}
            vim.g.ctrlsf_mapping = {next = 'n', prev = 'N'}
        end
    }, { -- tree sitter
        'nvim-treesitter/nvim-treesitter',
        lazy = true,
        build = ':TSUpdate',
        dependencies = {
            {'windwp/nvim-ts-autotag', ft = {"html", "tsx"}}, -- close html tags via treesitter
            'nvim-treesitter/nvim-treesitter-refactor',
            'nvim-treesitter/nvim-treesitter-textobjects',
            {
                'JoosepAlviste/nvim-ts-context-commentstring',
                ft = {"html", "tsx"}
            }
        },
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = {
                    "markdown", "go", "lua", "yaml", "json", "java",
                    "typescript", "bash", "diff", "dockerfile", "gitcommit",
                    "git_rebase", "gomod", "gosum", "ini", "kotlin", "sql",
                    "tsx", "xml"
                },
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
    }, {'kevinhwang91/nvim-bqf', ft = 'qf'},

    { -- show trailing whitespaces in red
        'ntpeters/vim-better-whitespace',
        init = function() vim.g.better_whitespace_enabled = 1 end
    }, { -- diagnostic list
        'folke/trouble.nvim',
        keys = {
            {"<leader>da", ":TroubleToggle<CR>", silent = true, noremap = true}
        },
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
        end
    }, {
        'kyazdani42/nvim-tree.lua',
        dependencies = {'kyazdani42/nvim-web-devicons'},
        keys = {
            {
                "<leader>e",
                ":NvimTreeFindFileToggle<CR>",
                silent = true,
                noremap = true
            }
        },
        config = function()
            require("nvim-tree").setup({
                renderer = {icons = {show = {git = false, modified = false}}}
            })

            autocmd("BufEnter", {
                group = augroup("NvimTreeClose", {clear = true}),
                callback = function()
                    local layout = vim.api.nvim_call_function("winlayout", {})
                    if layout[1] == "leaf" and
                        vim.api
                            .nvim_buf_get_option(
                            vim.api.nvim_win_get_buf(layout[2]), "filetype") ==
                        "NvimTree" and layout[3] == nil then
                        vim.cmd("quit")
                    end
                end
            })
        end
    }, { -- autocomplete
        'hrsh7th/nvim-cmp',
        event = "InsertEnter",
        dependencies = {
            'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lsp-signature-help', 'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip'
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
                    {name = 'nvim_lsp'}, {name = 'path'},
                    {name = 'nvim_lsp_signature_help'}
                })
            })
            cmp.event:on('confirm_done',
                         cmp_autopairs.on_confirm_done({map_chrr = {tex = ''}}))
        end
    }, { -- lsp
        'neovim/nvim-lspconfig',
        ft = {"js", "ts", "tsx", "go", "rs", "markdown"},
        dependencies = {
            'iamcco/diagnostic-languageserver', -- show inline diagnostics
            'creativenull/diagnosticls-configs-nvim',
            'simrat39/rust-tools.nvim', -- extra rust inline stuff
            'folke/lsp-colors.nvim', -- better lsp colors
            'gfanto/fzf-lsp.nvim' -- fzf lsp
            -- {
            -- omnisharp stuff
            -- Remove after https://github.com/OmniSharp/omnisharp-roslyn/issues/2238 is fixed
            --   'Hoffs/omnisharp-extended-lsp.nvim',
            --  disable = true,
            -- requires = {'nvim-telescope/telescope.nvim'}
            -- }
        },
        config = function()
            local nvim_lsp = require 'lspconfig'
            local on_attach = function(client, bufnr)
                local function buf_keymap(...)
                    vim.api.nvim_buf_set_keymap(bufnr, ...)
                end

                vim.api.nvim_buf_set_option(bufnr, 'omnifunc',
                                            'v:lua.vim.lsp.omnifunc')
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
                buf_keymap('n', 'gm', ':DocumentSymbols<CR>',
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
                buf_keymap('n', '<leader>aa', ':CodeActions<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', '<leader>aF',
                           '<cmd>lua vim.lsp.buf.formatting()<CR>',
                           {silent = true, noremap = true})
                buf_keymap('n', '<leader>dl',
                           '<cmd>lua vim.diagnostic.open_float({bufno = 0})<CR>',
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

            -- Enable the following language servers
            local servers = {
                'gopls', 'rust_analyzer', 'tsserver', 'jsonls', 'yamlls', 'zk',
                "marksman"
            }
            local caps = require('cmp_nvim_lsp').default_capabilities()
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
}

local opts = {}
require("lazy").setup(plugins, opts)

-- https://github.com/hrsh7th/nvim-compe#how-to-remove-pattern-not-found
vim.o.shortmess = vim.o.shortmess .. 'c'

-- Incremental live completion
vim.o.inccommand = "nosplit"

-- tabs
vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.o.confirm = true

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

-- Highlight on yank
autocmd('TextYankPost', {
    group = augroup('YankHighlight', {clear = true}),
    callback = function()
        vim.highlight.on_yank({higroup = 'IncSearch', timeout = '300'})
    end
})

-- restore view

autocmd('BufRead', {
    callback = function(opts)
        autocmd('BufWinEnter', {
            once = true,
            buffer = opts.buf,
            callback = function()
                local ft = vim.bo[opts.buf].filetype
                local last_known_line =
                    vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
                if not (ft:match('commit') and ft:match('rebase')) and
                    last_known_line > 1 and last_known_line <=
                    vim.api.nvim_buf_line_count(opts.buf) then
                    vim.api.nvim_feedkeys([[g`"]], 'nx', false)
                end
            end
        })
    end
})

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
