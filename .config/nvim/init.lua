local keymap = vim.api.nvim_set_keymap
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local plugins = {
	"airblade/vim-rooter", -- change cwd to git root
	{
		"akinsho/bufferline.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup()
		end,
	},
	{ "tpope/vim-fugitive", cmd = "Git" }, -- Git commands
	{
		"numToStr/Comment.nvim",
		opts = {
			pre_hook = function()
				return vim.bo.commentstring
			end,
		},
	},
	{ "windwp/nvim-autopairs", opts = { check_ts = true } }, -- autoclose ()
	{ "kylechui/nvim-surround", config = true }, -- surround operations
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory" },
		keys = {
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", mode = "n", noremap = true },
			{ "<leader>gh", "<Esc><cmd>'<,'>DiffviewFileHistory<CR>", mode = "v", noremap = true },
		},
	},
	"christoomey/vim-tmux-navigator",
	{ -- startup tracking
		"dstein64/vim-startuptime",
		cmd = "StartupTime",
		init = function()
			vim.g.startuptime_tries = 10
		end,
	},
	{ -- format everything
		"stevearc/conform.nvim",
		keys = {
			{
				"<leader>af",
				function()
					require("conform").format({ lsp_fallback = true })
				end,
				noremap = true,
			},
		},
		opts = {
			formatters_by_ft = {
				rust = { "rustfmt" },
				go = { "goimports" },
				lua = { "stylua" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
			},
			formatters = { rustfmt = { prepend_args = { "--edition", "2021" } } },
		},
	},
	{ -- theme
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			vim.o.termguicolors = true
			require("gruvbox").setup({})
			vim.cmd([[colorscheme gruvbox]])
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = {
					theme = "gruvbox",
					icons_enabled = false,
					component_separators = { "|", "|" },
					section_separators = { "", "" },
					disabled_filetypes = {},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { { "filename", file_status = true, path = 1 } },
					lualine_c = {
						{
							"diagnostics",
							sources = { "nvim_diagnostic" },
							symbols = { error = "E", warn = "W", info = "I", hint = "H" },
						},
					},
					lualine_x = {
						function()
							local clients = {}
							for _, client in pairs(vim.lsp.get_clients()) do
								table.insert(clients, client.name)
							end
							return table.concat(clients, " ")
						end,
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				extensions = {},
			})
		end,
	},
	{ -- show git signs at the left side
		"lewis6991/gitsigns.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("gitsigns").setup({
				on_attach = function(bufnr)
					local function map(mode, lhs, rhs, opts)
						opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
						vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
					end

					-- Navigation
					map("n", "]c", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
					map("n", "[c", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })

					-- Actions
					map("n", "<leader>hs", ":Gitsigns stage_hunk<CR>")
					map("v", "<leader>hs", ":Gitsigns stage_hunk<CR>")
					map("n", "<leader>hr", ":Gitsigns reset_hunk<CR>")
					map("v", "<leader>hr", ":Gitsigns reset_hunk<CR>")
					map("n", "<leader>hS", "<cmd>Gitsigns stage_buffer<CR>")
					map("n", "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>")
					map("n", "<leader>hR", "<cmd>Gitsigns reset_buffer<CR>")
					map("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>")
					map("n", "<leader>hb", '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
					map("n", "<leader>tb", "<cmd>Gitsigns toggle_current_line_blame<CR>")
					map("n", "<leader>hd", "<cmd>Gitsigns diffthis<CR>")
					map("n", "<leader>hD", '<cmd>lua require"gitsigns".diffthis("~")<CR>')
					map("n", "<leader>td", "<cmd>Gitsigns toggle_deleted<CR>")

					-- Text object
					map("o", "ih", ":<C-U>Gitsigns select_hunk<CR>")
					map("x", "ih", ":<C-U>Gitsigns select_hunk<CR>")
				end,
			})
		end,
	}, -- navigation
	{
		"folke/snacks.nvim",
		lazy = false,
		keys = {
			{
				"<leader>f",
				function()
					Snacks.picker.grep()
				end,
				silent = true,
				noremap = true,
			},
			{
				"<leader>n",
				function()
					Snacks.picker.git_files()
				end,
				silent = true,
				noremap = true,
			},
			{
				"<leader>N",
				function()
					Snacks.picker.files()
				end,
				silent = true,
				noremap = true,
			},
			{
				"<leader>b",
				function()
					Snacks.picker.buffers()
				end,
				silent = true,
				noremap = true,
			},
			{
				"<leader>r",
				function()
					Snacks.picker.resume()
				end,
				silent = true,
				noremap = true,
			},
			{
				"<leader>go",
				function()
					Snacks.gitbrowse()
				end,
				desc = "Open in browser",
				mode = { "n", "v" },
			},
		},
		opts = {
			gitbrowse = { enabled = true },
			indent = { char = "│", scope = { enabled = false } },
			picker = {
				layout = {
					reverse = true,
					layout = {
						backdrop = false,
						row = -1,
						width = 0,
						height = 0.5,
						box = "vertical",
						border = "top",
						{ win = "preview", border = "bottom" },
						{ win = "list", border = "none", height = 0.6 },
						{ win = "input", height = 1, border = "top" },
					},
				},
				sources = { select = { layout = { layout = { preview = false } } } },
				win = { input = { keys = { ["<Esc>"] = { "close", mode = { "n", "i" } } } } },
			},
		},
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},
	{
		"MagicDuck/grug-far.nvim",
		cmd = "GrugFar",
		keys = { { "<leader>as", "<cmd>GrugFar<CR>", noremap = true } },
		opts = {},
	},
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		priority = 1000,
		config = function()
			require("tiny-inline-diagnostic").setup()
			vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
		end,
	},
	"b0o/schemastore.nvim",
	{ -- tree sitter
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		dependencies = {
			{ "windwp/nvim-ts-autotag", ft = { "html", "typescriptreact" } }, -- close html tags via treesitter
			{ "JoosepAlviste/nvim-ts-context-commentstring", ft = { "html", "typescriptreact" } },
		},
		config = function()
			require("nvim-treesitter").install({
				"bash",
				"diff",
				"dockerfile",
				"gitcommit",
				"git_rebase",
				"go",
				"gomod",
				"gosum",
				"ini",
				"java",
				"json",
				"kotlin",
				"lua",
				"markdown",
				"python",
				"tsx",
				"typescript",
				"xml",
				"yaml",
			})
		end,
	},
	{ -- show trailing whitespaces in red
		"ntpeters/vim-better-whitespace",
		init = function()
			vim.g.better_whitespace_enabled = 1
		end,
	},
	{ -- diagnostic list
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics<cr>", silent = true, noremap = true },
			{ "<leader>xl", "<cmd>Trouble loclist<cr>", silent = true, noremap = true },
			{ "<leader>xq", "<cmd>Trouble quickfix<cr>", silent = true, noremap = true },
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").prev({ skip_groups = true, jump = true })
					else
						vim.cmd.cprev()
					end
				end,
				desc = "Previous trouble/quickfix item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						vim.cmd.cnext()
					end
				end,
				desc = "Next trouble/quickfix item",
			},
		},
		opts = { keys = { j = "next", k = "prev" } },
	},
	{
		"kyazdani42/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = { { "<leader>e", ":NvimTreeFindFileToggle<CR>", silent = true, noremap = true } },
		config = function()
			require("nvim-tree").setup({
				view = { width = 44 },
				renderer = { icons = { show = { git = false, modified = false } } },
			})

			autocmd("BufEnter", {
				group = augroup("NvimTreeClose", { clear = true }),
				callback = function()
					local layout = vim.api.nvim_call_function("winlayout", {})
					if
						layout[1] == "leaf"
						and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree"
						and layout[3] == nil
					then
						vim.cmd("quit")
					end
				end,
			})
		end,
	},
	{ -- autocomplete
		"saghen/blink.cmp",
		version = "1.*",
		opts = {
			keymap = {
				preset = "none",
				["<Down>"] = { "select_next", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-Space>"] = { "show", "fallback" },
				["<CR>"] = { "accept", "fallback" },
			},
			signature = { enabled = true },
			completion = {
				list = { selection = { preselect = true, auto_insert = true } },
				documentation = { auto_show = true },
			},
			sources = { default = { "lsp", "path" } },
		},
	},
	"neovim/nvim-lspconfig",
	{ "j-hui/fidget.nvim", event = "LspAttach", opts = {} },
}

