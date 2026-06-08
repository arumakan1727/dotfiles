#!/usr/bin/env bash
# run_once (chezmoi): install the global mise tool set declared in
# ~/.config/mise/config.toml. mise itself is installed earlier by
# installer/00-install-bootstrap.sh; here mise takes over checksum / release-age
# policy for every other CLI (ripgrep, fd, gh, neovim, aws-cli, ...).
#
# This runs on both macOS and Linux. Skip it with DOTFILES_SKIP_MISE_INSTALL=1
# (the fast CI smoke test sets this; the full test installs a representative
# subset explicitly instead of the whole — heavy — tool list).
set -Eeuo pipefail

if [ -n "${DOTFILES_SKIP_MISE_INSTALL:-}" ]; then
  echo "[mise] DOTFILES_SKIP_MISE_INSTALL set — skipping 'mise install'"
  exit 0
fi

# Bootstrap installs mise into ~/.local/bin, which may not be on PATH yet during
# the very first apply (the shell has not been reloaded).
export PATH="$HOME/.local/bin:$PATH"

if ! command -v mise >/dev/null 2>&1; then
  echo "[mise] 'mise' not found on PATH — run installer/00-install-bootstrap.sh first" >&2
  exit 1
fi

# Answer any confirmation prompts non-interactively; the global config under
# ~/.config/mise is auto-trusted, but be explicit for non-standard layouts.
export MISE_YES=1
mise trust --quiet "$HOME/.config/mise/config.toml" 2>/dev/null || true

echo "[mise] installing global tools from ~/.config/mise/config.toml (may take a while)…"
mise install
mise reshim 2>/dev/null || true
