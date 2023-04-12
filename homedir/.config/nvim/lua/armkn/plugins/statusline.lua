local function get_active_lsp_names()
	local FALLBACK_MSG = 'No Active LSP'
	local clients = vim.lsp.get_active_clients()
	if #clients == 0 then
		return FALLBACK_MSG
	end

	local bufnr = vim.fn.bufnr()
	local res = nil
	for _, c in ipairs(clients) do
		if c.attached_buffers[bufnr] then
			res = res and (res .. ',' .. c.name) or c.name
		end
	end
	return res or FALLBACK_MSG
end

return {
	{
		"SmiteshP/nvim-navic",
		lazy = true,
		init = function()
			require("armkn.utils").on_lsp_attach(function(client, buffer)
				if client.server_capabilities.documentSymbolProvider then
					require("nvim-navic").attach(client, buffer)
				end
			end)
		end,
		opts = {
			separator = " > ",
			highlight = true,
			depth_limit = 5,
		}
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = function()
			local icons = require("armkn.icons")

			local function fg(name)
				return function()
					---@type {foreground?:number}?
					local hl = vim.api.nvim_get_hl_by_name(name, true)
					return hl and hl.foreground and { fg = string.format("#%06x", hl.foreground) }
				end
			end

			return {
				options = {
					theme = "auto",
					globalstatus = true,
					disabled_filetypes = { statusline = { "dashboard", "alpha" } },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						{ 'filename', path = 1 }
					},
					lualine_c = {
						'branch',
						'diff',
						{ 'diagnostics', sources = { 'nvim_lsp' } },
						{
							function() return require("nvim-navic").get_location() end,
							cond = function()
								return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
							end,
						},
					},
					lualine_x = {
						'encoding',
						'fileformat',
						'filetype',
						{
							'active_lsp_name',
							fmt = get_active_lsp_names,
							color = {fg = '#60c3c0'}
						},
					},
				},
				extensions = { "neo-tree", "lazy" },
			}
		end,
	},
}
