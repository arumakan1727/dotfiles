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
./install.sh          # = make install （curl|sh は一切使わない）
```

`./install.sh` は次の 2 ステップを順に実行する:

1. **bootstrap**（`installer/bootstrap.sh`）: 固定バージョン + sha256 検証で `chezmoi` と
   `mise` を `~/.local/bin` へ導入する。信頼の起点は `installer/pinned.toml`。
2. **chezmoi init --apply**: dotfiles を適用する。apply 中に chezmoi external が Nerd Fonts を
   sha256 検証取得し、apply 後に run_onchange が走る(対象が変われば次回 apply で自動再適用):
     - 10 Homebrew + brew bundle         (macOS のみ。`DOTFILES_SKIP_BREW=1` で skip)
     - 20 mise install                   (~/.config/mise の config/lockfile から。`DOTFILES_SKIP_MISE_INSTALL=1` で skip)
     - 30 macOS defaults / 40 gpg-agent  (macOS のみ)
     - Nerd Fonts (pinned external)      (ヘッドレス機は `DOTFILES_HEADLESS=1` で skip)
     - 50 fontcache                      (Linux の fc-cache のみ)

透明性重視で個別に実行したいときは `make bootstrap` → `chezmoi init --apply --source="$PWD"`。
その場合 `~/.local/bin` を PATH に追加してから後者を実行すること
（`./install.sh` は chezmoi を絶対パスで呼ぶので PATH 追加は不要）。
ディスプレイの無いサーバ(SSH 先など)では GUI 系(fonts)を飛ばすため
`export DOTFILES_HEADLESS=1` を **shell rc に入れて恒久化**しておく
(フォントは chezmoi external = 宣言的なので、`apply`/`diff` のたびに判定される)。

## Day-to-day

```shell
chezmoi edit ~/.zshrc   # source を編集
chezmoi apply           # $HOME へ反映  (make apply)
chezmoi diff            # 差分プレビュー (make diff)
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

apply の挙動を切り替える env（ヘッドレス機やテスト・CI で使う）:

- `DOTFILES_HEADLESS=1` — フォント（chezmoi external）を取得しない。`apply`/`diff` のたびに
  評価されるので shell rc で恒久 export する。
- `DOTFILES_SKIP_MISE_INSTALL=1` — `mise install`（20）を skip。
- `DOTFILES_SKIP_BREW=1` — Homebrew + brew bundle（10）を skip。
- `DOTFILES_DEBUG=1` — installer / run_onchange を `set -x` でトレース。

## Supply chain

- mise で入るものは全て mise（aqua のチェックサム検証 + `mise.lock` + `MISE_INSTALL_BEFORE`）。
  rust もここ（旧 `installer/rustup.sh` を廃止し core:rust へ移行）。
- 検証取得が要るもの（bootstrap の chezmoi/mise 本体・Homebrew 公式 install.sh）は
  `installer/pinned.toml` に人手レビュー済みの sha256 を記録し `secure_fetch` で検証取得する。
  ピン更新は `make update-pins`（chezmoi/mise は自動、`[homebrew]` は手動レビューで保持）。
- Nerd Fonts は `home/.chezmoiexternal.toml.tmpl` に手レビュー済み sha256 を記録し、
  chezmoi external（`checksum.sha256`）が検証取得・展開する（pinned.toml と同じ信頼モデル）。
- Homebrew は macOS の最終手段（GUI cask / mas / pinentry-mac など）。

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

push / PR では GitHub Actions（`.github/workflows/ci.yml`）が `make lint` + `make test/linux`
+ macOS render を回す。週次（`weekly-smoke.yml`）で Linux full E2E + macOS 実 apply を実行し、
ピンが今も fetch でき checksum が一致することを継続検証する。
