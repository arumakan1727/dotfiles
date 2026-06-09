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
# Fresh machine, one command:
#   git clone <repo> dotfiles && cd dotfiles && make install   # (= ./install.sh)
# Or the two granular steps (same effect, more transparent):
#   ./installer/bootstrap.sh                # pinned + checksum-verified chezmoi & mise -> ~/.local/bin
#   chezmoi init --apply --source="$$PWD"   # apply + run_onchange (brew/mise/macos)

install:	## One-shot fresh setup: bootstrap then chezmoi init --apply (= ./install.sh)
	./install.sh

apply:	## chezmoi apply (materialize dotfiles into $HOME)
	chezmoi apply

diff:	## chezmoi diff (preview what apply would change)
	chezmoi diff

update-pins:	## Refresh installer/pinned.toml to latest age-compliant chezmoi/mise
	./installer/update-pins.sh

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

# --- tests --------------------------------------------------------------------
test/linux:	## Smoke test on Linux in Docker: bootstrap -> chezmoi apply -> verify
	./test/run.sh smoke

test/linux/full:	## Full test: smoke + representative mise install + zsh/bash load
	./test/run.sh full

test/linux/shell:	## Drop into an interactive shell in the clean Linux test container (manual debugging)
	./test/run.sh shell

# run_onchange の *.sh.tmpl も対象にする。テンプレ式({{ }})は変更検知の hash コメント行
# だけに置く規約(AGENTS.md)なので shellcheck からはコメントとして無視され通る。逆に
# コード中へ {{ }} を書くと lint で落ちる = 規約破りの検知になる。
lint:	## shellcheck installer / run_onchange(.sh & .sh.tmpl)/ helper scripts
	shellcheck -x install.sh installer/*.sh installer/chezmoi-steps/*.sh installer/lib/*.sh \
		test/*.sh home/.chezmoiscripts/*.sh home/.chezmoiscripts/*.sh.tmpl \
		home/bin/executable_chezmoi-ls-scripts
