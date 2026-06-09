#!/usr/bin/env bash
# One-shot fresh-machine installer.
#
#   git clone <this repo> dotfiles && cd dotfiles && ./install.sh
#
# Thin wrapper that chains the two real steps so a clean machine is set up with
# a single command:
#   1. installer/bootstrap.sh  — fetch + sha256-verify pinned `chezmoi` & `mise`
#                                into ~/.local/bin (NO `curl | sh`; the trust
#                                anchor is installer/pinned.toml).
#   2. chezmoi init --apply     — materialize the dotfiles and run the apply-time
#                                steps (Homebrew/mise/macOS defaults, fonts, …).
#
# This adds NO new trust surface over `make bootstrap` + `chezmoi init --apply`;
# it only removes the between-step PATH footgun by invoking the just-installed
# chezmoi by absolute path. Override the install dir with BIN_DIR=/somewhere.
set -Eeuo pipefail
[ -n "${DOTFILES_DEBUG:-}" ] && set -x

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
bin_dir="${BIN_DIR:-$HOME/.local/bin}"

"$here/installer/bootstrap.sh"
exec "$bin_dir/chezmoi" init --apply --source="$here"
