local MY_GROUP = "vimrc_autocmds"
vim.api.nvim_create_augroup(MY_GROUP, { clear = true })

local create_autocmd = vim.api.nvim_create_autocmd

-- フォーカス中の window でのみ現在行・現在列をハイライト
create_autocmd("WinEnter", { group=MY_GROUP, command="setlocal cursorline cursorcolumn" })
create_autocmd("WinLeave", { group=MY_GROUP, command="setlocal nocursorline nocursorcolumn" })

-- shebang が指定されているファイルを保存したら実行可能フラグを付与する
create_autocmd("BufWritePost", {
	group = MY_GROUP,
	callback = function()
		local head = vim.fn.getline(1)
		local filepath = vim.fn.fnamemodify(vim.fn.expand('%'), ':p')
		local is_executable = vim.fn.executable(filepath) == 1
		if vim.startswith(head, "#!") and head:find("/bin/") and not is_executable then
			vim.cmd("! chmod u+x " .. filepath)
		end
	end,
})

-- Vim がフォーカスされたらファイルのタイムスタンプをチェック (autoread)
create_autocmd("FocusGained", { group=MY_GROUP, command="checktime" })

-- ヤンク (コピー) した領域を少しの時間だけハイライト
vim.api.nvim_create_autocmd("TextYankPost", {
	group = MY_GROUP,
	callback = function()
		vim.highlight.on_yank({
			higroup = (vim.fn.hlexists("HighlightedyankRegion") > 0 and "HighlightedyankRegion" or "Visual"),
			timeout = 200,
		})
	end,
})

-- 前回閉じた時点の位置にカーソルを移動
vim.api.nvim_create_autocmd("BufRead", {
	group = MY_GROUP,
	callback = function ()
		local last_row = vim.fn.line([['"]])
		if last_row > 0 and last_row <= vim.fn.line("$") then
			vim.cmd [[normal g`"]]
		end
	end
})
