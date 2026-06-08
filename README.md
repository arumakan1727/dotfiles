# dotfiles
Target environments: Linux (i3wm), macOS

秘伝のタレ。
たまごっちのように愛情込めて育てていけ。

[chezmoi](https://www.chezmoi.io/) で管理している。source は `home/`（`.chezmoiroot`）。

## Install (fresh machine)

前提は `git` + `curl` + `shasum`/`sha256sum`（mac/Linux 標準）だけ。

```shell
# 1. リポジトリを取得
git clone <this repo> dotfiles && cd dotfiles

# 2. ブートストラップ: 固定バージョン + sha256 検証で chezmoi と mise を
#    ~/.local/bin へ導入（curl|sh は使わない。詳細は installer/pinned.toml）
make bootstrap        # = ./installer/00-install-bootstrap.sh

# 3. dotfiles を適用。apply 後に run_once スクリプトが順に走る:
#      10 Homebrew + brew bundle (macOS のみ)
#      20 mise install            (~/.config/mise/config.toml のツール群)
#      30 macOS defaults + gpg-agent pinentry (macOS のみ)
chezmoi init --apply --source="$PWD"
```

`~/.local/bin` が PATH に無ければ追加してから 3 を実行すること。

## Day-to-day

```shell
chezmoi edit ~/.zshrc   # source を編集
chezmoi apply           # $HOME へ反映  (make apply)
chezmoi diff            # 差分プレビュー (make diff)
chezmoi add <path>      # 実環境で直接編集したファイルを source へ取り込む
```

## Supply chain

- mise で入るものは全て mise（aqua のチェックサム検証 + `mise.lock` + `MISE_INSTALL_BEFORE`）。
- mise を使わない bootstrap の 2 点（chezmoi 本体・mise 本体）のみ、`installer/pinned.toml`
  に人手でレビューして記録した sha256 で検証取得する。ピン更新は `make update-pins`。
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
```
