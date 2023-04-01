local MY_GROUP = "vimrc_pluginconfig"
vim.api.nvim_create_augroup(MY_GROUP, { clear = true })

-- on startup
require "rc/pluginconfig/on_launch"

require("luasnip.loaders.from_snipmate").lazy_load({paths = "~/.config/nvim/snippets"})

-- on VimEnter (after startup)
vim.api.nvim_create_autocmd("VimEnter", {
	group = MY_GROUP,
	once = true,
	callback = function()
		require "rc/pluginconfig/after_launch"
		require "rc/pluginconfig/completion"
	end,
})
