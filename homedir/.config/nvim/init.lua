require("armkn.rc.base")
require("armkn.rc.commands")
require("armkn.rc.keymaps")
require("armkn.rc.autocmd")
require("armkn.rc.highlight")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("armkn.plugins")
