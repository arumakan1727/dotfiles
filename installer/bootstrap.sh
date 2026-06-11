#!/usr/bin/env bash
# Bootstrap installer: install pinned, checksum-verified `chezmoi` and `mise`
# binaries into ~/.local/bin WITHOUT a package manager and WITHOUT a
# `curl | sh` pipe. These two are the only tools installed this way; from
# here `chezmoi init --apply` + `mise install` take over (mise then owns
# checksum/release-age policy for everything else).
#
# USAGE:
#     ./bootstrap.sh
#
# Override install location with BIN_DIR=/somewhere ./bootstrap.sh
#
# Reads versions and sha256 from ./pinned.toml (the human-reviewed trust
# anchor). Idempotent: re-running with the same pins is a no-op.
set -Eeuo pipefail
[ -n "${DOTFILES_DEBUG:-}" ] && set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
readonly PINNED="$SCRIPT_DIR/pinned.toml"

# shellcheck source-path=SCRIPTDIR source=lib/secure_fetch.sh
. "$SCRIPT_DIR/lib/secure_fetch.sh"

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
readonly BIN_DIR

die() { echo "[ERR] $*" >&2; exit 1; }
info() { echo "[*] $*"; }

# Minimal TOML reader for the restricted grammar used by pinned.toml:
# flat `key = "value"` lines grouped under `[section]` headers, '#' comments.
# No nested tables, arrays, or multiline values.
#   toml_get <file> <section> <key>  -> prints value (empty if not found)
# Keys are matched LITERALLY (not as regex), so metacharacters in a key name
# are safe.
toml_get() {
  local file="$1" section="$2" key="$3"
  awk -v want_section="$section" -v want_key="$key" '
    # skip blank lines and comments
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    # section header: [name]
    /^[[:space:]]*\[/ {
      line = $0
      gsub(/[][[:space:]]/, "", line)   # strip [ ] and spaces -> bare name
      cur = line
      next
    }
    # key line within the wanted section: split on first "=", compare key literally
    cur == want_section {
      eq = index($0, "=")
      if (eq > 0) {
        k = substr($0, 1, eq - 1)
        gsub(/[[:space:]]/, "", k)       # trim all spaces from key token
        if (k == want_key) {
          rest = substr($0, eq + 1)
          if (match(rest, /"[^"]*"/)) {   # value is the first quoted string
            print substr(rest, RSTART + 1, RLENGTH - 2)
            exit
          }
        }
      }
    }
  ' "$file"
}

# Map uname to per-tool os/arch tokens.
detect_platform() {
  local s m
  s="$(uname -s)"
  m="$(uname -m)"
  case "$s" in
    Darwin) CHEZMOI_OS="darwin"; MISE_OS="macos" ;;
    Linux)  CHEZMOI_OS="linux";  MISE_OS="linux" ;;
    *) die "unsupported OS: $s" ;;
  esac
  case "$m" in
    arm64 | aarch64) CHEZMOI_ARCH="arm64"; MISE_ARCH="arm64" ;;
    x86_64 | amd64)  CHEZMOI_ARCH="amd64"; MISE_ARCH="x64" ;;
    *) die "unsupported arch: $m" ;;
  esac
}

# Exact installed-version of a binary (empty if absent). $2 = awk program that
# prints the version token from line 1 of `<bin> --version`.
installed_version() {
  local bin="$1" prog="$2"
  [ -x "$bin" ] || return 0
  "$bin" --version 2>/dev/null | awk "$prog"
}

