return {
	{ "MunifTanjim/nui.nvim", lazy = true },
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "nvim-tree/nvim-web-devicons", lazy = true },
	{
		"SmiteshP/nvim-navic",
		lazy = true,
		init = function()
			require("armkn.utils").autocmd_lsp_attach(function(client, buffer)
				if client.server_capabilities.documentSymbolProvider then
					require("nvim-navic").attach(client, buffer)
				end
			end)
		end,
		opts = {
			separator = " 〉",
			highlight = true,
			depth_limit = 6,
		},
	},
}
