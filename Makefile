.DEFAULT_GOAL := help
SHELL         := /bin/bash
RED     := \033[31m
CYAN    := \033[36m
MAGENTA := \033[35m
RESET   := \033[0m

DENO_INSTALL ?= $(HOME)/.deno
DENO := $(DENO_INSTALL)/bin/deno

.PHONY:	_bootstrap
_bootstrap:
	@test -x $(DENO) || curl -fsSL https://deno.land/x/install/install.sh | sh

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

INSTALL_ARGS := --allow-read=/etc/os-release,$(LAST_INSTALL_DATE_JSON) \
				--allow-write=$(DOTFILES_CACHE_HOME),$(LAST_INSTALL_DATE_JSON) \
				--allow-env=XDG_CACHE_HOME,HOME \
				--allow-run \
				manager/cmd/install.ts --dry-run

.PHONY:	install/cli/essentials	## Install essential CLI
install/cli/essentials:	_bootstrap
	$(DENO) run $(INSTALL_ARGS)  cli.essentials

.PHONY:	install/cli/extras	## Install additional CLI
install/cli/extras:	_bootstrap
	$(DENO) run $(INSTALL_ARGS) cli.extras

.PHONY:	install/cli/devs	## Install development tools CLI
install/cli/devs:	_bootstrap
	$(DENO) run $(INSTALL_ARGS) cli.devs

.PHONY:	install/gui	## Install GUI applications
install/gui:	_bootstrap
	$(DENO) run $(INSTALL_ARGS) gui.all

.PHONY:	help	## Show Makefile tasks
help:
	@grep -E '^.PHONY:\s*\S+\s+#' Makefile | \
		sed -E 's/.PHONY:\s*//' | \
		awk 'BEGIN {FS = "(\\s*##\\s*)?"}; {printf "$(CYAN)%-22s$(RESET) %s\n", $$1, $$2}'
