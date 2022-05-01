do -- LSP
	-- プロジェクト固有の LSP 設定を json/yaml で設定可能に
	-- https://github.com/tamago324/nlsp-settings.nvim
	require("nlspsettings").setup {
		config_home = vim.fn.stdpath("config") .. "/nlsp-settings",
		local_settings_dir = ".nvim/nlsp-settings",
		local_settings_root_markers = { ".nvim",  ".git" },
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
		buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
		buf_set_keymap("n", "<Space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
		buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
		buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
	end
	local servers = {
		'bashls',
		'clangd',
		'cssls',
		'gopls',
		'hls',
		'html',
		'jsonls',
		'nimls',
		'ocamllsp',
		'pyright',
		'rust_analyzer',
		'sumneko_lua',
		'tsserver',
		'vimls',
		'volar',
	}
	local custom_configs = {
		["clangd"] = {
			cmd = { 'clangd', '--background-index', '--enable-config', '--header-insertion=never' },
		},
	}
	local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
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

	require("fidget").setup()
end


-- treesitter
do
	require("nvim-treesitter.configs").setup {
		-- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
		ensure_installed = "all",
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		indent = { enable = false, }, -- yati を使うので disable
		yati = { enable = true },
		context_commentstring = { enable = true },
		matchup = { enable = true },
		nvimGPS = { enable = true },
		autotag = { enable = true },
	}
	require('hlargs').setup()
	require('nvim_context_vt').setup {
		-- Disable display of virtual text below blocks for indentation based languages like Python
		disable_virtual_lines = true,
		-- How many lines required after starting position to show virtual text
		min_rows = 6,
	}
end


vim.cmd 'colorscheme duskfox'
vim.o.list = true
vim.o.listchars = "tab:» ,trail:･"
vim.cmd 'hi IndentBlanklineIndent1 guibg=#2f2b44 gui=nocombine'
vim.cmd 'hi IndentBlanklineIndent2 guibg=#231d36 gui=nocombine'
vim.cmd 'hi Whitespace guifg=#575385 gui=nocombine'  -- color of listchar
require('indent_blankline').setup {
	char = "",
	char_highlight_list = {
		"IndentBlanklineIndent1",
		"IndentBlanklineIndent2",
	},
	space_char_highlight_list = {
		"IndentBlanklineIndent1",
		"IndentBlanklineIndent2",
	},
	show_trailing_blankline_indent = false,
}
require'colorizer'.setup()
require("todo-comments").setup()
