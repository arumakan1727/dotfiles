.DEFAULT_GOAL := help
MAKEFLAGS += --always-make

RED     := \033[31m
CYAN    := \033[36m
MAGENTA := \033[35m
RESET   := \033[0m

help:	## Print the description of each task in this Makefile
	@grep -E '^[a-zA-Z0-9_/-]+:' Makefile | \
		awk 'BEGIN {FS = ":(.*## )?"}; {printf "$(CYAN)%-18s$(RESET) %s\n", $$1, $$2}'

# --- chezmoi workflow ---------------------------------------------------------
# Fresh machine flow:
#   git clone <repo> && cd dotfiles
#   make bootstrap        # pinned + checksum-verified chezmoi & mise -> ~/.local/bin
#   chezmoi init --apply --source="$$PWD"   # apply + run_once (brew/mise/macos)

bootstrap:	## Install pinned, checksum-verified chezmoi & mise into ~/.local/bin
	./installer/00-install-bootstrap.sh

apply:	## chezmoi apply (materialize dotfiles into $HOME)
	chezmoi apply

diff:	## chezmoi diff (preview what apply would change)
	chezmoi diff

update-pins:	## Refresh installer/pinned.toml to latest age-compliant chezmoi/mise
	./installer/update-pins.sh

# --- optional installers ------------------------------------------------------
i/fonts:	## Install Nerd Fonts
	./installer/fonts.sh

i/rust:	## Install rustup + cargo-binstall (optional; most tools come via mise)
	./installer/rustup.sh

# --- Homebrew bundle workflow (macOS) -----------------------------------------
# Brewfile は手動キュレーション。`brew bundle dump` は leaf + 依存ライブラリを
# 全部書き戻して手で分類したカテゴリを破壊するので使わない(モダン Homebrew は
# lockfile 機能も廃止済み)。追加・削除は Brewfile を直接編集する。

brew/install:	## Install missing packages from Brewfile (no upgrades)
	brew bundle install --no-upgrade

brew/check:	## Show Brewfile entries not yet installed (dry-run)
	brew bundle check --verbose || true

upgrade/brew:	## Update + upgrade all Homebrew packages (Brewfile はいじらない)
	brew update
	brew upgrade --cask --greedy

# --- maintenance --------------------------------------------------------------
find/dead-symlink:	## Show dead symlinks (e.g. orphans left by the old installer)
	find ~ ~/.local ~/Library -maxdepth 2 -xtype l

find/dead-symlink/del:	## Delete dead symlinks
	find ~ ~/.local ~/Library -maxdepth 2 -xtype l -delete

# --- tests --------------------------------------------------------------------
test/linux:	## Smoke test on Linux in Docker: bootstrap -> chezmoi apply -> verify
	./test/run.sh smoke

test/linux/full:	## Full test: smoke + representative mise install + zsh/bash load
	./test/run.sh full

lint:	## shellcheck installer scripts and plain run_once scripts
	shellcheck -x installer/*.sh installer/lib/*.sh test/*.sh \
		home/.chezmoiscripts/*.sh
