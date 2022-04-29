local o = vim.o
local opt = vim.opt

-- Ex command
o.history = 10000  -- コマンド履歴,検索履歴の記憶件数
o.wildmenu = true  -- コマンド補完を強化
o.wildignorecase = true  -- コマンド補完で大文字小文字を区別しない
o.wildmode = "full:longest,full"  -- 最長のマッチまで補完して候補を縦に列挙→タブで候補選択
opt.wildoptions:append("pum")

-- Timeout
o.timeout = true
o.timeoutlen = 500  -- マッピングを無効にするタイムアウト時間
o.ttimeoutlen = 10  -- <Left> 等は複数の制御キーコードの列として与えられうる。この「キーコード列」と「実際に逐次キータイプしたもの」を区別するためのしきい値。
o.updatetime = 2000  -- used for CursorHold autocommand event

-- Completions
opt.complete:append("k") -- 補完に辞書ファイル追加
o.completeopt = "menuone,noselect,noinsert"

-- Indent
o.tabstop = 2  -- タブ文字の画面上での表示幅
o.shiftwidth = 2  -- cindentやautoindent時に挿入されるインデント幅
o.softtabstop = 0  -- Tabキー押下時に挿入される空白文字数, 0の場合はtabstopと同じ, BSにも影響する
o.expandtab = true
o.autoindent = true
o.smartindent = false

-- Invisible chars
o.list = true  -- 不可視文字を表示する
o.listchars = "tab:»»,trail:･"  -- タブ文字と末尾の空白文字

-- Search
o.wrapscan = true -- 最後まで検索したら先頭へ戻る
o.ignorecase = true -- 大文字小文字無視
o.smartcase = true -- 大文字ではじめたら大文字小文字無視しない
o.incsearch = true -- インクリメンタルサーチ
o.hlsearch = true -- 検索文字をハイライト
o.inccommand = "split" -- 置換のリアルタイムプレビューを別ウィンドウに分割して表示

-- Split
o.splitbelow = true -- 新しい分割ウィンドウは下へ
o.splitright = true -- 新しい分割ウィンドウは右へ

-- File
o.autoread = true -- 他で書き換えられたら自動で読み直す
o.hidden = true -- 編集中でも他のファイルを開けるようにする
o.modeline = true -- ファイル末尾のmodeline読み込みを許可
o.confirm = true -- 未保存のときに確認する
-- o.autochdir = true -- ファイルのディレクトリに移動

-- Backup
o.backup = true
o.backupdir = vim.fn.stdpath("data") .. "/backup/"
vim.fn.mkdir(o.backupdir, "p")
o.backupskip = ""

-- Swapfile
o.swapfile = false
o.updatecount = 100  -- この数だけ打鍵する度ににスワップファイル作成
o.directory = vim.fn.stdpath("data") .. "/swap/"
vim.fn.mkdir(o.directory, "p")

-- Undo
o.undofile = true
o.undodir = vim.fn.stdpath("data") .. "/undo/"
vim.fn.mkdir(o.undodir, "p")

-- Input
o.backspace = "indent,eol,start" -- バックスペースでなんでも消せるように
opt.formatoptions:append("m") -- 整形オプション，マルチバイト系を追加
o.fixendofline = false  -- テキストファイル保存時に、末尾に改行を自動挿入しない

-- Clipboard
--    +レジスタ：Ubuntuの[Ctrl-v]で貼り付けられるもの unnamedplus
--    *レジスタ：マウスのミドルクリックで貼り付けられるもの unnamed
opt.clipboard:prepend("unnamedplus", "unnamed")

-- Beep
o.errorbells = false
o.visualbell = false

-- Misc
o.spelllang = "en,cjk"
o.switchbuf = "useopen,uselast"
o.sessionoptions = "buffers,curdir,tabpages,winsize"
o.diffopt = o.diffopt .. ",vertical,internal,algorithm:patience,iwhite,indent-heuristic"

-- Syntax highlight
o.synmaxcol = 300
vim.cmd "syntax enable"
o.t_Co = 256
o.background = "dark"
vim.g.vimsyn_embed = "l" -- 埋め込みluaコードのハイライトを有効化

-- True color support
vim.g.colorterm = os.getenv("COLORTERM")
if (vim.g.colorterm == "truecolor" or vim.g.colorterm == "24bit" or vim.g.colorterm == "") then
	if vim.fn.exists("+termguicolors") then
		o.t_8f = "<Esc>[38;2;%lu;%lu;%lum"
		o.t_8b = "<Esc>[48;2;%lu;%lu;%lum"
		o.termguicolors = true
	end
end

-- UI, Visual, Display
o.cursorline = true -- 現在行をハイライト
o.display = "lastline" -- 長い行も一行で収まるように
o.showmode = false
o.showmatch = true -- 括弧の対応をハイライト
o.matchtime = 1 -- 括弧の対を見つけるミリ秒数
o.showcmd = true -- 入力中のコマンドを表示
o.number = true -- 行番号表示
o.relativenumber = false  -- 行番号の表示を現在行からの相対値にしない
o.wrap = true -- 画面幅で折り返す
o.title = true -- ウィンドウのタイトルを設定する
o.scrolloff = 8  -- 上下方向のカーソルのゆとり行数
o.sidescrolloff = 5  -- 左右方向のカーソルのゆとり行数
o.pumblend = 0  -- ポップアップの透明度
o.pumheight = 10 -- 補完候補の表示数
o.mouse = "a"  -- 全てのマウス操作有効化
o.conceallevel = 0  -- JSONなどでダブルクォートが隠されるのを抑制
o.showtabline = 2  -- tablineを常に表示
o.signcolumn = "yes"

-- Fold (コード折りたたみ)
-- o.foldmethod="marker"
o.foldmethod = "manual"
o.foldlevel = 1
o.foldlevelstart = 99
vim.w.foldcolumn = "0:"

-- Cursor style
o.guicursor = "n-v-c-sm:block-Cursor/lCursor-blinkon0,i-ci-ve:ver25-Cursor/lCursor,r-cr-o:hor20-Cursor/lCursor"

-- Status line
o.laststatus = 3  -- ウィンドウ分割してもステータスラインは画面全体の下部(last)にのみ表示
o.shortmess = "aItToOF"
opt.fillchars = {
	horiz = "━",
	horizup = "┻",
	horizdown = "┳",
	vert = "┃",
	vertleft = "┫",
	vertright = "┣",
	verthoriz = "╋",
}