require("lazy").setup({ spec = plugins, install = { colorscheme = { "gruvbox" } }, checker = { enabled = false } })

-- LSP keybindings on attach
autocmd("LspAttach", {
	group = augroup("LspKeybindings", { clear = true }),
	callback = function(ev)
		local opts = { buffer = ev.buf, silent = true, noremap = true }
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", function()
			Snacks.picker.lsp_definitions()
		end, opts)
		vim.keymap.set("n", "gi", function()
			Snacks.picker.lsp_implementations()
		end, opts)
		vim.keymap.set("n", "gr", function()
			Snacks.picker.lsp_references()
		end, opts)
		vim.keymap.set("n", "gm", function()
			Snacks.picker.lsp_symbols()
		end, opts)
		vim.keymap.set("n", "gM", function()
			Snacks.picker.lsp_workspace_symbols()
		end, opts)
		vim.keymap.set("n", "<leader>ar", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ad", function()
			Snacks.picker.lsp_definitions()
		end, opts)
		vim.keymap.set("n", "<leader>aa", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "<leader>aF", vim.lsp.buf.format, opts)
		vim.keymap.set("n", "<leader>dl", function()
			vim.diagnostic.open_float({ bufnr = 0 })
		end, opts)
		vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, opts)
		vim.keymap.set("n", "<leader>dN", vim.diagnostic.goto_prev, opts)
	end,
})

