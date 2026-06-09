#!/bin/bash
# chezmoi-step (macOS only): install Homebrew if absent, then apply the repo
# Brewfile. Invoked by home/.chezmoiscripts/run_onchange_after_10-homebrew.sh.tmpl
# (re-runs whenever the Brewfile changes).
#
# Homebrew itself is installed from the OFFICIAL install.sh PINNED to a
# human-reviewed commit and VERIFIED against the sha256 in ../pinned.toml, then
# run non-interactively — replacing the old unpinned `curl | bash` HEAD. The
# install.sh still git-clones the latest brew at run time, so brew's own version
# is not frozen, but the installer script's bytes are pinned and tamper-evident.
#
# Idempotent: skips the install when Homebrew is already present; `brew bundle
# --no-upgrade` only installs what's missing and never mass-upgrades.
set -Eeuo pipefail
[ -n "${DOTFILES_DEBUG:-}" ] && set -x

[ "$(uname -s)" = Darwin ] || { echo "[homebrew] not macOS — skipping"; exit 0; }
[ -n "${DOTFILES_SKIP_BREW:-}" ] && { echo "[homebrew] DOTFILES_SKIP_BREW set — skipping"; exit 0; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"  # installer/chezmoi-steps -> repo root
readonly REPO_ROOT
# shellcheck source-path=SCRIPTDIR source=../lib/secure_fetch.sh
. "$SCRIPT_DIR/../lib/secure_fetch.sh"
readonly PINNED="$SCRIPT_DIR/../pinned.toml"

if [[ "$(uname -m)" == "arm64" ]]; then
  readonly homebrew_repository="/opt/homebrew"
else
  readonly homebrew_repository="/usr/local/Homebrew"
fi

# 1. Install Homebrew if absent (pinned + verified install.sh).
if [[ -d "$homebrew_repository" ]]; then
  echo "[homebrew] ${homebrew_repository} present — skipping install"
else
  # install_commit / install_sha256 are unique to the [homebrew] section, so a
  # line-anchored awk is unambiguous (no full TOML parser needed here).
  commit="$(awk -F'"' '/^install_commit[[:space:]]*=/{print $2; exit}' "$PINNED")"
  sha="$(awk -F'"' '/^install_sha256[[:space:]]*=/{print $2; exit}' "$PINNED")"
  if [ -z "$commit" ] || [ -z "$sha" ]; then
    echo "[homebrew] pinned.toml: missing [homebrew] install_commit/install_sha256" >&2
    exit 1
  fi

  url="https://raw.githubusercontent.com/Homebrew/install/${commit}/install.sh"
  tmpd="$(mktemp -d "${TMPDIR:-/tmp}/brew-install.XXXXXX")" || { echo "mktemp failed" >&2; exit 1; }
  echo "[homebrew] fetching pinned install.sh (commit ${commit:0:12}…, verifying sha256)"
  if secure_fetch "$url" "$sha" "$tmpd/install.sh"; then
    # NONINTERACTIVE so this is safe to run from chezmoi (no TTY).
    NONINTERACTIVE=1 /bin/bash "$tmpd/install.sh"
  else
    echo "[homebrew] install.sh download/verify failed — refusing to run" >&2
    rm -rf "$tmpd"
    exit 1
  fi
  rm -rf "$tmpd"
fi

# 2. Load brew into this shell.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. Apply the Brewfile (repo root). --no-upgrade keeps it idempotent: installs
#    only missing entries, never upgrades already-installed formulae.
echo "[homebrew] brew bundle --file=${REPO_ROOT}/Brewfile --no-upgrade"
brew bundle --file="${REPO_ROOT}/Brewfile" --no-upgrade
