#!/usr/bin/env bash
# chezmoi-step: install the native (standalone) Codex CLI if it is absent.
# Invoked by home/.chezmoiscripts/run_onchange_after_25-agent-clis.sh.tmpl.
#
# The codex-package tarball for the version pinned in ../pinned.toml [codex] is
# fetched from the openai/codex GitHub release and checked against the
# human-reviewed sha256 stored there. No `curl | sh` installer and no vendor
# code runs during the install.
#
# Files are laid out as the official installer (releases.openai.com/codex/
# install.sh, package layoutVersion 1) does, so Codex's own updater
# (`codex update` / the startup update check) takes over afterwards:
#   $CODEX_HOME/packages/standalone/releases/<ver>-<target>/  extracted package
#   $CODEX_HOME/packages/standalone/current -> that release
#   $CODEX_HOME/packages/standalone/auto-update-version       follow "latest"
#   ~/.local/bin/codex -> .../current/bin/codex               the launcher
# CODEX_HOME and CODEX_INSTALL_DIR are honoured like the official installer.
#
# Install-only: when ~/.local/bin/codex already exists (any version), this step
# does nothing. The pin only seeds fresh machines; updates are Codex's job.
set -Eeuo pipefail
[ -n "${DOTFILES_DEBUG:-}" ] && set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
# shellcheck source-path=SCRIPTDIR source=../lib/secure_fetch.sh
. "$SCRIPT_DIR/../lib/secure_fetch.sh"
# shellcheck source-path=SCRIPTDIR source=../lib/toml_get.sh
. "$SCRIPT_DIR/../lib/toml_get.sh"
readonly PINNED="$SCRIPT_DIR/../pinned.toml"

readonly BIN_DIR="${CODEX_INSTALL_DIR:-$HOME/.local/bin}"
readonly STANDALONE_ROOT="${CODEX_HOME:-$HOME/.codex}/packages/standalone"
readonly RELEASES_DIR="$STANDALONE_ROOT/releases"
readonly CURRENT_LINK="$STANDALONE_ROOT/current"
readonly LAUNCHER="$BIN_DIR/codex"
readonly HOST_LAUNCHER="$BIN_DIR/codex-code-mode-host"

info() { echo "[codex] $*"; }
die() { echo "[codex] ERROR: $*" >&2; exit 1; }

if [ -e "$LAUNCHER" ] || [ -L "$LAUNCHER" ]; then
  info "$LAUNCHER present — skipping (Codex updates itself)"
  exit 0
fi

# Print the version of a codex binary ("codex-cli 0.169.0" -> 0.169.0). Fails
# unless `--version` exits 0 and its output ends in a dotted version.
version_of() { # <binary>
  local out v
  out="$("$1" --version 2>/dev/null)" || return 1
  v="$(printf '%s\n' "$out" | awk 'NR==1{print $NF}')"
  [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]] || return 1
  printf '%s\n' "$v"
}

# Replace <link> with a symlink to <target> without a window where it is
# missing. Same fallback chain as the official installer (GNU mv -T, BSD mv -h).
replace_symlink() { # <target> <link>
  local tmp="$2.tmp.$$"
  rm -f -- "$tmp"
  ln -s "$1" "$tmp"
  mv -Tf "$tmp" "$2" 2>/dev/null || mv -hf "$tmp" "$2" 2>/dev/null \
    || { rm -f -- "$2" && mv -f "$tmp" "$2"; }
}

case "$(uname -s)" in
  Darwin) os=darwin ;;
  Linux) os=linux ;;
  *) die "unsupported OS: $(uname -s)" ;;
esac
case "$(uname -m)" in
  x86_64 | amd64) arch=x86_64 ;;
  arm64 | aarch64) arch=aarch64 ;;
  *) die "unsupported arch: $(uname -m)" ;;
esac
# A shell running as x86_64 under Rosetta 2 still gets the native arm64 package.
if [ "$os" = darwin ] && [ "$arch" = x86_64 ] \
  && [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || true)" = 1 ]; then
  arch=aarch64
fi
case "$os" in
  darwin) target="$arch-apple-darwin" ;;
  linux) target="$arch-unknown-linux-musl" ;; # static musl builds run on any distro
esac

