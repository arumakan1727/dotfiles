local keymap = vim.keymap
local MY_GROUP = 'vimrc_pluginconfig';

-- Customize LSP signs
do
	local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end
end


-- https://github.com/mattn/vim-sonictemplate/blob/master/doc/sonictemplate.txt
do -- sonictemplate
	vim.g.sonictemplate_vim_template_dir = {
		vim.fn.expand('~/.config/nvim/sonictemplate'),
		vim.fn.expand('~/kyopro/sonictemplate'),
	}
end


-- https://github.com/nvim-telescope/telescope.nvim
keymap.set("n", "z<Space>", "<Cmd>Telescope<CR>", { noremap=true, silent=false })
keymap.set("n", "za", "<Cmd>Telescope autocommands<CR>", { noremap=true, silent=false })
keymap.set("n", "zb", "<Cmd>Telescope buffers<CR>", { noremap=true, silent=false })
keymap.set("n", "zc", "<Cmd>Telescope commands<CR>", { noremap=true, silent=false })
keymap.set("n", "zf", "<Cmd>Telescope find_files hidden=true follow=true<CR>", { noremap=true, silent=false })
keymap.set("n", "zg", "<Cmd>Telescope live_grep<CR>", { noremap=true, silent=false })
keymap.set("n", "zh", "<Cmd>Telescope help_tags<CR>", { noremap=true, silent=false })
keymap.set("n", "zk", "<Cmd>Telescope keymaps<CR>", { noremap=true, silent=false })
keymap.set("n", "zl", "<Cmd>Telescope oldfiles<CR>", { noremap=true, silent=false })
keymap.set("n", "zo", "<Cmd>Telescope vim_options<CR>", { noremap=true, silent=false })
keymap.set("n", "zt", "<Cmd>Telescope sonictemplate templates<CR>", { noremap=true, silent=false })
do
	local telescope = require"telescope"
	local layout_actions = require"telescope.actions.layout"
	telescope.setup {
		defaults = {
			mappings = {
				n = { ["<C-t>"] = layout_actions.toggle_preview },
				i = { ["<C-t>"] = layout_actions.toggle_preview },
			},
		},
		extensions = {
		},
	}
	telescope.load_extension("sonictemplate")
end

-- https://github.com/andymass/vim-matchup
vim.g.matchup_matchparen_offscreen = {method = 'popup'}

-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/MAIN.md
do
	local null_ls = require("null-ls")
	null_ls.setup {
		sources = {
			-- formatter
			null_ls.builtins.formatting.black,
			null_ls.builtins.formatting.erb_lint,
			null_ls.builtins.formatting.isort,
			null_ls.builtins.formatting.markdownlint,
			null_ls.builtins.formatting.prettier.with({
				condition = function(utils)
					return utils.root_has_file({ "package.json" })
				end,
			}),
			null_ls.builtins.formatting.rubocop,
			null_ls.builtins.formatting.shfmt,
			null_ls.builtins.formatting.stylua,
			-- linter
			null_ls.builtins.diagnostics.cppcheck,
			null_ls.builtins.diagnostics.erb_lint,
			null_ls.builtins.diagnostics.eslint_d.with({
				method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
				condition = function(utils)
					return utils.root_has_file({ "package.json" })
				end,
			}),
			null_ls.builtins.diagnostics.hadolint,
			null_ls.builtins.diagnostics.misspell,
			-- null_ls.builtins.diagnostics.phpmd,
			-- null_ls.builtins.diagnostics.phpstan,
			null_ls.builtins.diagnostics.rubocop,
			null_ls.builtins.diagnostics.shellcheck,
			null_ls.builtins.diagnostics.golangci_lint,
		}
	}
end


-- https://github.com/folke/trouble.nvim
keymap.set("n", ",,d", "<Cmd>TroubleToggle<CR>", { noremap=true, silent=false })
vim.api.nvim_create_autocmd("CmdUndefined", {
	pattern = "Trouble*",
	once = true,
	command = "packadd trouble.nvim"
})

-- https://github.com/junegunn/vim-easy-align
keymap.set({"n", "x"}, "ga", "<Plug>(EasyAlign)", { noremap=true, silent=false })

-- https://github.com/AckslD/nvim-trevJ.lua
require('trevj').setup()
keymap.set("n", "gJ",
	function() require('trevj').format_at_cursor() end,
	{ noremap=true, silent=false }
)

-- https://github.com/numToStr/Comment.nvim
require('Comment').setup()

-- https://github.com/t9md/vim-quickhl
keymap.set({"n", "x"}, "<Space>;", "<Plug>(quickhl-manual-this)")

