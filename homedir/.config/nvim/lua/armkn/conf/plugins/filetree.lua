local function openRootDir()
	require("neo-tree.command").execute({ toggle = true, dir = require("armkn.utils").get_root() })
end

local function openCwd()
	require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
end

return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		cmd = "NeoTree",
		keys = {
			{ "<leader>e", openRootDir, desc = "NeoTree (root dir)" },
			{ "<leader>E", openCwd, desc = "NeoTree (cwd)" },
		},
		init = function()
			vim.g.neo_tree_remove_legacy_commands = 1
			if vim.fn.argc() == 1 then
				local stat = vim.loop.fs_stat(vim.fn.argv(0))
				if stat and stat.type == "directory" then
					require("neo-tree")
				end
			end
		end,
		opts = {
			filesystem = {
				bind_to_cwd = false,
				follow_current_file = true,
			},
			window = {
				mappings = {
					["<space>"] = "none",
				},
			},
			default_component_configs = {
				indent = {
					with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
			},
		},
	},
}
