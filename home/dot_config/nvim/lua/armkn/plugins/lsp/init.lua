return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "folke/neoconf.nvim", cmd = "Neoconf", config = true },
			{ "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
			"hrsh7th/cmp-nvim-lsp",
			"mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		---@class PluginLspOpts
		opts = {
			-- options for vim.diagnostic.config()
			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = { spacing = 4, prefix = "●" },
				severity_sort = true,
			},
			server_default_opts = {
				autostart = true,
				single_file_support = true,
			},
		},
		---@param opts PluginLspOpts
		config = function(_, opts)
			-- on_attach hook
			require("armkn.utils").autocmd_lsp_attach(function(client, buffer)
				require("armkn.plugins.lsp.keymaps").on_attach(client, buffer)
			end)

			-- setup diagnostics
			for name, icon in pairs(require("armkn.icons").diagnostics) do
				name = "DiagnosticSign" .. name
				vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
			end
			vim.diagnostic.config(opts.diagnostics)

			local lspconfig = require("lspconfig")
			local servers = require("armkn.plugins.lsp.servers")
			local capabilities =
				require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

			local function setup(server)
				local o = vim.tbl_deep_extend("force", {
					capabilities = capabilities,
				}, opts.server_default_opts, servers[server] or {})
				lspconfig[server].setup(o)
			end

			local all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
			local ensure_installed_with_mason = {} ---@type string[]

			-- setup without mason or append into table
			for server, server_opts in pairs(servers) do
				if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
					setup(server)
				else
					ensure_installed_with_mason[#ensure_installed_with_mason + 1] = server
				end
			end

			local mlsp = require("mason-lspconfig")
			mlsp.setup({ ensure_installed = ensure_installed_with_mason })
			mlsp.setup_handlers({ setup })
		end,
	},

	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			return {
				root_dir = require("null-ls.utils").root_pattern(".neoconf.json", "Makefile", ".git"),
				sources = require("armkn.plugins.lsp.nls-sources"),
			}
		end,
	},

	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		config = function(_, opts)
			require("mason").setup(opts)
		end,
	},
}
