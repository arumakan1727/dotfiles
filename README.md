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

## Options

apply の挙動を切り替える env（ヘッドレス機やテスト・CI で使う）:

- `DOTFILES_HEADLESS=1` — フォントを取得しない。
- `DOTFILES_SKIP_MISE_INSTALL=1` — `mise install` を skip。
- `DOTFILES_SKIP_BREW=1` — Homebrew + Brewfile によるインストールを skip。
- `DOTFILES_DEBUG=1` — installer / run_onchange を `set -x` でトレース。

## Day-to-day

```shell
chezmoi edit ~/.zshrc   # source を編集
chezmoi diff            # 差分プレビュー (make diff)
chezmoi apply           # $HOME へ反映  (make apply)
chezmoi add <path>      # 実環境で直接編集したファイルを source へ取り込む
```

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
make test/linux/full   # 上記 + 代表ツールの mise install + zsh/bash 対話ロード
make test/linux/shell  # 同じクリーン環境に対話シェルで入る（手動デバッグ）
```

push / PR では GitHub Actions（`.github/workflows/ci.yml`）が `make lint` + `make test/linux` + macOS render を回す。
週次（`weekly-smoke.yml`）で Linux full E2E + macOS 実 apply を実行し、ピンが今も fetch でき checksum が一致することを継続検証する。
