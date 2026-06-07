return {
	{
		"stevearc/dressing.nvim",
		lazy = true,
		init = function()
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.select(...)
			end
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.input = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.input(...)
			end
		end,
	},
	{
		"rcarriga/nvim-notify",
		keys = {
			{
				"<leader>un",
				function()
					require("notify").dismiss({ silent = true, pending = true })
				end,
				desc = "Delete all Notifications",
			},
		},
		opts = {
			timeout = 3000,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
		},
		init = function()
			vim.notify = require("notify")
		end,
	},
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
