#!/usr/bin/env bash
# run_once (chezmoi): macOS only — install Homebrew (non-interactive) and apply
# the repo Brewfile (GUI casks, mas apps, pinentry-mac, and the CLI not yet
# moved to mise). No-op (early exit) on non-macOS.
#
# Ordering: 10 (before 20-mise-install). chezmoi runs `*_after_` scripts after
# files are applied, in filename order.
#
# No chezmoi template here: chezmoi injects CHEZMOI_OS / CHEZMOI_SOURCE_DIR into
# the script environment, so the OS branch is a plain shell guard and the path
# is read from the env. The Brewfile lives at the repo root, one level above
# CHEZMOI_SOURCE_DIR (which is home/, via .chezmoiroot).
set -Eeuo pipefail

[ "${CHEZMOI_OS:-}" = "darwin" ] || exit 0

repo_root="$(cd "$(dirname "$CHEZMOI_SOURCE_DIR")" && pwd -P)"

# 1. Install Homebrew if absent (idempotent + non-interactive; see the script).
"${repo_root}/installer/homebrew.sh"

# 2. Load brew into the environment for this script.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. Apply the Brewfile. --no-upgrade installs only what's missing and leaves
#    already-installed formulae untouched (idempotent; no surprise mass upgrade
#    on an existing machine). Upgrades are done deliberately via `make
#    upgrade/brew`. (Modern Homebrew dropped the lockfile feature, so there is
#    no --no-lock / Brewfile.lock.json to manage here.)
echo "[homebrew] brew bundle --file=${repo_root}/Brewfile --no-upgrade"
brew bundle --file="${repo_root}/Brewfile" --no-upgrade
