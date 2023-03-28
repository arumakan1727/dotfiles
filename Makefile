.DEFAULT_GOAL := help
SHELL         := /bin/bash
RED     := \033[31m
CYAN    := \033[36m
MAGENTA := \033[35m
RESET   := \033[0m

.PHONY:	lint/Makefile	## Lint makefiles
lint/Makefile:
	deno run --allow-read=Makefile ./manager/cmd/lint_makefile.ts Makefile

.PHONY:	symlink/update	## Set symlinks pointing to this dotifiles & remove dead symlinks
symlink/update:
	echo "TODO"

.PHONY:	symlink/remove	## Remove all symlinks
symlink/remove:
	echo "TODO"


INSTALL_ARGS := --allow-read=/etc/os-release ./manager/cmd/install.ts

.PHONY:	install/cli/essentials	## Install essential CLI
install/cli/essentials:
	deno run $(INSTALL_ARGS)  cli.essentials

.PHONY:	install/cli/extras	## Install additional CLI
install/cli/extras:
	deno run $(INSTALL_ARGS) cli.extras

.PHONY:	install/cli/devs	## Install development tools CLI
install/cli/devs:
	deno run $(INSTALL_ARGS) cli.devs

.PHONY:	install/fonts	## Install fonts
install/fonts:
	deno run $(INSTALL_ARGS) fonts.all

.PHONY:	install/gui	## Install GUI applications
install/gui:
	deno run $(INSTALL_ARGS) gui.all

.PHONY:	help	## Show Makefile tasks
help:
	@grep -oP '(?<=\.PHONY:\s).*' Makefile | \
		awk 'BEGIN {FS = "(\\s*##\\s*)?"}; {printf "$(CYAN)%-22s$(RESET) %s\n", $$1, $$2}'