-- https://github.com/phaazon/hop.nvim
require('hop').setup()
keymap.set({"n", "x"}, "<Space><Space>w", "<Cmd>HopWord<CR>")
keymap.set({"n", "x"}, "<Space><Space>j", "<Cmd>HopWordAC<CR>")
keymap.set({"n", "x"}, "<Space><Space>k", "<Cmd>HopWordBC<CR>")
keymap.set({"n", "x"}, "<Space><Space>c", "<Cmd>HopChar1<CR>")
keymap.set({"n", "x"}, "<Space><Space>l", "<Cmd>HopLine<CR>")

-- https://github.com/kevinhwang91/nvim-hlslens
-- https://github.com/haya14busa/vim-asterisk
require('hlslens').setup()
vim.g['asterisk#keeppos'] = 1
keymap.set({'n', 'x'}, '*', [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]])
keymap.set({'n', 'x'}, '#', [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]])
keymap.set({'n', 'x'}, 'g*', [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]])
keymap.set({'n', 'x'}, 'g#', [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]])

-- https://github.com/osyo-manga/vim-milfeulle/blob/master/doc/milfeulle.jax
vim.g['milfeulle_default_kind'] = 'buffer'
vim.g['milfeulle_default_jumper_name'] = 'win_tab_bufnr_pos'
keymap.set('n', '[g', '<Plug>(milfeulle-prev)')
keymap.set('n', ']g', '<Plug>(milfeulle-next)')


-- https://github.com/lewis6991/gitsigns.nvim
require('gitsigns').setup {
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map('n', ']c', function()
			if vim.wo.diff then return ']c' end
			vim.schedule(gs.next_hunk)
			return '<Ignore>'
		end, {expr=true})

		map('n', '[c', function()
			if vim.wo.diff then return '[c' end
			vim.schedule(gs.prev_hunk)
			return '<Ignore>'
		end, {expr=true})

		-- Actions
		map({'n', 'v'}, ',gs', ':Gitsigns stage_hunk<CR>')
		map({'n', 'v'}, ',gr', ':Gitsigns reset_hunk<CR>')
		map('n', ',gS', gs.stage_buffer)
		map('n', ',gu', gs.undo_stage_hunk)
		map('n', ',gR', gs.reset_buffer)
		map('n', ',gp', gs.preview_hunk)
		map('n', ',gb', function() gs.blame_line{full=true} end)
		map('n', ',gl', gs.toggle_current_line_blame)
		map('n', ',gd', gs.diffthis)
		map('n', ',gD', function() gs.diffthis('~') end)

		-- Text object
		map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
	end,
}

-- https://github.com/TimUntersberger/neogit
require("neogit").setup()
keymap.set('n', ',,g', '<Cmd>Neogit<CR>')


-- Colorizing
local function setup_highlight()
	vim.o.list = true
	vim.o.listchars = "tab:» ,trail:･"
	vim.cmd 'hi IndentBlanklineIndent1 guibg=#2f2b44 gui=nocombine'
	vim.cmd 'hi IndentBlanklineIndent2 guibg=#231d36 gui=nocombine'
	vim.cmd 'hi Whitespace guifg=#575385 gui=nocombine'  -- color of listchar
end
vim.api.nvim_create_autocmd("ColorScheme", {
	group = MY_GROUP,
	callback = setup_highlight
})

require('indent_blankline').setup {
	char = "",
	char_highlight_list = {
		"IndentBlanklineIndent1",
		"IndentBlanklineIndent2",
	},
	space_char_highlight_list = {
		"IndentBlanklineIndent1",
		"IndentBlanklineIndent2",
	},
	show_trailing_blankline_indent = false,
}

vim.cmd "colorscheme duskfox"
setup_highlight()

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
	gps.setup{}

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

-- https://github.com/akinsho/bufferline.nvim#configuration
do -- Bufferline
	require('bufferline').setup {
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
		}
	}
	keymap.set("n", "[b", "<Cmd>BufferLineCyclePrev<CR>", { noremap=true, silent=true })
	keymap.set("n", "]b", "<Cmd>BufferLineCycleNext<CR>", { noremap=true, silent=true })
	keymap.set("n", ",bp", "<Cmd>BufferLinePick<CR>", { noremap=true, silent=true })
	keymap.set("n", ",bd", "<Cmd>lua require'bufdelete'.bufdelete(0, false)<CR>", { noremap=true, silent=true })
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

require'colorizer'.setup()
require'todo-comments'.setup()
