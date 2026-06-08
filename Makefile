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
# NOTE: Brewfile.lock.json only records versions for debugging / reproducing a
#       "last known good" state. It does NOT pin versions on install (Homebrew
#       cannot install a specific version).

brew/dump:	## Update Brewfile and Brewfile.lock.json
	rm -f Brewfile
	brew bundle dump
	rm -f Brewfile.lock.json
	brew bundle --no-upgrade

brew/install:	## Install and upgrade packages from Brewfile
	brew bundle install --no-lock

upgrade/brew:	## Update + upgrade all Homebrew packages, then re-dump
	brew update
	brew upgrade --cask --greedy
	make brew/dump

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
