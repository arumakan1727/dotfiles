.DEFAULT_GOAL := help
DENO_INSTALL ?= $(HOME)/.deno
PATH         := $(DENO_INSTALL)/bin:$(PATH)
SHELL        := env PATH=$(PATH) /bin/bash
RED     := \033[31m
CYAN    := \033[36m
MAGENTA := \033[35m
RESET   := \033[0m

export DENO_INSTALL

.PHONY:    deno
deno:	$(DENO_INSTALL)/bin/deno

$(DENO_INSTALL)/bin/deno:
	curl -fsSL https://deno.land/x/install/install.sh | sh


.PHONY:	lint/Makefile	## Lint makefiles
lint/Makefile:	deno
	deno run --allow-read=Makefile --allow-env ./manager/cmd/lint_makefile.ts Makefile


DOTFILE_ARGS := -A manager/cmd/dotfile.ts

.PHONY:	dotfiles/apply/symlink	## Apply dotfiles using symlink, and remove deadlinks
dotfiles/apply/symlink:	deno
	deno run $(DOTFILE_ARGS) apply

.PHONY:	dotfiles/apply/copy	## Apply dotfiles using copy, and remove deadlinks
dotfiles/apply/copy:	deno
	deno run $(DOTFILE_ARGS) apply --copy

.PHONY:	dotfiles/list-symlinks	## List applied symlinks
dotfiles/list-symlinks:	deno
	deno run $(DOTFILE_ARGS) symlinks



XDG_CACHE_HOME ?= $(HOME)/.cache
DOTFILES_CACHE_HOME := $(XDG_CACHE_HOME)/armkn-dotfiles
LAST_INSTALL_DATE_JSON := $(DOTFILES_CACHE_HOME)/last-install-date.json

PKGMAN_ARGS := -A manager/cmd/pkgman.ts

.PHONY:	cli/install/essentials	## Install essential CLI
cli/install/essentials:	deno
	deno run $(PKGMAN_ARGS)  cli.essentials

.PHONY:	cli/install/extras	## Install additional CLI
cli/install/extras:	deno
	deno run $(PKGMAN_ARGS) cli.extras

.PHONY:	cli/install/devs	## Install development tools CLI
cli/install/devs:	deno
	deno run $(PKGMAN_ARGS) cli.devs

.PHONY:	gui/install	## Install GUI applications
gui/install:	deno
	deno run $(PKGMAN_ARGS) gui.all

.PHONY:	help	## Show Makefile tasks
help:
	@grep -E '^.PHONY:\s*\S+\s+#' Makefile | \
		sed -E 's/.PHONY:\s*//' | \
		awk 'BEGIN {FS = "(\\s*##\\s*)?"}; {printf "$(CYAN)%-22s$(RESET) %s\n", $$1, $$2}'
