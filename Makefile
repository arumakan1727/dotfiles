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

i/cli:	## Install CLI
	./installer/symlink_dotfiles.sh
	./installer/neovim.sh
	./installer/rtx.sh
	./installer/aqua.sh
	./installer/volta+corepack.sh
	./installer/rye.sh

i/fonts:	## Install fonts
	./installer/fonts.sh

# NOTE: Brewfile.lock.json is only for recording the version which can be
# 		  useful in debugging brew bundle failures and replicating a "last known good build" state.
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

lint:
	shellcheck ./installer/*
