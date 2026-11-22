# AGENTS.md

エージェント向けメモ。`CLAUDE.md` はこのファイルへの symlink。
README / Makefile / 各スクリプトを読めば分かる手順や構成はそちらを優先し、ここには判断基準と落とし穴だけ残す。

## Principles

- **サプライチェーン攻撃対策**: version / commit / tag を固定し、自リポジトリに人手レビュー済み sha256 を置いて検証する。同一リリースに同梱された checksum は信頼の起点にしない。`curl | sh` や `main` / `HEAD` 参照は禁止。
- **リリース直後の取り込みを避ける**: mise `minimum_release_age=7d`(config.toml)、`UV_EXCLUDE_NEWER=P7D`、pnpm / npm / pip の minimumReleaseAge 相当を維持する。ピン更新はこの待機期間を尊重し、回避目的の downgrade はしない。
- **CLI は原則 mise**: aqua + lockfile + age policy に寄せる。新規依存は正当性を確認し、低人気・無名パッケージを避ける。
- **セットアップ系は冪等**: installer / run_onchange は再実行安全にし、存在・バージョン一致で skip する。実環境を触る変更は「先に作って原子的に差し替え」を基本にする。
- **Linux / macOS 両対応、Windows 非対象**: 配置有無の OS 分岐は `.chezmoiignore`、実行時分岐は `CHEZMOI_OS`。shell init は未導入ツールに耐えるよう `command -v` でガードする。macOS/GNU 差には注意し、`readlink -f` ではなく `realpath` などを使う。
- **Homebrew は macOS の最終手段**: CLI は mise 優先。`Brewfile` は手でキュレーションし、`brew bundle dump` は使わない。

## chezmoi

- テスト目的で実 home に `chezmoi apply` しない。brew / mise / macOS defaults / external が動く。Linux 検証は `make test/linux` / `make test/linux/full`、対話デバッグは `make test/linux/shell`。
- 追跡停止は `chezmoi forget <target>` + `.chezmoiignore` に target 相対パターンを追加する。`git rm --cached` ではない。
- `run_onchange` が監視するのは source ツリーだけ。`Brewfile` や `installer/` など source 外の変更で再実行したい場合は、既存テンプレートと同じ hash 行を入れる。macOS には `sha256sum` コマンドが無いので chezmoi のテンプレート関数として使う。
- `run_onchange` の hash 行は **生ソース**を見る。`include "<file>"` は生ソースを返すので、監視対象が `*.tmpl` で `[chezmoidata]` 等を参照し「**展開結果**の変化」で再実行させたいときは `includeTemplate "<path>" . | sha256sum`(第2引数 `.` で現在のデータスコープを渡す)を使う。逆に「リテラル変更」で再実行したいだけなら `include` が正しい(例: `50-fontcache` は font ピンの URL/sha 変更で再実行したいだけなので `include ".chezmoiexternal.toml.tmpl"` のまま)。
- `.tmpl` の `{{ .chezmoi.* }}` は原則、変更検知の hash 行だけに使う。実行時の OS / source dir は chezmoi が注入する `CHEZMOI_OS` / `CHEZMOI_SOURCE_DIR` を読む。
- fetch logic は `installer/chezmoi-steps/` または chezmoi external に閉じ込める。fetch 不要の設定変更は plain `.sh` にインラインし、スクリプト本体の変更で再実行させる。
- headless 機では `DOTFILES_HEADLESS=1` を shell rc などで恒久 export する。chezmoi external は `apply` / `diff` のたびに評価されるため、一時 env だと次回フォント取得が復活する。

## Claude Code / Codex

- install-only: `installer/pinned.toml` のピンは新規マシンの初回導入用。更新は各 CLI の自己アップデートに任せ、ピン更新で既存の導入を差し替えない。chezmoi external にしない(diff / apply のたびに数百 MB を再ハッシュし、自己更新が張り替えた symlink とも衝突する)。
- 配置は公式インストーラと同じ形を手で作る。自己更新はこの形を前提に引き継ぐ。
    - Claude Code: `<binary> install <ver>` を使わない。`~/.claude.json` に `autoUpdates: false` が書かれ、ピン扱いになる。
    - Claude Code の versions は `XDG_DATA_HOME` 配下。一時 HOME で試すときは `XDG_*` も差し替える(HOME だけだと実ホームの versions を指す)。
    - Codex: `auto-update-version` が無いとピン扱いになり、定期更新が何もしない。
