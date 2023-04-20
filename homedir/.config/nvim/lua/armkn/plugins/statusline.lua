local function get_active_lsp_names()
	local FALLBACK_MSG = "No Active LSP"
	local clients = vim.lsp.get_active_clients()
	if #clients == 0 then
		return FALLBACK_MSG
	end

	local bufnr = vim.fn.bufnr()
	local res = nil
	for _, c in ipairs(clients) do
		if c.attached_buffers[bufnr] then
			res = res and (res .. "," .. c.name) or c.name
		end
	end
	return res or FALLBACK_MSG
end

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"SmiteshP/nvim-navic",
		},
		event = "VeryLazy",
		opts = function()
			return {
				options = {
					theme = "auto",
					globalstatus = true,
					disabled_filetypes = { statusline = { "dashboard", "alpha" } },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = {
						{
							function()
								return require("nvim-navic").get_location()
							end,
							cond = function()
								return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
							end,
						},
					},
					lualine_x = {
						"encoding",
						"fileformat",
						"filetype",
						{
							"active_lsp_name",
							fmt = get_active_lsp_names,
							color = { fg = "#60c3c0" },
						},
					},
				},
				winbar = {
					lualine_a = {},
					lualine_b = { { "filename", path = 1 } },
					lualine_c = {
						"diff",
						{ "diagnostics", sources = { "nvim_lsp" } },
					},
				},
				inactive_winbar = {
					lualine_a = {},
					lualine_b = { { "filename", path = 1 } },
					lualine_c = {},
				},
				extensions = { "neo-tree", "lazy" },
			}
		end,
	},
}
