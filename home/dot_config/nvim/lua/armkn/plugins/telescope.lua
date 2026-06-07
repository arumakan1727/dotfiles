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
			if vim.loop.fs_stat((vim.loop.cwd() or opts.cwd) .. "/.git") then
				opts.show_untracked = true
				builtin = "git_files"
			else
				builtin = "find_files"
			end
		end
		require("telescope.builtin")[builtin](opts)
	end
end

local function c_cpp_header_files(opts)
	opts = opts or {}

	local ft = vim.api.nvim_buf_get_option(0, "filetype")
	if not (ft == "c" or ft == "cpp") then
		vim.api.nvim_err_writeln("Current buffer is not C/C++ file.")
		return
	end

	local cwd = vim.loop.cwd()
	assert(cwd, "Cannot get cwd")

	local utils = require("armkn.utils")

	local headers_dir = utils.find_dir_in_ancestors(cwd, "include")
	if headers_dir == nil then
		vim.api.nvim_err_writeln("Cannot find `include/` in ancestors.")
		return
	end

	local cmd = {
		"find",
		headers_dir,
		"-follow",
		"-type",
		"f",
		"-printf",
		"%P\n",
		"-name",
		"*.hpp",
		"-o",
		"-name",
		"*.h",
	}

	--- @param lines table<string>
	--- @return integer
	local function index_of_last_include_directive(lines)
		for i, line in ipairs(lines) do
			if line:sub(1, #"#include") ~= "#include" then
				return i
			end
		end
		return 1
	end

	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	require("telescope.pickers")
		.new(opts, {
			prompt_title = "C/C++ header files",
			finder = require("telescope.finders").new_oneshot_job(cmd, opts),
			previewer = conf.file_previewer(opts),
			sorter = conf.file_sorter(opts),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
					local linenr = index_of_last_include_directive(lines)
					local cursor = vim.api.nvim_win_get_cursor(0)
					vim.api.nvim_win_set_cursor(0, { linenr, 0 })
					vim.api.nvim_put({ "#include <" .. selection[1] .. ">" }, "l", false, false)
					vim.api.nvim_win_set_cursor(0, { cursor[1] + 1, cursor[2] })
				end)
				return true
			end,
		})
		:find()
end

return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		version = false, -- telescope did only one release, so use HEAD for now
		keys = {
			{ "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
			{
				"<leader>/",
				telescope_builtin("live_grep", { additional_args = { "--hidden" } }),
				desc = "Find in Files (Grep)",
			},
			{ "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
			{ "<leader><space>", telescope_builtin("files"), desc = "Find Files (root dir)" },
			-- find
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>ff", telescope_builtin("files"), desc = "Find Files (root dir)" },
			{ "<leader>fF", telescope_builtin("files", { cwd = false }), desc = "Find Files (cwd)" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
			{ "<leader>fh", c_cpp_header_files, desc = "Find C/C++ headers & insert #include <...>" },
			-- git
			{ "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
			{ "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },
			-- search
			{ "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
			{ "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
			{ "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
			{ "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
			{ "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
			{ "<leader>sg", telescope_builtin("live_grep"), desc = "Grep (root dir)" },
			{ "<leader>sG", telescope_builtin("live_grep", { cwd = false }), desc = "Grep (cwd)" },
			{ "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
			{ "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
			{ "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
			{ "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
			{ "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
			{ "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
			{ "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
			{ "<leader>sw", telescope_builtin("grep_string"), desc = "Word (root dir)" },
			{ "<leader>sW", telescope_builtin("grep_string", { cwd = false }), desc = "Word (cwd)" },
			-- ui
			{
				"<leader>uC",
				telescope_builtin("colorscheme", { enable_preview = true }),
				desc = "Colorscheme with preview",
			},
			{
				"<leader>ss",
				telescope_builtin("lsp_document_symbols", {
					symbols = {
						"Class",
						"Function",
						"Method",
						"Constructor",
						"Interface",
						"Module",
						"Struct",
						"Trait",
						"Field",
						"Property",
					},
				}),
				desc = "Goto Symbol",
			},
			{
				"<leader>sS",
				telescope_builtin("lsp_dynamic_workspace_symbols", {
					symbols = {
						"Class",
						"Function",
						"Method",
						"Constructor",
						"Interface",
						"Module",
						"Struct",
						"Trait",
						"Field",
						"Property",
					},
				}),
				desc = "Goto Symbol (Workspace)",
			},
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
