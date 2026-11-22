# dotfiles

[![CI](https://github.com/arumakan1727/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/arumakan1727/dotfiles/actions/workflows/ci.yml)

Target environments: Linux (i3wm), macOS

秘伝のタレ。
たまごっちのように愛情込めて育てていけ。

[chezmoi](https://www.chezmoi.io/) で管理している。source は `home/`（`.chezmoiroot`）。

## Install (fresh machine)

前提は `git` + `curl` + `shasum`/`sha256sum`（mac/Linux 標準）だけ。

```shell
git clone <this repo> dotfiles && cd dotfiles

# ディスプレイの無いサーバ (SSH 先など) では下記で GUI 系や fonts をスキップできる
# export DOTFILES_HEADLESS=1
# mise セットアップ後はは mise.local.toml の [env] に追加するとよい

./install.sh          # = make install （curl|sh は一切使わない）
```

`./install.sh` は次の 2 ステップを順に実行する:

1. **bootstrap**（`installer/bootstrap.sh`）: 固定バージョン + sha256 検証で `chezmoi` と
   `mise` を `~/.local/bin` へ導入する。信頼の起点は `installer/pinned.toml`。
2. **chezmoi init --apply**: dotfiles を適用する。apply 中に chezmoi external が Nerd Fonts を
   sha256 検証取得し、apply 後に run_onchange が走る(対象が変われば次回 apply で自動再適用)。

## AI agent CLIs (Claude Code / Codex)

Claude Code と Codex CLI は、mise や npm を使わず公式のネイティブバイナリで入れる
（`home/.chezmoiscripts/run_onchange_after_25-agent-clis.sh.tmpl`）。

- **install-only**: `~/.local/bin/claude`、`~/.local/bin/codex` が無いマシンにだけ、`installer/pinned.toml` の
  ピン版を sha256 検証して配置する。既にあれば何もしない。
- **更新は各 CLI の自己アップデートに任せる**: 配置は公式インストーラと同じ形にしてあり、
  Claude Code の auto-update と `claude update`、Codex の起動時チェックと `codex update` がそのまま引き継ぐ。
  - Claude Code: `${XDG_DATA_HOME:-~/.local/share}/claude/versions/<ver>` + `~/.local/bin/claude` の symlink
  - Codex: `~/.codex/packages/standalone/{releases/<ver>-<target>,current,auto-update-version}` + `~/.local/bin/codex` の symlink
- ピンは新規マシンの初回導入の信頼の起点にすぎないので、更新が遅れても既存の導入には影響しない。

## Options

apply の挙動を切り替える env（ヘッドレス機やテスト・CI で使う）:

- `DOTFILES_HEADLESS=1` — フォントを取得しない。
- `DOTFILES_SKIP_MISE_INSTALL=1` — `mise install` を skip。
- `DOTFILES_SKIP_BREW=1` — Homebrew + Brewfile によるインストールを skip。
- `DOTFILES_SKIP_AGENT_CLIS=1` — Claude Code / Codex のインストールを skip。
- `DOTFILES_DEBUG=1` — installer / run_onchange を `set -x` でトレース。

## Day-to-day

```shell
chezmoi edit ~/.zshrc   # source を編集
chezmoi diff            # 差分プレビュー (make diff)
chezmoi apply           # $HOME へ反映  (make apply)
chezmoi add <path>      # 実環境で直接編集したファイルを source へ取り込む
```

## Update (pinned.toml の pin)

`installer/pinned.toml` に、bootstrap で使う chezmoi と mise、初回導入用の Claude Code と Codex のバージョンと SHA-256 を固定する。
`make update-pins` は各ツールについて、公開から7日以上経過した最新の安定版を選ぶ。
バージョンか SHA-256 が1つでも変われば、そのツールの全対象プラットフォームの配布物を検証する。

- **chezmoi** は、リポジトリに固定した cosign 公開鍵 `installer/keys/chezmoi_cosign.pub` でチェックサム一覧の署名を毎回検証する。照合には署名済みの値を使う。
- **mise** は、各 tarball の GitHub artifact attestation で、ソースが対象のリリースタグであることと、そのタグの `jdx/mise/.github/workflows/release.yml` が署名したことを確認する。
- **Claude Code** は、stable チャネルの版を候補にし、リポジトリに固定した GPG 公開鍵 `installer/keys/claude-code.asc` で `manifest.json` の署名を毎回検証する。
  - 7日待機は `anthropics/claude-code` の GitHub release の公開日時で判定する（manifest の `buildDate` は公開より数時間早い）。
  - 署名済み manifest が全バイナリの SHA-256 を保証するため、バイナリ自体は取得しない。
- **Codex** は、`codex-package_SHA256SUMS` の値を、GitHub がアップロード時に計算した asset digest と、OpenAI の配信元 `releases.openai.com` の `release.json` の digest の両方と突き合わせる。そのうえで全 tarball を取得して照合する。
  - Linux 版: Sigstore bundle を cosign で検証し、`openai/codex/.github/workflows/rust-release.yml` の該当タグが署名したことを確認する。
  - macOS 版: 展開した全 Mach-O ファイルの Developer ID 署名（OpenAI のチーム ID `2DC432GLL2`）を codesign で検証する。
  - `[codex]` の更新には cosign と codesign の両方が要る。どちらかが使えない環境（macOS 以外を含む）では `[codex]` を現行のまま保持する。macOS で `mise x aqua:sigstore/cosign@<ver> -- ./installer/update-pins.sh` のように cosign を有効にして実行する。

```shell
GITHUB_TOKEN=$(gh auth token) make update-pins
git diff installer/pinned.toml  # バージョンと SHA-256 の差分をレビューしてコミット
./installer/bootstrap.sh        # レビュー済みの SHA-256 と照合し、~/.local/bin に配置
```

`./installer/update-pins.sh --dry-run` でも同じ検証を行い、差分を表示する。一部のツールだけ更新する場合は、
検証済みの差分から該当セクションを取り込む。待機日数は `--days N` で変更できる。

他のマシンで pin 更新を取り込むときは、`git pull` の後に `./installer/bootstrap.sh` を **`chezmoi apply` より先に**
実行する。新しい mise 設定や lockfile は古い mise で読めないことがある（例: `paranoid = ["provenance"]` は
mise 2026.10.14 未満では読めない）。

## Debug

```shell
chezmoi diff                       # 反映される差分プレビュー (make diff)
chezmoi diff --exclude scripts     # run_onchange の中身を除いた差分
chezmoi-ls-scripts [next|all]      # 次の apply で走る run_* スクリプト一覧 (~/bin)
chezmoi doctor                     # 環境のサニティチェック
chezmoi apply --dry-run --verbose  # 何も変更せずテンプレート展開だけ確認

DOTFILES_DEBUG=1 ./install.sh      # installer / run_onchange を set -x でトレース
make test/linux/shell              # クリーンな Linux コンテナで対話デバッグ
```

## Other tasks

`make help` を参照。

```sh
make help
```

## Test (Linux)

クリーン環境からの再現性を Docker で検証する。

```sh
make test/linux        # smoke: bootstrap -> chezmoi apply -> 構造検証（高速）
make test/linux/full   # 上記 + Claude Code / Codex の導入 + 代表ツールの mise install + zsh/bash 対話ロード
make test/linux/shell  # 同じクリーン環境に対話シェルで入る（手動デバッグ）
```

push / PR では GitHub Actions（`.github/workflows/ci.yml`）が `make lint` + `make test/linux` + macOS render を回す。
週次（`weekly-smoke.yml`）で Linux full E2E + macOS 実 apply を実行し、ピンが今も fetch でき checksum が一致することを継続検証する。
