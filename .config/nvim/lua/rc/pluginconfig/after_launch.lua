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
			null_ls.builtins.formatting.stylua,
			null_ls.builtins.formatting.black,
			null_ls.builtins.formatting.isort,
			null_ls.builtins.formatting.prettier,
			null_ls.builtins.formatting.shfmt,
			null_ls.builtins.formatting.markdownlint,
			-- linter
			null_ls.builtins.diagnostics.shellcheck,
			null_ls.builtins.diagnostics.cppcheck,
			null_ls.builtins.diagnostics.eslint_d,
			null_ls.builtins.diagnostics.hadolint,
			null_ls.builtins.diagnostics.staticcheck,
			null_ls.builtins.diagnostics.phpstan,
			null_ls.builtins.diagnostics.phpmd,
		}
	}
end


-- https://github.com/renerocksai/telekasten.nvim
do
	local home = vim.fn.expand("~/zettelkasten")
	require('telekasten').setup({
		home = home,

		-- if true, telekasten will be enabled when opening a note within the configured home
		take_over_my_home = true,

		-- auto-set telekasten filetype: if false, the telekasten filetype will not be used
		--                               and thus the telekasten syntax will not be loaded either
		auto_set_filetype = true,

		-- dir names for special notes (absolute path or subdir name)
		dailies   = home .. '/' .. 'daily',
		weeklies  = home .. '/' .. 'weekly',
		templates = home .. '/' .. 'templates',

		-- image (sub)dir for pasting
		-- dir name (absolute path or subdir name)
		-- or nil if pasted images shouldn't go into a special subdir
		image_subdir = "img",

		-- markdown file extension
		extension = ".md",

		-- prefix file with uuid
		prefix_title_by_uuid = false,
		-- file uuid type ("rand" or input for os.date()")
		uuid_type = "%Y-%m%d-%H%M",
		-- UUID separator
		uuid_sep = "-",

		-- following a link to a non-existing note will create it
		follow_creates_nonexisting = true,
		dailies_create_nonexisting = true,
		weeklies_create_nonexisting = true,

		-- skip telescope prompt for goto_today and goto_thisweek
		journal_auto_open = false,

		-- template for new notes (new_note, follow_link)
		-- set to `nil` or do not specify if you do not want a template
		template_new_note = home .. '/' .. 'templates/new_note.md',

		-- template for newly created daily notes (goto_today)
		-- set to `nil` or do not specify if you do not want a template
		template_new_daily = home .. '/' .. 'templates/daily.md',

		-- template for newly created weekly notes (goto_thisweek)
		-- set to `nil` or do not specify if you do not want a template
		template_new_weekly= home .. '/' .. 'templates/weekly.md',

		-- image link style
		-- wiki:     ![[image name]]
		-- markdown: ![](image_subdir/xxxxx.png)
		image_link_style = "markdown",

		-- default sort option: 'filename', 'modified'
		sort = "filename",

		-- integrate with calendar-vim
		plug_into_calendar = true,
		calendar_opts = {
			-- calendar week display mode: 1 .. 'WK01', 2 .. 'WK 1', 3 .. 'KW01', 4 .. 'KW 1', 5 .. '1'
			weeknm = 4,
			-- use monday as first day of week: 1 .. true, 0 .. false
			calendar_monday = 0,
			-- calendar mark: where to put mark for marked days: 'left', 'right', 'left-fit'
			calendar_mark = 'left-fit',
		},

		-- telescope actions behavior
		close_after_yanking = false,
		insert_after_inserting = true,

		-- tag notation: '#tag', ':tag:', 'yaml-bare'
		tag_notation = "#tag",

		-- command palette theme: dropdown (window) or ivy (bottom panel)
		command_palette_theme = "ivy",

		-- tag list theme:
		-- get_cursor: small tag list at cursor; ivy and dropdown like above
		show_tags_theme = "ivy",

		-- when linking to a note in subdir/, create a [[subdir/title]] link
		-- instead of a [[title only]] link
		subdirs_in_links = true,

		-- template_handling
		-- What to do when creating a new note via `new_note()` or `follow_link()`
		-- to a non-existing note
		-- - prefer_new_note: use `new_note` template
		-- - smart: if day or week is detected in title, use daily / weekly templates (default)
		-- - always_ask: always ask before creating a note
		template_handling = "smart",

		-- path handling:
		--   this applies to:
		--     - new_note()
		--     - new_templated_note()
		--     - follow_link() to non-existing note
		--
		--   it does NOT apply to:
		--     - goto_today()
		--     - goto_thisweek()
		--
		--   Valid options:
		--     - smart: put daily-looking notes in daily, weekly-looking ones in weekly,
		--              all other ones in home, except for notes/with/subdirs/in/title.
		--              (default)
		--
		--     - prefer_home: put all notes in home except for goto_today(), goto_thisweek()
		--                    except for notes with subdirs/in/title.
		--
		--     - same_as_current: put all new notes in the dir of the current note if
		--                        present or else in home
		--                        except for notes/with/subdirs/in/title.
		new_note_location = "smart",

		-- should all links be updated when a file is renamed
		rename_update_links = true,
	})

	-- on hesitation
	keymap.set("n", ",z", "<Cmd>Telekasten panel<CR>")

	-- search
	keymap.set("n", ",zf", "<Cmd>Telekasten find_notes<CR>")
	keymap.set("n", ",zd", "<Cmd>Telekasten find_daily_notes<CR>")
	keymap.set("n", ",zw", "<Cmd>Telekasten find_weekly_notes<CR>")
	keymap.set("n", ",zg", "<Cmd>Telekasten search_notes<CR>")

	-- create/goto
	keymap.set("n", ",zT", "<Cmd>Telekasten goto_today<CR>")
	keymap.set("n", ",zW", "<Cmd>Telekasten goto_thisweek<CR>")
	keymap.set("n", ",zT", "<Cmd>Telekasten goto_today<CR>")
	keymap.set("n", ",zn", "<Cmd>Telekasten new_note<CR>")
	keymap.set("n", ",zN", "<Cmd>Telekasten new_templated_note<CR>")

	-- edit/view
	keymap.set("n", ",zr", "<Cmd>Telekasten rename_note<CR>")
	keymap.set("n", ",zz", "<Cmd>Telekasten follow_link<CR>")
	keymap.set("n", ",zy", "<Cmd>Telekasten yank_notelink<CR>")
	keymap.set("n", ",zc", "<Cmd>Telekasten show_calendar<CR>")
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


-- https://github.com/edluffy/specs.nvim
require('specs').setup{
	show_jumps  = false,
	min_jump = 30,
	popup = {
		delay_ms = 0, -- delay before popup displays
		inc_ms = 5, -- time increments used for fade/resize effects
		blend = 5, -- starting blend, between 0-100 (fully transparent), see :h winblend
		width = 50,
		winhl = "Todo",
		fader = require('specs').linear_fader,
		resizer = require('specs').shrink_resizer
	},
	ignore_filetypes = {},
	ignore_buftypes = {
		nofile = true,
	},
}
keymap.set("n", "<Space><CR>", require("specs").show_specs)

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
