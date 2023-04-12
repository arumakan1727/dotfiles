-- this will return a function that calls telescope.
-- cwd will default to lazyvim.util.get_root
-- for `files`, git_files or find_files will be chosen depending on .git
local function telescope_builtin(builtin, opts)
  local params = { builtin = builtin, opts = opts }
	local utils = require("armkn.utils")
  return function()
    builtin = params.builtin
    opts = params.opts
    opts = vim.tbl_deep_extend("force", { cwd = utils.get_root() }, opts or {})
    if builtin == "files" then
      if vim.loop.fs_stat((opts.cwd or vim.loop.cwd()) .. "/.git") then
        opts.show_untracked = true
        builtin = "git_files"
      else
        builtin = "find_files"
      end
    end
    require("telescope.builtin")[builtin](opts)
  end
end

return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		version = false, -- telescope did only one release, so use HEAD for now
		keys = {
			{ "z,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
			{ "z/", telescope_builtin("live_grep"), desc = "Find in Files (Grep)" },
			{ "z:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
			{ "z<space>", telescope_builtin("files"), desc = "Find Files (root dir)" },
			-- find
			{ "zfb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "zff", telescope_builtin("files"), desc = "Find Files (root dir)" },
			{ "zfF", telescope_builtin("files", { cwd = false }), desc = "Find Files (cwd)" },
			{ "zfr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
			-- git
			{ "zgc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
			{ "zgs", "<cmd>Telescope git_status<CR>", desc = "status" },
			-- search
			{ "zsa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
			{ "zsb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
			{ "zsc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
			{ "zsC", "<cmd>Telescope commands<cr>", desc = "Commands" },
			{ "zsd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
			{ "zsg", telescope_builtin("live_grep"), desc = "Grep (root dir)" },
			{ "zsG", telescope_builtin("live_grep", { cwd = false }), desc = "Grep (cwd)" },
			{ "zsh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
			{ "zsH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
			{ "zsk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
			{ "zsM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
			{ "zsm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
			{ "zso", "<cmd>Telescope vim_options<cr>", desc = "Options" },
			{ "zsR", "<cmd>Telescope resume<cr>", desc = "Resume" },
			{ "zsw", telescope_builtin("grep_string"), desc = "Word (root dir)" },
			{ "zsW", telescope_builtin("grep_string", { cwd = false }), desc = "Word (cwd)" },
			{ "zuC", telescope_builtin("colorscheme", { enable_preview = true }), desc = "Colorscheme with preview" },
		},
		opts = {
			defaults = {
				prompt_prefix = " ",
				selection_caret = " ",
				mappings = {
					i = {
						["<c-t>"] = function(...)
							return require("trouble.providers.telescope").open_with_trouble(...)
						end,
						["<a-t>"] = function(...)
							return require("trouble.providers.telescope").open_selected_with_trouble(...)
						end,
						["<a-i>"] = function()
							telescope_builtin("find_files", { no_ignore = true })()
						end,
						["<a-h>"] = function()
							telescope_builtin("find_files", { hidden = true })()
						end,
						["<C-Down>"] = function(...)
							return require("telescope.actions").cycle_history_next(...)
						end,
						["<C-Up>"] = function(...)
							return require("telescope.actions").cycle_history_prev(...)
						end,
						["<C-f>"] = function(...)
							return require("telescope.actions").preview_scrolling_down(...)
						end,
						["<C-b>"] = function(...)
							return require("telescope.actions").preview_scrolling_up(...)
						end,
					},
					n = {
						["q"] = function(...)
							return require("telescope.actions").close(...)
						end,
					},
				},
			},
		},
	},
}
