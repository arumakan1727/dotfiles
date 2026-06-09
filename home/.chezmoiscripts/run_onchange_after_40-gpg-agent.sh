#!/usr/bin/env bash
# run_onchange (chezmoi, macOS only): point gpg-agent at pinentry-mac (installed
# via Brewfile). Inlined (no fetch). run_onchange + plain script: re-runs when
# these bytes change. On non-macOS this is a no-op (Linux uses its own pinentry).
set -Eeuo pipefail
[ -n "${DOTFILES_DEBUG:-}" ] && set -x

[ "${CHEZMOI_OS:-}" = "darwin" ] || exit 0

pinentry="$(command -v pinentry-mac)" || {
  echo "[gpg-agent] pinentry-mac not found (installed via Brewfile?) — skipping" >&2
  exit 0
}

mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"
echo "pinentry-program $pinentry" > "$HOME/.gnupg/gpg-agent.conf"
gpgconf --kill gpg-agent
