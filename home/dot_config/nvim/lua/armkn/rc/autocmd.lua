local MY_GROUP = "armkn_autocmds"
vim.api.nvim_create_augroup(MY_GROUP, { clear = true })

local autocmd = vim.api.nvim_create_autocmd

-- フォーカス中の window でのみ現在行・現在列をハイライト
autocmd("WinEnter", { group = MY_GROUP, command = "setlocal cursorline cursorcolumn" })
autocmd("WinLeave", { group = MY_GROUP, command = "setlocal nocursorline nocursorcolumn" })

-- shebang が指定されているファイルを保存したら実行可能フラグを付与する
autocmd("BufWritePost", {
	group = MY_GROUP,
	callback = function()
		local line = vim.fn.getline(1)
		if not vim.startswith(line, "#!/") then
			return
		end

		local filename = vim.fn.expand("<afile>:t")
		if vim.startswith(filename, ".") then
			return
		end

		local abspath = vim.fn.expand("<afile>:p")
		if not vim.startswith(abspath, "/tmp/") and vim.fn.executable(abspath) ~= 1 then
			local res = vim.loop.fs_chmod(abspath, tonumber("755", 8))
			if res ~= true then
				error(res)
			end
		end
	end,
})

-- Vim がフォーカスされたらファイルのタイムスタンプをチェック (autoread)
autocmd("FocusGained", { group = MY_GROUP, command = "checktime" })

-- ヤンク (コピー) した領域を少しの時間だけハイライト
autocmd("TextYankPost", {
	group = MY_GROUP,
	callback = function()
		vim.highlight.on_yank({
			higroup = (vim.fn.hlexists("HighlightedyankRegion") > 0 and "HighlightedyankRegion" or "Visual"),
			timeout = 200,
		})
	end,
})

-- 前回閉じた時点の位置にカーソルを移動
autocmd("BufRead", {
	group = MY_GROUP,
	callback = function()
		local last_row = vim.fn.line([['"]])
		if last_row > 0 and last_row <= vim.fn.line("$") then
			vim.cmd([[normal g`"]])
		end
	end,
})
