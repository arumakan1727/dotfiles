local MY_GROUP = "armkn_highlight"
vim.api.nvim_create_augroup(MY_GROUP, { clear = true })

vim.fn.matchadd("ArmknTrailSpace", [[\s\+$]])

-- ColorScheme ロード後の highlight カスタマイズ
vim.api.nvim_create_autocmd("ColorScheme", {
	group = MY_GROUP,
	callback = function()
		vim.cmd([[hi ArmknTrailSpace guifg=red ctermfg=red]])
	end,
})
