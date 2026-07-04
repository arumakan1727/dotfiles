-- プラグイン由来のキーマップは各 plugin spec(keys / LspAttach 等)側に置く。
-- ここは plugin 非依存のコアキーマップのみ。leader 定義は options.lua にある。

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 表示行単位で上下移動(折り返し行を考慮)
map({ "n", "v" }, "j", "gj", opts)
map({ "n", "v" }, "k", "gk", opts)

-- Copy / Delete
map("n", "Y", "y$", opts)
map("n", "<Leader>y", "<Cmd>%yank<CR>", opts)
map("n", "x", '"_x', opts) -- x はレジスタを汚さない

-- ハイライト消去
map("n", ",<Esc>", "<Cmd>nohlsearch<CR>", opts)
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", opts)

-- 挿入モードでこまめに undo 区切りを打つ
map("i", "<CR>", "<C-g>u<CR>", opts)
map("i", "<C-w>", "<C-g>u<C-w>", opts)
map("i", "<C-u>", "<C-g>u<C-u>", opts)

-- Emacs 風カーソル移動(command-line モード。silent=false でないと動かない)
map("c", "<C-a>", "<Home>", { noremap = true, silent = false })
map("c", "<C-e>", "<End>", { noremap = true, silent = false })
map("c", "<C-f>", "<Right>", { noremap = true, silent = false })
map("c", "<C-b>", "<Left>", { noremap = true, silent = false })
map("c", "<C-h>", "<BS>", { noremap = true, silent = false })
map("c", "<C-d>", "<Del>", { noremap = true, silent = false })

-- Emacs 風カーソル移動(挿入モード)
map("i", "<C-a>", "<Home>", opts)
map("i", "<C-e>", "<End>", opts)
map("i", "<C-f>", "<Right>", opts)
map("i", "<C-b>", "<Left>", opts)
map("i", "<C-h>", "<BS>", opts)
map("i", "<C-d>", "<Del>", opts)

-- quickfix / location / buffer / tab の移動
-- ([d/]d 診断ジャンプは LSP の native default、[h/]h hunk は gitsigns 側)
map("n", "[q", "<Cmd>cprevious<CR>", opts)
map("n", "]q", "<Cmd>cnext<CR>", opts)
map("n", "[l", "<Cmd>lprevious<CR>", opts)
map("n", "]l", "<Cmd>lnext<CR>", opts)
map("n", "[b", "<Cmd>bprevious<CR>", opts)
map("n", "]b", "<Cmd>bnext<CR>", opts)
map("n", "[t", "<Cmd>tabprevious<CR>", opts)
map("n", "]t", "<Cmd>tabnext<CR>", opts)

-- 現在バッファのパスをクリップボード("+, unnamedplus)へコピー
map("n", "<Leader>fy", function()
  local name = vim.fn.expand("%:t")
  if name == "" then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", name)
  vim.notify("Copied: " .. name)
end, { desc = "Copy file name" })

map("n", "<Leader>fY", function()
  local abs = vim.fn.expand("%:p")
  if abs == "" then
    vim.notify("No file path", vim.log.levels.WARN)
    return
  end
  local root = vim.fs.root(abs, ".git")
  -- root 配下なら repo 相対、外なら cwd/home 相対にフォールバック
  local path = root and abs:sub(#root + 2) or vim.fn.fnamemodify(abs, ":~:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy repo-relative path" })

-- Window 操作(<Leader>w を <C-w> のエイリアスに)
map("n", "<Leader>w", "<C-w>", { noremap = true })

-- Terminal
map("t", "<Esc>", [[<C-\><C-n>]], opts)
