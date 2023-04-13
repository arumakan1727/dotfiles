return {
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = function()
			local colors = require("tokyonight.colors").setup()
			local util = require("tokyonight.util")
			vim.cmd("hi IndentBlanklineIndent1 gui=nocombine guibg=" .. util.darken(colors.bg_dark, -2))
			vim.cmd("hi IndentBlanklineIndent2 gui=nocombine guibg=" .. util.darken(colors.bg_dark, 0.5))
			return {
				--char = "│",
				char = "",
				filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
				show_trailing_blankline_indent = false,
				show_current_context = false,
				char_highlight_list = {
					"IndentBlanklineIndent1",
					"IndentBlanklineIndent2",
				},
				space_char_highlight_list = {
					"IndentBlanklineIndent1",
					"IndentBlanklineIndent2",
				},
			}
		end,
	},
}
