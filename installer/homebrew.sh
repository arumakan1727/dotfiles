#!/bin/bash
# Install Homebrew (macOS only) by fetching the OFFICIAL install.sh PINNED to a
# human-reviewed commit and VERIFIED against the sha256 in pinned.toml, then
# running it non-interactively. This replaces the previous `curl | bash` of an
# unpinned HEAD, which violated the supply-chain principle (untrusted pipe +
# moving target). install.sh still git-clones the latest brew at run time, so
# brew's own version is not frozen — but the installer script's bytes are pinned
# and tamper-evident. Idempotent: skips if Homebrew is already present.
set -Eeuo pipefail

os="$(uname -s)"
readonly os

if [[ "$os" != Darwin ]]; then
  echo "Not on macOS. Skipping Homebrew installation."
  exit
fi

arch="$(uname -m)"
readonly arch

if [[ "${arch}" == "arm64" ]]; then
  readonly homebrew_repository="/opt/homebrew"
else
  readonly homebrew_repository="/usr/local/Homebrew"
fi

if [[ -d "$homebrew_repository" ]]; then
  echo "Found ${homebrew_repository}. Skipping Homebrew installation."
  exit
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
# shellcheck source-path=SCRIPTDIR source=lib/secure_fetch.sh
. "$SCRIPT_DIR/lib/secure_fetch.sh"
readonly PINNED="$SCRIPT_DIR/pinned.toml"

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
rc=1
if secure_fetch "$url" "$sha" "$tmpd/install.sh"; then
  # NONINTERACTIVE so this is safe to run from chezmoi's run_once (no TTY).
  NONINTERACTIVE=1 /bin/bash "$tmpd/install.sh" && rc=0
else
  echo "[homebrew] install.sh download/verify failed — refusing to run" >&2
fi
rm -rf "$tmpd"
exit "$rc"
