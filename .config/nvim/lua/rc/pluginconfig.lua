local MY_GROUP = "vimrc_pluginconfig"
vim.api.nvim_create_augroup(MY_GROUP, { clear = true })


-- LSP
do
	-- プロジェクト固有の LSP 設定を json/yaml で設定可能に
	-- https://github.com/tamago324/nlsp-settings.nvim
	require("nlspsettings").setup {
		config_home = vim.fn.stdpath("config") .. "/nlsp-settings",
		local_settings_dir = ".nvim/nlsp-settings",
		local_settings_root_markers = { ".git" },
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

	-- 以下 lspconfig の設定
	-- https://github.com/neovim/nvim-lspconfig#suggested-configuration
	local on_attach = function(client, bufnr)
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
end


vim.cmd("colorscheme duskfox")


local function callbackOnVimEnter()
	local keymap = vim.keymap

	-- Customize LSP signs
	do
		local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
		end
	end

	-- Bufferline
	-- https://github.com/akinsho/bufferline.nvim#configuration
	do
		require('bufferline').setup {
			options = {
				mode = "buffers", -- set to "tabs" to only show tabpages instead
				numbers = "both",
				close_command = "bdelete! %d",
				right_mouse_command = nil,
				left_mouse_command = "buffer %d",
				middle_mouse_command = "bdelete! %d",
				max_name_length = 18,
				max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
				tab_size = 18,
				diagnostics = "nvim_lsp",
				diagnostics_update_in_insert = false,
				diagnostics_indicator = function(count, level, diagnostics_dict, context)
					return "("..count..")"
				end,
				-- NOTE: this will be called a lot so don't do any heavy processing here
				custom_filter = function(buf_number, buf_numbers)
					if vim.bo[buf_number].filetype == "qf" then
						return false
					end
					return true
				end,
				color_icons = true,
				show_buffer_icons = true,
				show_buffer_close_icons = false,
				show_buffer_default_icon = false, -- whether or not an unrecognised filetype should show a default icon
				show_close_icon = false,
				show_tab_indicators = true,
				persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
				separator_style = "thin", -- "slant" | "thick" | "thin" | { 'any', 'any' }
				enforce_regular_tabs = false,
				always_show_bufferline = true,
			}
		}
		keymap.set("n", "[b", "<Cmd>BufferLineCyclePrev<CR>", { noremap=true, silent=true })
		keymap.set("n", "]b", "<Cmd>BufferLineCycleNext<CR>", { noremap=true, silent=true })
		keymap.set("n", ",bp", "<Cmd>BufferLinePick<CR>", { noremap=true, silent=true })
		keymap.set("n", ",bd", "<Cmd>bdelete!<CR>", { noremap=true, silent=true })
		keymap.set("n", ",bH", "<Cmd>BufferLineMovePrev<CR>", { noremap=true, silent=true })
		keymap.set("n", ",bL", "<Cmd>BufferLineMoveNext<CR>", { noremap=true, silent=true })

		keymap.set("n", ",1", "<Cmd>BufferLineGoToBuffer 1<CR>", { noremap=true, silent=true })
		keymap.set("n", ",2", "<Cmd>BufferLineGoToBuffer 2<CR>", { noremap=true, silent=true })
		keymap.set("n", ",3", "<Cmd>BufferLineGoToBuffer 3<CR>", { noremap=true, silent=true })
		keymap.set("n", ",4", "<Cmd>BufferLineGoToBuffer 4<CR>", { noremap=true, silent=true })
		keymap.set("n", ",5", "<Cmd>BufferLineGoToBuffer 5<CR>", { noremap=true, silent=true })
		keymap.set("n", ",6", "<Cmd>BufferLineGoToBuffer 6<CR>", { noremap=true, silent=true })
		keymap.set("n", ",7", "<Cmd>BufferLineGoToBuffer 7<CR>", { noremap=true, silent=true })
		keymap.set("n", ",8", "<Cmd>BufferLineGoToBuffer 8<CR>", { noremap=true, silent=true })
		keymap.set("n", ",9", "<Cmd>BufferLineGoToBuffer 9<CR>", { noremap=true, silent=true })
	end
end

vim.api.nvim_create_autocmd("VimEnter", { group=MY_GROUP, callback=callbackOnVimEnter })
