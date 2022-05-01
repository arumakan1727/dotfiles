local keymap = vim.keymap

-- Customize LSP signs
do
	local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end
end

-- https://github.com/akinsho/bufferline.nvim#configuration
do -- Bufferline
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

-- https://github.com/nvim-lualine/lualine.nvim
do  -- Statusline
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

	local gps = require('nvim-gps')

	require'lualine'.setup {
		options = {
			theme = 'solarized_dark'
		},
		sections = {
			lualine_b = {
				{
					'filename',
					path = 1,  -- 0: Just the filename / 1: Relative path / 2: Absolute path
				}
			},
			lualine_c = {
				'branch',
				'diff',
				{
					'diagnostics',
					sources = {'nvim_lsp'},
					diagnostics_color = {
						error = {fg = '#ff3333'}
					}
				},
				{
					gps.get_location,
					cond = gps.is_available
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
	}
end


-- https://github.com/mattn/vim-sonictemplate/blob/master/doc/sonictemplate.txt
do -- sonictemplate
	vim.g.sonictemplate_vim_template_dir = {
		vim.fn.expand('~/.config/nvim/sonictemplate'),
		vim.fn.expand('~/kyopro/sonictemplate'),
	}
	vim.api.nvim_create_autocmd("CmdUndefined", {
		pattern = "Template",
		group = 'vimrc_pluginconfig',
		once = true,
		command = "packadd vim-sonictemplate"
	})
end


do -- treesitter

end


do -- Telescope
	keymap.set("n", "z ", "<Cmd>Telescope<CR>", { noremap=true, silent=false })
	keymap.set("n", "za", "<Cmd>Telescope autocommands<CR>", { noremap=true, silent=false })
	keymap.set("n", "zb", "<Cmd>Telescope buffers<CR>", { noremap=true, silent=false })
	keymap.set("n", "zc", "<Cmd>Telescope commands<CR>", { noremap=true, silent=false })
	keymap.set("n", "zf", "<Cmd>Telescope find_files<CR>", { noremap=true, silent=false })
	keymap.set("n", "zg", "<Cmd>Telescope live_grep<CR>", { noremap=true, silent=false })
	keymap.set("n", "zh", "<Cmd>Telescope help_tags<CR>", { noremap=true, silent=false })
	keymap.set("n", "zk", "<Cmd>Telescope keymaps<CR>", { noremap=true, silent=false })
	keymap.set("n", "zl", "<Cmd>Telescope oldfiles<CR>", { noremap=true, silent=false })
	keymap.set("n", "zo", "<Cmd>Telescope vim_options<CR>", { noremap=true, silent=false })
	keymap.set("n", "zr", "<Cmd>Telescope frecency<CR>", { noremap=true, silent=false })
	keymap.set("n", "zt", "<Cmd>Telescope sonictemplate templates<CR>", { noremap=true, silent=false })

	-- 遅延ロード (Telescope コマンドが実行されてから初めて packadd する)
	vim.api.nvim_create_autocmd("CmdUndefined", {
		pattern = "Telescope",
		group = 'vimrc_pluginconfig',
		once = true,
		callback = function()
			vim.cmd "packadd telescope.nvim"
			vim.cmd "packadd telescope-frecency.nvim"
			vim.cmd "packadd telescope-sonictemplate.nvim"
			local telescope = require"telescope"
			local layout_actions = require"telescope.actions.layout"
			telescope.setup {
				mappings = {
					n = { ["<C-t>"] = layout_actions.toggle_preview },
					i = { ["<C-t>"] = layout_actions.toggle_preview },
				},
				extensions = {
					frecency = {
						show_scores = true,
						ignore_patterns = {"*.git/*", "*/tmp/*", "/ramdisk/*"},
						workspaces = {
							["conf"] = vim.fn.expand("~/.config"),
							["univ"] = vim.fn.expand("~/Univ"),
						}
					}
				},
			}
			telescope.load_extension("frecency")
			telescope.load_extension("sonictemplate")
		end,
	})
end