if existing="$(version_of "$CURRENT_LINK/bin/codex")"; then
  # A working standalone install exists but the launcher was removed: restore
  # only the launcher and keep whatever version and update policy it has. A
  # broken one falls through to a fresh install instead, so a failed repair
  # never leaves a launcher that makes later runs skip.
  info "existing standalone install found ($existing); restoring launcher only"
else
  ver="$(toml_get "$PINNED" codex version)"
  sha="$(toml_get "$PINNED" codex "sha256_${target//-/_}")"
  [[ "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "pinned.toml: invalid [codex] version: '$ver'"
  [ -n "$sha" ] || die "pinned.toml: missing [codex] sha256_${target//-/_}"

  release_name="$ver-$target"
  release_dir="$RELEASES_DIR/$release_name"
  url="https://github.com/openai/codex/releases/download/rust-v$ver/codex-package-$target.tar.gz"

  mkdir -p "$RELEASES_DIR"
  tmpd="$(mktemp -d "${TMPDIR:-/tmp}/codex-install.XXXXXX")" || die "mktemp failed"
  stage="$RELEASES_DIR/.staging.$release_name.$$"
  trap 'rm -rf -- "$tmpd" "$stage"' EXIT

  info "fetching Codex $ver ($target, verifying sha256)"
  secure_fetch "$url" "$sha" "$tmpd/codex-package.tar.gz" || die "download or sha256 verification failed"

  # Extract into a staging dir next to the final one, then rename into place.
  rm -rf -- "$stage"
  mkdir -p "$stage"
  tar -xzf "$tmpd/codex-package.tar.gz" -C "$stage"
  [ -f "$stage/codex-package.json" ] && [ -f "$stage/bin/codex" ] \
    || die "unexpected package layout (no codex-package.json or bin/codex)"
  chmod 0755 "$stage/bin/codex"
  for f in bin/codex-code-mode-host bin/codex-exec-server codex-path/rg codex-resources/bwrap; do
    [ ! -f "$stage/$f" ] || chmod 0755 "$stage/$f"
  done
  ln -sf bin/codex "$stage/codex"
  got="$(version_of "$stage/bin/codex")" || die "bin/codex --version failed"
  [ "$got" = "$ver" ] || die "bin/codex --version reported '$got', expected $ver"

  # Mark this install as following the "latest" channel, as the official
  # installer does for a default install. Without it Codex treats the install
  # as pinned and its scheduled updates do nothing. Written before the release
  # can become reachable through `current` (which may already point at
  # $release_dir when repairing): once `current` works, later runs only
  # restore the launcher and would never write it.
  printf '%s' "$release_name" > "$STANDALONE_ROOT/auto-update-version.tmp.$$"
  mv -f "$STANDALONE_ROOT/auto-update-version.tmp.$$" "$STANDALONE_ROOT/auto-update-version"

  rm -rf -- "$release_dir"
  mv "$stage" "$release_dir"

  replace_symlink "$release_dir" "$CURRENT_LINK"
  # selection-history lets Codex prune old releases safely: release name,
  # previous selection (none), and the identity of the `current` link
  # (GNU stat -c / BSD stat -f, both inspect the link itself).
  selection_id="$(LC_ALL=C stat -c '%d %i %.9Z' "$CURRENT_LINK" 2>/dev/null \
    || LC_ALL=C stat -f '%d %i %Fc' "$CURRENT_LINK")"
  printf '%s\n%s\n%s\n' "$release_name" "" "$selection_id" > "$STANDALONE_ROOT/selection-history.tmp.$$"
  mv -f "$STANDALONE_ROOT/selection-history.tmp.$$" "$STANDALONE_ROOT/selection-history"
fi

mkdir -p "$BIN_DIR"
# The official installer exposes codex-code-mode-host on macOS only. Publish it
# before the main launcher: the launcher's presence makes later runs skip, so
# it goes last to keep an interrupted run retryable.
if [ "$os" = darwin ] && [ -x "$CURRENT_LINK/bin/codex-code-mode-host" ]; then
  replace_symlink "$CURRENT_LINK/bin/codex-code-mode-host" "$HOST_LAUNCHER"
fi
replace_symlink "$CURRENT_LINK/bin/codex" "$LAUNCHER"
info "installed Codex $(version_of "$LAUNCHER" || echo '?') -> $LAUNCHER"
