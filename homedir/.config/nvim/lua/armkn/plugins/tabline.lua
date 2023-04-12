return {
	-- bufferline
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
			{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
		},
		opts = {
			options = {
				mode = "buffers", -- set to "tabs" to only show tabpages instead
				numbers = "ordinal",
				close_command = "bdelete! %d",
				right_mouse_command = nil,
				left_mouse_command = "buffer %d",
				middle_mouse_command = "bdelete! %d",
				max_name_length = 18,
				max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
				tab_size = 18,
				diagnostics = "nvim_lsp",
				diagnostics_update_in_insert = false,
				diagnostics_indicator = function(count, _, _, _)
					return "("..count..")"
				end,
				-- NOTE: this will be called a lot so don't do any heavy processing here
				custom_filter = function(buf_number, _)
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
				offsets = {
					{
						filetype = "neo-tree",
						text = "Neo-tree",
						highlight = "Directory",
						text_align = "left",
					},
				},
			},
		},
	},
}