-- LSP server configs (defaults from nvim-lspconfig, overrides only)
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.config("yamlls", {
	settings = {
		yaml = { schemaStore = { enable = false, url = "" }, schemas = require("schemastore").yaml.schemas() },
	},
})
vim.lsp.config(
	"jsonls",
	{ settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } } }
)

vim.lsp.enable({ "gopls", "rust_analyzer", "ts_ls", "jsonls", "yamlls", "zk", "marksman", "pyright" })

-- Enable treesitter highlighting for installed parsers
autocmd("FileType", {
	group = augroup("TreesitterHighlight", { clear = true }),
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

vim.o.shortmess = vim.o.shortmess .. "c"

-- Incremental live completion
vim.o.inccommand = "nosplit"

-- tabs
vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.o.confirm = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menu,menuone,noselect"

-- Map blankline
vim.o.list = true
vim.o.listchars = "tab:┊ ,trail:•,space:⋅"

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
vim.o.backspace = "indent,eol,start"

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
vim.o.undodir = vim.fn.expand("$HOME") .. "/.vimundo"

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 100
vim.wo.signcolumn = "yes"

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup("YankHighlight", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = "300" })
	end,
})

-- disable list
autocmd("FileType", { group = augroup("DisableList", { clear = true }), pattern = { "qf" }, command = "set nolist" })

-- restore view
autocmd("BufRead", {
	callback = function(opts)
		autocmd("BufWinEnter", {
			once = true,
			buffer = opts.buf,
			callback = function()
				local ft = vim.bo[opts.buf].filetype

				if ft:match("gitcommit") or ft:match("gitrebase") then
					return
				end

				local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
				if last_known_line > 1 and last_known_line <= vim.api.nvim_buf_line_count(opts.buf) then
					vim.api.nvim_feedkeys([[g`"]], "nx", false)
				end
			end,
		})
	end,
})

-- key mapping

keymap("n", "Y", "y$", { silent = true, noremap = true })
keymap("n", "ZW", ":w<CR>", { silent = true, noremap = true })
keymap("n", "<leader>p", '"+p', { noremap = true })
keymap("n", "<leader>P", '"+P', { noremap = true })
keymap("v", "<leader>p", '"+p', { noremap = true })
keymap("v", "<leader>P", '"+P', { noremap = true })
keymap("n", "<leader>y", '"+y', { noremap = true })
keymap("n", "<leader>d", '"+d', { noremap = true })
keymap("v", "<leader>y", '"+y', { silent = true, noremap = true })
keymap("v", "<leader>d", '"+d', { silent = true, noremap = true })