- `update-pins.sh` の `[codex]` 更新は macOS + cosign が前提(Linux 版は Sigstore、macOS 版は全 Mach-O の codesign)。満たさない環境では検証を飛ばして書かず現ピンを保持する(ハッシュ不変の次回実行では検証が走らないため)。cosign は global mise tool(`home/dot_config/mise/config.toml`)。mise 未 activate のシェルでは inactive な shim が `command -v` で見つかっても失敗するので、その場合は `mise x -- ./installer/update-pins.sh` で実行する。
- `DOTFILES_SKIP_AGENT_CLIS` は run_onchange 25 の描画結果に含まれる。apply と diff で値を揃える(テストでは process-wide に export する)。

## CI

- `.github/workflows/ci.yml`(push/PR): `make lint`(shellcheck)+ Linux smoke(`make test/linux`)+ macOS render(`./installer/bootstrap.sh` で darwin ピンの取得/検証 → `chezmoi apply --dry-run`、実 apply はしない)。`weekly-smoke.yml`(週次 + 手動): Linux full E2E + macOS 実 apply。週次は「ピンが今も fetch でき checksum が一致するか」を継続検証する位置づけ。
- Action は **commit SHA 固定**(floating tag 禁止の原則を CI でも貫く)。固定/更新は `pinact run .github/workflows/*.yml`。pinact は mise 管理(`aqua:suzuki-shunsuke/pinact`)。`uses: owner/repo@<tag>` を足したら pinact を流す。匿名 API はレート制限に当たるので `GITHUB_TOKEN`(`gh auth token`)を渡す。
- macOS の実 apply(週次)は runner を汚さず速く保つため `DOTFILES_SKIP_BREW=1`(cask が重い)+ `DOTFILES_SKIP_MISE_INSTALL=1` + `DOTFILES_HEADLESS=1` で bounded にする。これらの env は run_onchange 側(10/20)と external で解釈される。`DOTFILES_DEBUG=1` で installer / run_onchange を `set -x` トレースできる。

## Line endings

- `.gitattributes` 無し、`core.autocrlf=input` + `core.safecrlf=true`。LF tracked ファイルに CRLF が混ざって `git add` が失敗したら `perl -i -pe 's/\r\n/\n/g' <file>` で直す。

## Sensitive / gotchas

- 機密値を含む target は source に入れない。`chezmoi add` の secrets warning を無視せず、迷ったら `.chezmoiignore` / source path / diff を確認する。
- `.zshenv` は環境変数だけ。親から来る `MANPAGER` / `EDITOR` は上書きしない。
- `.zshrc` の PATH は macOS `path_helper` 後に組む。`compinit -C` は同期実行のままにし、遅延ロード断片で再実行しない。
- `karabiner.json` は保存だけで空白 diff が巨大化する。実差分は `git diff -w` で確認し、必要ならコミットメッセージに明記する。

## mise

- ツール指定は registry 短縮名を優先し、短縮名が無いものだけ `aqua:owner/repo` などにフォールバックする。フォールバック理由は config コメントに残す。
- `mise use -g` は target 側の config を書く。先に `chezmoi apply` せず、`mise lock -g` 後に config と lock を `chezmoi add` で source に取り込む(対象 platform は config.toml の `lockfile_platforms` で linux-x64/arm64・macos-arm64 を宣言済。別 platform が要るときだけ `--platform` を明示)。
- `private_mise.lock` は mise が生成する。手で編集せず、chezmoiscript から `chezmoi add` して source を自動変更しない。
- lockfile は format 4。npm / pypi tool の推移的依存は `~/.config/mise/locks/` のサイドカー(aube-lock.yaml, uv.lock)に固定され、lock と一緒に source の `home/dot_config/mise/exact_locks/` へ取り込む。
    - `chezmoi add --exact` は source に残った旧 version のディレクトリを消さない。`mise lock -g` 後は `rm -rf home/dot_config/mise/exact_locks && chezmoi add --exact ~/.config/mise/locks` で丸ごと取り直す。
    - 一覧は `mise lock -g --sidecars`。`exact_` なので他マシンでは `chezmoi apply` が旧サイドカーを掃除する。
- `settings.locked = true` 下で新規 lock 生成が詰まる場合は、temp config root で `locked=false` にして生成し、必要な lock 行だけ source へ反映する。npm / pypi tool は lock 行が参照するサイドカーも一緒に移し、ローカル mise(2026.11.10+)の `mise lock -g --check` で整合を確認する。
- runtime version の major-only 指定は避け、少なくとも minor まで固定する。現在の理由は `home/dot_config/mise/config.toml` のコメントを参照。

## Commits

- 件名は lowercase scope + colon (`zsh:`, `mise:`, `chezmoi:`, `chore:` など)。命令形、末尾ピリオド無し。
- ドキュメントには実ユーザ名入りの絶対パスを書かない。リポジトリ相対パスを使う。
- solo の個人 dotfiles。`main` 直コミットでよい(feature branch / PR は不要)。論理単位ごとに細かく分けて commit する。
