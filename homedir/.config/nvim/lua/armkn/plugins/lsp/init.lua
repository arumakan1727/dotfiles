return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "folke/neoconf.nvim", cmd = "Neoconf", config = true },
			{ "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
			{ "hrsh7th/cmp-nvim-lsp" },
		},
		---@class PluginLspOpts
		opts = {
			-- options for vim.diagnostic.config()
			diagnostics = {
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			},
			server_default_opts = {
				autostart = true,
				single_file_support = true,
			},
		},
		---@param opts PluginLspOpts
		config = function(_, opts)
			require("armkn.utils").autocmd_lsp_attach(function(client, buffer)
				require("armkn.plugins.lsp.keymaps").on_attach(client, buffer)
			end)
			for name, icon in pairs(require("armkn.icons").diagnostics) do
				name = "DiagnosticSign" .. name
				vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
			end
			vim.diagnostic.config(opts.diagnostics)

			local lspconfig = require("lspconfig")
			local servers = require("armkn.plugins.lsp.servers")
			local capabilities =
				require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
			for server, server_opts in pairs(servers) do
				local o = vim.tbl_deep_extend("force", {
					capabilities = capabilities,
				}, opts.server_default_opts, server_opts)
				lspconfig[server].setup(o)
			end
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
}
