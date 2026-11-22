#!/usr/bin/env bash
# chezmoi-step: install the native Claude Code CLI if it is absent. Invoked by
# home/.chezmoiscripts/run_onchange_after_25-agent-clis.sh.tmpl.
#
# The binary for the version pinned in ../pinned.toml [claude-code] is fetched
# from Anthropic's release bucket and checked against the human-reviewed sha256
# stored there (update-pins.sh takes it from the GPG-signed manifest.json). No
# `curl | bash` installer and no vendor code runs during the install.
#
# Files are laid out exactly as the official native installer does, so Claude
# Code's own auto-updater takes over from the first launch:
#   $XDG_DATA_HOME/claude/versions/<version>   the binary (default ~/.local/share)
#   ~/.local/bin/claude -> <that file>         the launcher symlink
# Not `<binary> install <version>`: that marks the install as pinned
# (autoUpdates=false in ~/.claude.json). Without it the install method is
# unset, and Claude Code records "native" by itself on its first update.
#
# Install-only: when ~/.local/bin/claude already exists (any version, or a
# launcher the user made), this step does nothing. The pin only seeds fresh
# machines; updates are Claude Code's job (auto-update / `claude update`).
set -Eeuo pipefail
[ -n "${DOTFILES_DEBUG:-}" ] && set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
# shellcheck source-path=SCRIPTDIR source=../lib/secure_fetch.sh
. "$SCRIPT_DIR/../lib/secure_fetch.sh"
# shellcheck source-path=SCRIPTDIR source=../lib/toml_get.sh
. "$SCRIPT_DIR/../lib/toml_get.sh"
readonly PINNED="$SCRIPT_DIR/../pinned.toml"

# Same locations Claude Code's updater uses: it honours XDG_DATA_HOME for the
# versions dir, while the launcher stays in ~/.local/bin.
readonly BIN_DIR="$HOME/.local/bin"
readonly VERSIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/claude/versions"
readonly LAUNCHER="$BIN_DIR/claude"
readonly RELEASES_URL="https://downloads.claude.ai/claude-code-releases"

info() { echo "[claude-code] $*"; }
warn() { echo "[claude-code] WARN: $*" >&2; }
die() { echo "[claude-code] ERROR: $*" >&2; exit 1; }

if [ -e "$LAUNCHER" ] || [ -L "$LAUNCHER" ]; then
  info "$LAUNCHER present — skipping (Claude Code updates itself)"
  exit 0
fi

# Platform token as used in manifest.json and the bucket path.
case "$(uname -s)" in
  Darwin) os=darwin ;;
  Linux) os=linux ;;
  *) die "unsupported OS: $(uname -s)" ;;
esac
case "$(uname -m)" in
  x86_64 | amd64) arch=x64 ;;
  arm64 | aarch64) arch=arm64 ;;
  *) die "unsupported arch: $(uname -m)" ;;
esac
# A shell running as x64 under Rosetta 2 still gets the native arm64 binary.
if [ "$os" = darwin ] && [ "$arch" = x64 ] \
  && [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || true)" = 1 ]; then
  arch=arm64
fi
if [ "$os" = linux ]; then
  # Only the glibc builds are pinned. `case` instead of `ldd | grep -q`, which
  # can fail under pipefail when grep exits early.
  if [ -f /lib/libc.musl-x86_64.so.1 ] || [ -f /lib/libc.musl-aarch64.so.1 ] \
    || { command -v ldd >/dev/null 2>&1 && case "$(ldd /bin/ls 2>&1)" in *musl*) true ;; *) false ;; esac; }; then
    warn "musl libc detected; only glibc builds are pinned — skipping"
    exit 0
  fi
fi

ver="$(toml_get "$PINNED" claude-code version)"
sha="$(toml_get "$PINNED" claude-code "sha256_${os}_${arch}")"
[[ "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "pinned.toml: invalid [claude-code] version: '$ver'"
[ -n "$sha" ] || die "pinned.toml: missing [claude-code] sha256_${os}_${arch}"

dest="$VERSIONS_DIR/$ver"
mkdir -p "$VERSIONS_DIR" "$BIN_DIR"

# Reuse an already-present binary for this version only if it matches the pin.
if [ -f "$dest" ] && [ "$(_sf_sha256 "$dest")" = "$sha" ]; then
  info "reusing verified $dest"
  chmod 0755 "$dest" # a restored copy may have lost its execute bit
else
  # Download next to the destination, then rename: the final path never holds
  # a partial or unverified file.
  tmp="$VERSIONS_DIR/.claude-$ver.$$"
  trap 'rm -f -- "$tmp"' EXIT
  info "fetching Claude Code $ver ($os-$arch, verifying sha256)"
  secure_fetch "$RELEASES_URL/$ver/$os-$arch/claude" "$sha" "$tmp" \
    || die "download or sha256 verification failed"
  chmod 0755 "$tmp"
  mv -f "$tmp" "$dest"
fi

# Check the binary before publishing the launcher: a launcher left pointing at a
# broken binary would make every later run skip this step.
out="$("$dest" --version 2>/dev/null)" || die "$dest --version failed"
got="$(printf '%s\n' "$out" | awk 'NR==1{print $1}')"
[ "$got" = "$ver" ] || die "$dest --version reported '${got:-nothing}', expected $ver"

ln -s "$dest" "$LAUNCHER"
info "installed Claude Code $ver -> $LAUNCHER"
