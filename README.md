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
make bootstrap        # = ./installer/bootstrap.sh

# 3. dotfiles を適用。apply 中に chezmoi external が Nerd Fonts を sha256 検証取得し、
#    apply 後に run_onchange スクリプトが走る(対象が変われば次回 apply で自動再適用):
#      10 Homebrew + brew bundle            (macOS のみ)
#      20 mise install                      (~/.config/mise の config/lockfile から)
#      30 macOS defaults  / 40 gpg-agent    (macOS のみ)
#      Nerd Fonts (pinned external)         (ヘッドレス機は DOTFILES_HEADLESS=1 で skip)
#      50 fontcache                         (Linux の fc-cache のみ)
chezmoi init --apply --source="$PWD"
```

`~/.local/bin` が PATH に無ければ追加してから 3 を実行すること。
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
```
