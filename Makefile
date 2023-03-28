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
	@command -v deno > /dev/null || curl -fsSL https://deno.land/x/install/install.sh | sh

.PHONY:	lint/Makefile	## Lint makefiles
lint/Makefile:	_bootstrap
	$(DENO) run --allow-read=Makefile ./manager/cmd/lint_makefile.ts Makefile

.PHONY:	symlink/update	## Set symlinks pointing to this dotifiles & remove dead symlinks
symlink/update:
	echo "TODO"

.PHONY:	symlink/remove	## Remove all symlinks
symlink/remove:
	echo "TODO"


INSTALL_ARGS := --allow-read=/etc/os-release ./manager/cmd/install.ts

.PHONY:	install/cli/essentials	## Install essential CLI
install/cli/essentials:	_bootstrap
	$(DENO) run $(INSTALL_ARGS)  cli.essentials

.PHONY:	install/cli/extras	## Install additional CLI
install/cli/extras:	_bootstrap
	$(DENO) run $(INSTALL_ARGS) cli.extras

.PHONY:	install/cli/devs	## Install development tools CLI
install/cli/devs:	_bootstrap
	$(DENO) run $(INSTALL_ARGS) cli.devs

.PHONY:	install/fonts	## Install fonts
install/fonts:	_bootstrap
	$(DENO) run $(INSTALL_ARGS) fonts.all

.PHONY:	install/gui	## Install GUI applications
install/gui:	_bootstrap
	$(DENO) run $(INSTALL_ARGS) gui.all

.PHONY:	help	## Show Makefile tasks
help:
	@grep -E '^.PHONY:\s*\S+\s+#' Makefile | \
		sed -E 's/.PHONY:\s*//' | \
		awk 'BEGIN {FS = "(\\s*##\\s*)?"}; {printf "$(CYAN)%-22s$(RESET) %s\n", $$1, $$2}'
