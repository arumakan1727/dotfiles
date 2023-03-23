-- https://github.com/klen/nvim-config-local
require("config-local").setup {
	config_files = { ".nvim/local.vim", ".nvim/local.lua" },
	hashfile = vim.fn.stdpath("data") .. "/config-local",
	autocommands_create = true, -- Create autocommands (VimEnter, DirectoryChanged)
	commands_create = true, -- Create commands (ConfigSource, ConfigEdit, ConfigTrust, ConfigIgnore)
	silent = false, -- Disable plugin messages (Config loaded/ignored)
	lookup_parents = true,
}

-- https://github.com/preservim/vim-markdown
vim.g.vim_markdown_math = 1
vim.g.vim_markdown_frontmatter = 1
vim.g.vim_markdown_toml_frontmatter = 1
vim.g.vim_markdown_strikethrough = 1
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 0

do -- LSP
	-- プロジェクト固有の LSP 設定を json/yaml で設定可能に
	-- https://github.com/tamago324/nlsp-settings.nvim
	require("nlspsettings").setup {
		config_home = vim.fn.stdpath("config") .. "/nlsp-settings",
		local_settings_dir = ".nvim/nlsp-settings",
		local_settings_root_markers = { ".nvim", ".git" },
		loader = 'json',
		jsonls_append_default_schemas = true,
		nvim_notify = {
			enable = true,
			timeout = 5000,
		},
	}

	-- Note: lspconfig の設定の前に lsp-installer を setup しておく必要がある
	-- https://github.com/williamboman/nvim-lsp-installer
	require("nvim-lsp-installer").setup {}

	-- https://zenn.dev/monaqa/articles/2021-12-10-satysfi-language-server
	local configs = require("lspconfig.configs")
	local util = require("lspconfig.util")
	if not configs.satysfi_ls then
		configs.satysfi_ls = {
			default_config = {
				cmd = { 'satysfi-language-server' },
				filetypes = { 'satysfi' },
				root_dir = util.root_pattern('.git'),
				single_file_support = true,
			},
			docs = {
				description = [[
	https://github.com/monaqa/satysfi-language-server
	Language server for SATySFi. ]],
				default_config = {
					root_dir = [[root_pattern(".git")]],
				},
			},
		}
	end


	-- lspconfig の設定
	-- https://github.com/neovim/nvim-lspconfig#suggested-configuration
	local on_attach = function(_, bufnr)
		local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

		local opts = { noremap = true, silent = true }
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
		buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
		buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
		buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
		buf_set_keymap("n", "<Space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
		buf_set_keymap("n", "<Space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
		buf_set_keymap("n", "<Space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
		buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
		buf_set_keymap("n", "<Space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
		buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
		buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
	end
	local servers = {
		'bashls',
		'clangd',
		'cmake',
		'cssls',
		'dartls',
		'dockerls',
		'emmet_ls',
		'gopls',
		'hls',
		'html',
		'jdtls',
		'jsonls',
		'nimls',
		'ocamllsp',
		'phpactor',
		'pyright',
		'rust_analyzer',
		'satysfi_ls',
		'solargraph',
		'lua_ls',
		'tsserver',
		'vimls',
		'volar',
		'yamlls',
	}
	local custom_configs = {
		["clangd"] = {
			cmd = { 'clangd', '--background-index', '--enable-config', '--header-insertion=never' },
		},
		["emmet_ls"] = {
			filetypes = {
				'html', 'xml',
				'css', 'scss', 'sass', 'stylus',
				'javascriptreact', 'typescriptreact',
			}
		},
	}
	local capabilities = require("cmp_nvim_lsp").default_capabilities()
	local lspconfig = require("lspconfig")
	for _, lsp in pairs(servers) do
		local cfg = {
			autostart = true,
			on_attach = on_attach,
			capabilities = capabilities,
			flags = {
				debounce_text_changes = 200,
			},
			single_file_support = true,
		}
		if custom_configs[lsp] then
			cfg = vim.tbl_deep_extend("force", cfg, custom_configs[lsp])
		end
		lspconfig[lsp].setup(cfg)
	end

	-- https://github.com/j-hui/fidget.nvim
	require("fidget").setup()
end


-- Treesitter
do
	-- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
	require("nvim-treesitter.configs").setup {
		ensure_installed = "all",
		highlight = {
			enable = true,
			disable = { "yaml" },
			additional_vim_regex_highlighting = false,
		},
		indent = { enable = false, }, -- yati を使うので disable
		yati = { enable = true },
		context_commentstring = { enable = true },
		matchup = { enable = true },
		nvimGPS = { enable = true },
		autotag = { enable = true },
		textobjects = { -- syntax-aware textobjects
			select = {
				enable = true,
				disable = {},
				keymaps = {
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
					["ib"] = "@block.inner",
					["ab"] = "@block.outer",
					["ii"] = "@conditional.inner",
					["ai"] = "@conditional.outer",
					["il"] = "@loop.inner",
					["al"] = "@loop.outer",
					["ip"] = "@parameter.inner",
					["ap"] = "@parameter.outer",
					["iS"] = "@scopename.inner",
					["aS"] = "@statement.outer",
				},
			},
			swap = {
				enable = true,
				swap_next = { ["'>"] = "@parameter.inner" },
				swap_previous = { ["'<"] = "@parameter.inner" },
			},
			move = {
				enable = true,
				goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
				goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
				goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
				goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
			},
		},
	}

	vim.keymap.set('x', 'iu', ':lua require"treesitter-unit".select()<CR>', { noremap = true })
	vim.keymap.set('x', 'au', ':lua require"treesitter-unit".select(true)<CR>', { noremap = true })
	vim.keymap.set('o', 'iu', ':<c-u>lua require"treesitter-unit".select()<CR>', { noremap = true })
	vim.keymap.set('o', 'au', ':<c-u>lua require"treesitter-unit".select(true)<CR>', { noremap = true })

	-- https://github.com/m-demare/hlargs.nvim
	require('hlargs').setup()

	-- https://github.com/haringsrob/nvim_context_vt
	--[[ require('nvim_context_vt').setup {
		disable_virtual_lines = true, -- (Python 等のインデントベースの言語で) 仮想の行を作成しない
		min_rows = 6,
	} ]]
end

-- NeoTree
require("neo-tree").setup {
	window = {
		mappings = {
			["<Space>"] = nil,
			["o"] = "open",
		},
	},
	filesystem = {
		hijack_netrw_behavior = "open_current",
	},
}
vim.keymap.set("n", ",,t", "<Cmd>NeoTreeFocusToggle<CR>")
vim.keymap.set("n", ",,f", "<Cmd>NeoTreeFloat<CR>")
