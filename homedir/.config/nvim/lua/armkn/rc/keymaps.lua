local keymap = vim.keymap
local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Cursor move
keymap.set({ "n", "v" }, "j", "gj", opts)
keymap.set({ "n", "v" }, "k", "gk", opts)

-- Copy
keymap.set("n", "Y", "y$", opts)
keymap.set("n", "<Leader>y", "<Cmd>%yank<CR>", opts)
keymap.set("n", "x", '"_x', opts)

-- Buffer
keymap.set("n", "<Leader>bd", "<Cmd>bdelete!<CR>", opts)

-- Window
keymap.set("n", "<Leader>w", "<C-w>", opts)

-- Clear highlight
keymap.set("n", ",<Esc>", "<Cmd>nohlsearch<CR>", opts)

-- Undo trigger
keymap.set("i", "<CR>", "<C-g>u<CR>", opts)
keymap.set("i", "<C-w>", "<C-g>u<C-w>", opts)
keymap.set("i", "<C-u>", "<C-g>u<C-u>", opts)

-- Emacs style (command mode)
-- Note: silent=false にしないとうまく動かない (2022.04.29時点)
keymap.set("c", "<C-a>", "<Home>", { noremap = true, silent = false })
keymap.set("c", "<C-e>", "<End>", { noremap = true, silent = false })
keymap.set("c", "<C-f>", "<Right>", { noremap = true, silent = false })
keymap.set("c", "<C-b>", "<Left>", { noremap = true, silent = false })
keymap.set("c", "<C-h>", "<BS>", { noremap = true, silent = false })
keymap.set("c", "<C-d>", "<Del>", { noremap = true, silent = false })

-- Emacs style (insert mode)
keymap.set("i", "<C-a>", "<Home>", opts)
keymap.set("i", "<C-e>", "<End>", opts)
keymap.set("i", "<C-f>", "<Right>", opts)
keymap.set("i", "<C-b>", "<Left>", opts)
keymap.set("i", "<C-h>", "<BS>", opts)
keymap.set("i", "<C-d>", "<Del>", opts)

-- Moving
keymap.set("n", "[q", "<Cmd>cprevious<CR>", opts)
keymap.set("n", "]q", "<Cmd>cnext<CR>", opts)
keymap.set("n", "[l", "<Cmd>lprevious<CR>", opts)
keymap.set("n", "]l", "<Cmd>lnext<CR>", opts)
keymap.set("n", "[b", "<Cmd>bprevious<CR>", opts)
keymap.set("n", "]b", "<Cmd>bnext<CR>", opts)
keymap.set("n", "[t", "<Cmd>tabprevious<CR>", opts)
keymap.set("n", "]t", "<Cmd>tabnext<CR>", opts)

-- Scrolling; プラグインの Telescope で z を使うので代わりに gz で使えるように
-- https://vim-jp.org/vimdoc-ja/scroll.html
keymap.set("n", "gzz", "zz", opts)
keymap.set("n", "gzt", "zt", opts)
keymap.set("n", "gzb", "zb", opts)

-- Terminal
keymap.set("t", "<ESC>", [[<C-\><C-n>]], opts)
