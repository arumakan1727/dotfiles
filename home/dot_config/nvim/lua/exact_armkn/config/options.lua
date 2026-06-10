local g = vim.g
local o = vim.o
local opt = vim.opt

-- builtin プラグインの無効化は lazy の performance.rtp.disabled_plugins 側で行う
-- (config/lazy.lua を参照)。ここは純粋な vim option のみ。

-- リーダーキーは lazy の読み込み前に決める必要があるので keymaps.lua より前のここで定義
g.mapleader = " "
g.maplocalleader = ","

-- Encoding
o.encoding = "utf-8"
o.fileencodings = "ucs-bom,utf-8,euc-jp,iso-2022-jp,cp932,sjis,latin1"
o.fileformats = "unix,dos,mac"

-- Ex command
o.history = 10000
o.wildignorecase = true
o.wildmode = "full:longest,full"
opt.wildoptions:append("pum")

-- IO Behavior
o.autoread = true
o.hidden = true
o.confirm = true

-- Timeout
o.timeoutlen = 500
o.ttimeoutlen = 10
o.updatetime = 250 -- CursorHold / gitsigns / snacks.words の追従を速く

-- Completion (blink.cmp が menu を持つが、native 補完・cmdline 用に整えておく)
o.completeopt = "menu,menuone,noselect"
o.pumheight = 12

-- Format
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 0
o.expandtab = true
o.autoindent = true
o.smartindent = false
o.fixendofline = true
opt.formatoptions:append("m") -- マルチバイト文字の前後でも改行整形を許可

-- Invisible chars
o.list = true
o.listchars = "tab:» ,trail:･,nbsp:%"

-- Search
o.ignorecase = true
o.smartcase = true
o.inccommand = "split" -- :s のライブプレビュー

-- Split
o.splitbelow = true
o.splitright = true

-- Backup / Swap / Undo
o.backup = true
o.backupdir = vim.fn.stdpath("state") .. "/backup//"
vim.fn.mkdir(o.backupdir, "p")
o.swapfile = false
o.undofile = true -- 永続 undo(セッションを跨いで undo 履歴を保持)

-- Clipboard
opt.clipboard:prepend({ "unnamedplus", "unnamed" })

-- Misc
o.spelllang = "en,cjk"
o.switchbuf = "useopen,uselast"
o.sessionoptions = "buffers,curdir,tabpages,winsize"
opt.diffopt:append({ "vertical", "algorithm:histogram", "indent-heuristic", "linematch:60" })

-- Coloring
o.synmaxcol = 320
o.background = "dark"
o.termguicolors = true

-- UI, Visual, Display
o.cursorline = true
o.cursorcolumn = true
o.showmode = false -- mode は statusline で表示
o.showmatch = true
o.matchtime = 1
o.number = true
o.relativenumber = false
o.wrap = true
o.title = true
o.scrolloff = 5
o.sidescrolloff = 5
o.mouse = "a"
o.signcolumn = "yes"
o.winborder = "rounded" -- 0.11+: floating window(hover / blink / picker)の枠

-- Fold (0.10+ の native treesitter folding)
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = "" -- 折りたたみ行も syntax highlight したまま表示
o.foldlevel = 99
o.foldlevelstart = 99 -- 起動時は全 fold を開いておく

-- Window
o.laststatus = 3 -- グローバル statusline(分割しても最下部に1本)
o.showtabline = 2 -- tabline(bufferline)を常時表示
opt.fillchars = {
  foldopen = "▾",
  foldclose = "▸",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
  vert = "┃",
  vertleft = "┫",
  vertright = "┣",
  verthoriz = "╋",
}
