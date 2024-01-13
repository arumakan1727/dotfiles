.DEFAULT_GOAL := help
MAKEFLAGS += --always-make

RED     := \033[31m
CYAN    := \033[36m
MAGENTA := \033[35m
RESET   := \033[0m

help:	## Print the description of each task in this Makefile
	@grep -E '^[a-zA-Z0-9_/-]+:' Makefile | \
		awk 'BEGIN {FS = ":(.*## )?"}; {printf "$(CYAN)%-16s$(RESET) %s\n", $$1, $$2}'

i/symlink:	## Create/Update symlinks to this dotfiles
	./installer/symlink_dotfiles.sh

i/symlink/dryrun:	## Just show what will happen when creating/updating symlinks
	./installer/symlink_dotfiles.sh --dryrun

i/cli:	## Install CLI
	./installer/symlink_dotfiles.sh
	./installer/homebrew.sh
	./installer/neovim.sh
	./installer/rtx.sh
	./installer/aqua.sh
	./installer/volta+corepack.sh
	./installer/rye.sh
	./installer/rustup.sh

i/fonts:	## Install fonts
	./installer/fonts.sh

i/macos:	## Setup macos config
	./installer/macos_defaults.sh

find/dead-symlink:	## Show dead symlinks
	find ~ ~/.local -maxdepth 2 -xtype l

find/dead-symlink/del:	## Delete dead symlinks
	find ~ ~/.local -maxdepth 2 -xtype l -delete

# NOTE: Brewfile.lock.json is only for recording the version which can be
#       useful in debugging brew bundle failures and replicating a "last known good build" state.
#       Brewfile.lock.json does not fix the version on installation. (Homebrew cannot install specific version)

brew/dump:	## Update Brewfile and Brewfile.lock.json
	rm -f Brewfile
	brew bundle dump
	rm -f Brewfile.lock.json
	brew bundle --no-upgrade

brew/install:	## Install and upgrade packages from Brewfile
	# To support multiple user system, run brew as the dedicated user
	sudo -Hu $(shell stat -f '%Su' $$(which brew)) brew bundle install --no-lock

upgrade/aqua:	## Upgrade registry and packages managed by aqua
	aqua -c homedir/.config/aquaproj-aqua/aqua.yaml update

upgrade/brew:
	brew update
	brew upgrade --cask --greedy
	make brew/dump

lint:
	shellcheck ./installer/*
