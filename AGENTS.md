# AGENTS.md

エージェント向けメモ。`CLAUDE.md` はこのファイルへの symlink。
構成やコードを少し読めば分かることは書かない。非自明な原則・落とし穴・規約だけを記す。

## Principle (最優先・すべての変更がこれに従う)

1. **サプライチェーンに細心の注意**
   - バージョン / コミットハッシュを固定し、チェックサムで検証してから取得する。`curl | sh` のような未検証パイプは禁止。
   - 信頼の起点は「同一リリース同梱の checksums」ではなく**自リポジトリに人手でレビューして保管した sha256**(`installer/pinned.toml`)。後からリリースが改竄されてもバイト列の変化で検知できる。
   - 外部スクリプトを取得して実行する場合も取得元を `main`/`HEAD` でなく commit / tag で固定する。
   - **minimumReleaseAge 相当のリリース年齢ポリシーを必ず効かせる**(出来たてリリース経由の汚染回避): mise=`MISE_INSTALL_BEFORE=7d`、uv=`UV_EXCLUDE_NEWER=P7D`、pnpm=`minimumReleaseAge`、pip 等も同様。設定を勝手に外さない。
   - 入れられるものは極力 mise に寄せる(aqua のチェックサム検証 + lockfile + 上記 age ポリシーを継承できる)。新規ツール追加時は lockfile をコミット。ピン更新は age ポリシーを尊重し、原則ダウングレードしない。
   - 新規依存は正当性を確認してから追加(低人気・無名パッケージを避ける)。

2. **冪等**
   - installer / run_once / セットアップ系はすべて再実行安全に書く(存在チェックやバージョン一致で skip し、二重適用・破壊をしない)。
   - 「先に作って原子的に差し替え」を基本にし、途中失敗で実環境が壊れない順序にする。

3. **ポータビリティ (Linux と macOS。Windows 非対象)**
   - OS 分岐は chezmoi テンプレート(`.chezmoi.os`)と `.chezmoiignore`(テンプレート)で行う。一方の OS 専用ツリーは他方で ignore する。
   - シェル設定は未導入ツールに耐えるよう `command -v` でガードする。
   - macOS / GNU の非互換に注意(例: `readlink -f` は macOS 非対応 → `realpath` を使う)。

4. **Homebrew は最終手段(macOS)**
   - CLI は mise を最優先。brew は GUI cask / mas / `pinentry-mac` 等、mise でも検証取得でも賄えないものだけに絞る。

## chezmoi

- 編集フロー: source を直接いじらず `chezmoi edit <target>` → `chezmoi apply`。実環境を直接編集したら `chezmoi add <path>` で source へ取り込み直す。
- 追跡停止は `chezmoi forget <target>` + `.chezmoiignore` に**ターゲット相対**(`dot_` 等の属性接頭辞を付けない)パターンを追加。`git rm --cached` ではない。
- `.chezmoiignore` 自体がテンプレートとして評価される。
- `Brewfile` は repo ルート(= source ディレクトリの一つ上)にある。run_once から参照するときは `$(dirname {{ .chezmoi.sourceDir }})`。
- run_once の `mise install` は `DOTFILES_SKIP_MISE_INSTALL=1` でスキップできる(CI/テスト用の knob)。
- **テスト目的でも実環境の home に `chezmoi apply` しない**。run_once(brew bundle / `mise install` / macOS defaults)が発火する。Linux 再現性検証は `make test/linux[/full]`(Docker)で行う。

## Line endings

- `.gitattributes` 無し・`core.autocrlf=input` + `core.safecrlf=true`。`.gitignore` や `*.tmpl` など LF で index に入っているファイルに Edit が CRLF を混ぜると `git add` が "CRLF would be replaced by LF" で失敗する。`perl -i -pe 's/\r\n/\n/g' <file>` で直してからステージする。

## Sensitive / gotchas

- `~/.config/pip/pip.conf`: index-url にトークンが入る。リポジトリにも chezmoi source にも入れない(`.chezmoiignore` の `.config/pip/`)。**絶対に `chezmoi add` しない**。
- `mise/npmrc`(mise 公式設定ではない): `.zshrc` の `mise()` ラッパが `mise use|install npm:*` のときだけ `NPM_CONFIG_USERCONFIG` として読み込む。`~/.npmrc` の `min-release-age` と `MISE_INSTALL_BEFORE` が npm 11 で衝突するのを回避するため。レジストリは Flatt Security Takumi Guard(外部 SaaS・公開可)。
- `karabiner.json`: Karabiner-Elements が保存時に独自インデントで書き戻し、空白だけの巨大 diff を出す。`git diff -w` で実差分を確認し、コミットメッセージで明示する。

## Shell init (zsh) — 非自明な点のみ

- `.zshenv`: 環境変数のみ。`MANPAGER`/`EDITOR` は `${VAR:-default}` で親から注入された値を尊重する(Claude Code の `settings.json` `env.MANPAGER` がこれに依存)。
- `.zshrc`: PATH/fpath/manpath は macOS `/etc/zprofile` の `path_helper` の**後**に組む(先頭で `path=()` リセット)。sheldon は未導入なら自己インストールし `zsh-defer` を供給する。mise/zoxide/workmux は出力をファイルキャッシュして `zsh-defer` で遅延ロード。`compinit -C` は同期実行(遅延断片で再実行しない)。`mise()` ラッパが `npm:` を含む `use|install|...` を傍受して npmrc を差し込む(上記 Sensitive 参照)。
- `.bashrc` は zsh 相当を `command -v` ガードでミラーする。

## mise

- ツール指定は registry の短縮名(`rg`, `fd`, `gh`, `neovim` …)を優先。短縮名が無いものだけ `aqua:owner/repo` にフォールバックし、理由をコメントで残す。
- `aws-cli` は `aqua:aws/aws-cli`(aqua は .pkg でなく v2 バイナリを入れるので起動が速い)。

## Commits

- 件名: lowercase scope + colon(`zsh:`, `mise:`, `chezmoi:`, `chore:` …)。命令形・末尾ピリオド無し。本文は任意・~72 折り返し。
- ドキュメントには実ユーザ名入りの絶対パスを書かない(リポジトリ/ファイルからの相対パスで書く)。
