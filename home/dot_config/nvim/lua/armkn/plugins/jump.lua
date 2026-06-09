return {
	{
		"ggandor/flit.nvim",
		keys = {
			{ "f", mode = { "n", "x", "o" }, desc = "f" },
			{ "F", mode = { "n", "x", "o" }, desc = "F" },
			{ "t", mode = { "n", "x", "o" }, desc = "t" },
			{ "T", mode = { "n", "x", "o" }, desc = "T" },
		},
		opts = { labeled_modes = "nx" },
	},
	{
		"ggandor/leap.nvim",
		keys = {
			{ "gj", "<Plug>(leap-forward-to)", mode = { "n", "x", "o" }, noremap = true, desc = "Leap forward to" },
			{ "gk", "<Plug>(leap-backward-to)", mode = { "n", "x", "o" }, noremap = true, desc = "Leap backward to" },
			{ "gs", "<Plug>(leap-from-window)", mode = { "n", "x", "o" }, noremap = true, desc = "Leap from windows" },
		},
		config = function(_, opts)
			local leap = require("leap")
			for k, v in pairs(opts) do
				leap.opts[k] = v
			end
			leap.add_default_mappings(false)
		end,
	},
}