install_chezmoi() {
  local ver sha url tmpd cur
  ver="$(toml_get "$PINNED" chezmoi version)"
  sha="$(toml_get "$PINNED" chezmoi "sha256_${CHEZMOI_OS}_${CHEZMOI_ARCH}")"
  [ -n "$ver" ] || die "pinned.toml: missing [chezmoi] version"
  [ -n "$sha" ] || die "pinned.toml: missing [chezmoi] sha256_${CHEZMOI_OS}_${CHEZMOI_ARCH}"

  # `chezmoi version` -> "chezmoi version v2.70.5, commit ..."; extract "2.70.5".
  # shellcheck disable=SC2016  # awk program is intentionally literal (no shell expansion)
  cur="$(installed_version "$BIN_DIR/chezmoi" 'NR==1{v=$3; sub(/^v/,"",v); sub(/,.*$/,"",v); print v}')"
  if [ "$cur" = "$ver" ]; then
    info "chezmoi $ver already installed"
    return 0
  fi

  url="https://github.com/twpayne/chezmoi/releases/download/v${ver}/chezmoi_${ver}_${CHEZMOI_OS}_${CHEZMOI_ARCH}.tar.gz"
  tmpd="$(mktemp -d "${TMPDIR:-/tmp}/bootstrap-chezmoi.XXXXXX")" || die "mktemp failed"
  info "fetching chezmoi $ver ($CHEZMOI_OS/$CHEZMOI_ARCH)"
  # `&&` chain short-circuits on the first failure regardless of `set -e`
  # semantics; $tmpd is removed unconditionally afterwards.
  local ok=0
  if secure_fetch "$url" "$sha" "$tmpd/chezmoi.tar.gz" \
    && tar -xzf "$tmpd/chezmoi.tar.gz" -C "$tmpd" \
    && [ -f "$tmpd/chezmoi" ] \
    && install -m 0755 "$tmpd/chezmoi" "$BIN_DIR/chezmoi"; then
    ok=1
  fi
  rm -rf "$tmpd"
  [ "$ok" = 1 ] || die "chezmoi download/verify/install failed"
  info "installed chezmoi $ver -> $BIN_DIR/chezmoi"
}

install_mise() {
  local ver sha url tmpd cur
  ver="$(toml_get "$PINNED" mise version)"
  sha="$(toml_get "$PINNED" mise "sha256_${MISE_OS}_${MISE_ARCH}")"
  [ -n "$ver" ] || die "pinned.toml: missing [mise] version"
  [ -n "$sha" ] || die "pinned.toml: missing [mise] sha256_${MISE_OS}_${MISE_ARCH}"

  # `mise --version` -> "2026.6.1 macos-arm64 (...)"; first token is the version.
  # shellcheck disable=SC2016  # awk program is intentionally literal (no shell expansion)
  cur="$(installed_version "$BIN_DIR/mise" 'NR==1{print $1}')"
  if [ "$cur" = "$ver" ]; then
    info "mise $ver already installed"
    return 0
  fi

  url="https://github.com/jdx/mise/releases/download/v${ver}/mise-v${ver}-${MISE_OS}-${MISE_ARCH}.tar.gz"
  tmpd="$(mktemp -d "${TMPDIR:-/tmp}/bootstrap-mise.XXXXXX")" || die "mktemp failed"
  info "fetching mise $ver ($MISE_OS/$MISE_ARCH)"
  local ok=0
  if secure_fetch "$url" "$sha" "$tmpd/mise.tar.gz" \
    && tar -xzf "$tmpd/mise.tar.gz" -C "$tmpd" \
    && [ -f "$tmpd/mise/bin/mise" ] \
    && install -m 0755 "$tmpd/mise/bin/mise" "$BIN_DIR/mise"; then
    ok=1
  fi
  rm -rf "$tmpd"
  [ "$ok" = 1 ] || die "mise download/verify/install failed"
  info "installed mise $ver -> $BIN_DIR/mise"
}

main() {
  [ -f "$PINNED" ] || die "pinned.toml not found: $PINNED"
  detect_platform
  mkdir -p "$BIN_DIR"
  install_chezmoi
  install_mise

  echo
  info "bootstrap complete."
  case ":$PATH:" in
    *":$BIN_DIR:"*) : ;;
    *) echo "[WARN] $BIN_DIR is not on PATH yet (the shell config fixes this for new shells)." >&2 ;;
  esac
  # When chained from install.sh, that script runs `chezmoi init --apply` itself and
  # prints the closing guidance — so suppress this standalone hint to avoid telling
  # the user to run a step install.sh already ran.
  [ -n "${DOTFILES_BOOTSTRAP_CHAINED:-}" ] && return 0
  cat <<EOF
Next:
  chezmoi init --apply --source="<dotfiles repo path>"
  mise install            # via chezmoi run_once, or run manually
EOF
}

main "$@"
