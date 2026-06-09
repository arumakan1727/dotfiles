# Brewfile — macOS 専用。Homebrew は最終手段(AGENTS.md Principle 4)。
# CLI は極力 mise(aqua のチェックサム検証 + mise.lock + age policy)へ寄せ、
# ここには mise / aqua で検証取得できないものだけを残す。
#
# 手動キュレーション方針: `brew bundle dump` は leaf + 依存ライブラリを全部
# 書き戻して下のカテゴリ分類を破壊するので使わない(Makefile からも廃止済み)。
# 追加・削除は手で行い、`make brew/install`(--no-upgrade)で反映する。
# 純粋な依存ライブラリ(glib/pango/poppler 等)は明示しない。依存元(下の
# leaf や cask)を入れれば Homebrew が自動解決する。

# --- taps ---------------------------------------------------------------------
# homebrew/bundle・homebrew/services は modern Homebrew でコア統合され不要。
tap "espanso/espanso"      # cask "espanso"
tap "xcodesorg/made"       # xcodes

# --- GNU 版コアツール(macOS の BSD 版との非互換回避。PATH 優先で使う)---------
brew "bash"                # macOS 同梱は 3.2 と古い
brew "coreutils"
brew "findutils"
brew "diffutils"
brew "gawk"
brew "gnu-sed"
brew "gnu-tar"
brew "grep"
brew "gzip"

# --- シェル / ターミナル -------------------------------------------------------
brew "fish"
brew "tmux"
brew "sheldon"             # zsh plugin manager(.zshrc も未導入なら自己インストール)

# --- GPG / 認証(mise 不可。pinentry-mac は run_once_30 が gpg-agent に結線)----
brew "gnupg"
brew "pinentry-mac"

# --- DB サーバ(ビルド / サービス管理が必要。mise 不可)-----------------------
brew "mariadb"
brew "postgresql@14"

# --- C/C++ 開発(mise/aqua に検証取得経路が無い or 巨大)-----------------------
brew "llvm"
brew "clang-format"        # aqua 経路が conda/asdf のみ。検証取得が弱いため brew
brew "cppcheck"

# --- メディア / 画像 / PDF(CLI として直接使う。依存ライブラリは自動解決)------
brew "imagemagick"
brew "ffmpeg"
brew "ghostscript"
brew "gnuplot"
brew "tesseract"           # OCR

# --- ネットワーク / システム CLI ----------------------------------------------
brew "tailscale"
brew "wget"
brew "aria2"
brew "netcat"
brew "telnet"
brew "nmap"
brew "yt-dlp"              # aqua-registry に無く更新も頻繁なので brew 据え置き
brew "htop"
brew "mactop"
brew "tree"
brew "pstree"
brew "moreutils"

# --- ファイル / アーカイブ / 変換 ----------------------------------------------
brew "p7zip"
brew "sevenzip"
brew "unzip"
brew "nkf"
brew "exiftool"
brew "translate-shell"

# --- 雑多なユーティリティ ------------------------------------------------------
brew "libqalculate"        # qalc(電卓)
brew "pwgen"
brew "qrencode"
brew "zbar"                # QR / バーコード decode
brew "lolcat"
brew "ascii"

# --- mise に寄せられない(brew でしか arm native / 最新を取れない)------------
brew "ttyd"                # web terminal。Rust でなく cargo 不可、aqua も darwin 非対応
brew "silicon"             # コードのスクショ。cargo だと Intel/Rosetta・旧版になるため brew(arm native)

# --- tap 固有 ------------------------------------------------------------------
brew "xcodesorg/made/xcodes"

# === cask / vscode(formula 中心に棚卸し)====================================
cask "alacritty"
cask "aquaskk"
cask "arto"
cask "discord"
cask "espanso"
cask "firefox"
cask "ghostty"
cask "inkscape"
cask "iterm2"
cask "keycastr"
cask "obs"
cask "obsidian"
cask "swift-shift"
cask "unnaturalscrollwheels"
cask "visual-studio-code"
cask "vlc"
cask "warp"
cask "wezterm"
cask "wireshark"
cask "wireshark-app"
