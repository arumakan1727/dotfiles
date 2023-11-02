local g = vim.g
local o = vim.o
local opt = vim.opt

o.encoding = "utf-8"
o.fileencodings = "ucs-bom,utf-8,euc-jp,iso-2022-jp,cp932,sjis,latin1"
o.fileformats = "unix,dos,mac"

-- Skip builtin plugins
g.loaded_2html_plugin = 1
g.loaded_getscript = 1
g.loaded_getscriptPlugin = 1
g.loaded_gzip = 1
g.loaded_logiPat = 1
g.loaded_man = 1
g.loaded_matchit = 1
g.loaded_matchparen = 1
g.loaded_netrwFileHandlers = 1
g.loaded_netrwPlugin = 1
g.loaded_netrwSettings = 1
g.loaded_remote_plugins = 1
g.loaded_rplugin = 1
g.loaded_rrhelper = 1
g.loaded_shada_plugin = 1
g.loaded_shada_plugin = 1
g.loaded_spec = 1
g.loaded_spellfile_plugin = 1
g.loaded_spellfile_plugin = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1
g.loaded_tutor_mode_plugin = 1
g.loaded_vimball = 1
g.loaded_vimballPlugin = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
opt.runtimepath:remove("/etc/xdg/nvim")
opt.runtimepath:remove("/etc/xdg/nvim/after")
opt.runtimepath:remove("/usr/share/vim/vimfiles")

-- Ex command
o.history = 10000
o.wildmenu = true
o.wildignorecase = true
o.wildmode = "full:longest,full"
opt.wildoptions:append("pum")

-- IO Behavior
o.autoread = true
o.hidden = true
o.modeline = true
o.confirm = true

-- Timeout
o.timeout = true
o.timeoutlen = 500
o.ttimeoutlen = 10
o.updatetime = 2000

-- Completions
opt.complete:append("k")
o.completeopt = "menuone,noselect,noinsert"

-- Format
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 0
o.expandtab = true
o.autoindent = true
o.smartindent = false
g.editorconfig = true
o.fixendofline = true
opt.formatoptions:append("m") -- 整形オプション，マルチバイト系を追加

-- Invisible chars
o.list = true
o.listchars = "tab:» ,trail:･"

-- Search
o.wrapscan = true
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = true
o.inccommand = "split"

-- Split
o.splitbelow = true
o.splitright = true

-- Backup
o.backup = true
o.backupdir = vim.fn.stdpath("data") .. "/backup/"
vim.fn.mkdir(o.backupdir, "p")
o.backupskip = ""

-- Swapfile, Undofile
o.swapfile = false
o.undofile = false

-- Clipboard
opt.clipboard:prepend("unnamedplus", "unnamed")

-- Misc
o.spelllang = "en,cjk"
o.switchbuf = "useopen,uselast"
o.sessionoptions = "buffers,curdir,tabpages,winsize"
o.diffopt = o.diffopt .. ",vertical,internal,algorithm:patience,iwhite,indent-heuristic"
o.backspace = "indent,eol,start"

-- Coloring
o.synmaxcol = 300
o.background = "dark"
g.colorterm = os.getenv("COLORTERM")
o.termguicolors = true

-- UI, Visual, Display
o.cursorline = true
o.cursorcolumn = true
o.display = "lastline"
o.showmode = false
o.showmatch = true
o.matchtime = 1
o.showcmd = true
o.number = true
o.relativenumber = false
o.wrap = true
o.title = true
o.scrolloff = 5
o.sidescrolloff = 5
o.pumblend = 0
o.pumheight = 10
o.mouse = "a"
o.showtabline = 2 -- tablineを常に表示
o.signcolumn = "yes"

-- Fold
o.foldmethod = "manual"
o.foldlevel = 1
-- o.foldlevelstart = 99
vim.w.foldcolumn = "0:"

-- Window
o.laststatus = 3 -- ウィンドウ分割してもステータスラインは画面全体の下部(last)にのみ表示
opt.fillchars = {
	horiz = "━",
	horizup = "┻",
	horizdown = "┳",
	vert = "┃",
	vertleft = "┫",
	vertright = "┣",
	verthoriz = "╋",
}
