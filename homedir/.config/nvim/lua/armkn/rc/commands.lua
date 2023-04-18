vim.api.nvim_create_user_command("StripWhitespaces", function()
	local curpos = vim.api.nvim_win_get_cursor(0)
	vim.cmd([[keeppatterns %s/\s\+$//]])
	vim.api.nvim_win_set_cursor(0, curpos)
end, {})
