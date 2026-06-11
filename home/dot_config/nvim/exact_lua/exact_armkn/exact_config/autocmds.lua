local augroup = vim.api.nvim_create_augroup("armkn_autocmds", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- フォーカス中の window でのみ現在行・現在列をハイライト
autocmd({ "WinEnter", "BufWinEnter" }, {
  group = augroup,
  command = "setlocal cursorline cursorcolumn",
})
autocmd("WinLeave", {
  group = augroup,
  command = "setlocal nocursorline nocursorcolumn",
})

-- 行末の空白を赤く表示(window ごとに matchadd)。listchars の trail に加え視認性を上げる
autocmd("ColorScheme", {
  group = augroup,
  callback = function()
    vim.api.nvim_set_hl(0, "ArmknTrailSpace", { bg = "#ff5555" })
  end,
})
autocmd({ "WinNew", "BufWinEnter" }, {
  group = augroup,
  callback = function(ev)
    -- フローティングウィンドウ(lazy.nvim / blink.cmp などの UI)はノイズになるのでスキップ
    if vim.api.nvim_win_get_config(0).relative ~= "" then
      return
    end
    -- 通常のファイルバッファ以外(プラグイン UI などの特殊 buftype)もスキップ
    if vim.bo[ev.buf].buftype ~= "" then
      return
    end
    if vim.fn.exists("w:armkn_trail_match") == 0 then
      vim.w.armkn_trail_match = vim.fn.matchadd("ArmknTrailSpace", [[\s\+$]])
    end
  end,
})

-- ヤンク領域を一瞬ハイライト(vim.hl は 0.11+ の名前。vim.highlight は deprecated)
autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Vim がフォーカスされたらファイルのタイムスタンプを再チェック(autoread の補助)
autocmd("FocusGained", { group = augroup, command = "checktime" })

-- 前回閉じた位置にカーソルを復元
autocmd("BufReadPost", {
  group = augroup,
  callback = function(ev)
    local exclude = { "gitcommit", "gitrebase" }
    if vim.tbl_contains(exclude, vim.bo[ev.buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- shebang(#!/...)付きファイルを保存したら実行可能フラグを付与
autocmd("BufWritePost", {
  group = augroup,
  callback = function(ev)
    if not vim.startswith(vim.fn.getline(1), "#!/") then
      return
    end
    local filename = vim.fn.fnamemodify(ev.file, ":t")
    if vim.startswith(filename, ".") then
      return
    end
    local abspath = vim.fn.fnamemodify(ev.file, ":p")
    if not vim.startswith(abspath, "/tmp/") and vim.fn.executable(abspath) ~= 1 then
      pcall((vim.uv or vim.loop).fs_chmod, abspath, tonumber("755", 8))
    end
  end,
})

-- 一部のファイルタイプでは q で閉じられるようにする(help / quickfix / 各種 UI)
autocmd("FileType", {
  group = augroup,
  pattern = {
    "help",
    "qf",
    "man",
    "lspinfo",
    "checkhealth",
    "notify",
    "startuptime",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})

-- 末尾改行が無いファイルでも保存時に意図せず改行を増やさない(競プロ向け)
autocmd("FileType", {
  group = augroup,
  pattern = { "go", "lua", "tsv" },
  callback = function()
    vim.bo.expandtab = false
  end,
})
