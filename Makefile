.DEFAULT_GOAL := help
SHELL         := /bin/bash
RED     := \033[31m
CYAN    := \033[36m
MAGENTA := \033[35m
RESET   := \033[0m


.PHONY:	lint/Makefile	## Lint makefiles
lint/Makefile:	_bootstrap
	$(DENO) run --allow-read=Makefile ./manager/cmd/lint_makefile.ts Makefile

.PHONY:	symlink/update	## Set symlinks pointing to this dotifiles & remove dead symlinks
symlink/update:
	echo "TODO"

.PHONY:	symlink/remove	## Remove all symlinks
symlink/remove:
	echo "TODO"

XDG_CACHE_HOME ?= $(HOME)/.cache
DOTFILES_CACHE_HOME := $(XDG_CACHE_HOME)/armkn-dotfiles
LAST_INSTALL_DATE_JSON := $(DOTFILES_CACHE_HOME)/last-install-date.json

PKGMAN_ARGS := -A manager/cmd/pkgman.ts

.PHONY:	cli/install/essentials	## Install essential CLI
cli/install/essentials:
	deno run $(PKGMAN_ARGS)  cli.essentials

.PHONY:	cli/install/extras	## Install additional CLI
cli/install/extras:
	deno run $(PKGMAN_ARGS) cli.extras

.PHONY:	cli/install/devs	## Install development tools CLI
cli/install/devs:
	deno run $(PKGMAN_ARGS) cli.devs

.PHONY:	gui/install	## Install GUI applications
gui/install:
	deno run $(PKGMAN_ARGS) gui.all

.PHONY:	help	## Show Makefile tasks
help:
	@grep -E '^.PHONY:\s*\S+\s+#' Makefile | \
		sed -E 's/.PHONY:\s*//' | \
		awk 'BEGIN {FS = "(\\s*##\\s*)?"}; {printf "$(CYAN)%-22s$(RESET) %s\n", $$1, $$2}'
