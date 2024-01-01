#!/bin/bash
set -Eeuo pipefail

NVIM_TAG="${NVIM_TAG:-stable}"
NVIM_INSTALL_DIR="${NVIM_INSTALL_DIR:-"$HOME/.local/share/nvim_${NVIM_TAG}"}"
NVIM_BIN_SYMLINK="${NVIM_BIN_SYMLINK:-"$HOME/.local/bin/nvim"}"

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  echo >&2 "Cleanup tempdir: $tempdir"
  rm -rf "$tempdir"
}

log_run() {
  echo -e >&2 "$@"
  "$@"
}

die() {
  echo >&2 "$1"
  exit 1
}

get_github_release_tgz_name() {
  local uname_os="$1"

  case "$uname_os" in
    Darwin) echo 'nvim-macos.tar.gz' ;;
    Linux) echo 'nvim-linux64.tar.gz' ;;
    *) die "Unsupported os: $uname_os" ;;
  esac
}

main() {
  tempdir="$(mktemp -d)"
  trap cleanup SIGINT SIGTERM ERR EXIT
  cd "$tempdir"

  local url_prefix tgz
  url_prefix="https://github.com/neovim/neovim/releases/download/$NVIM_TAG"
  tgz="$(get_github_release_tgz_name "$(uname -s)")"

  log_run curl --progress-bar -fLO "$url_prefix/$tgz"

  echo >&2 "Verifying sha256sum..."
  curl -fsSL "$url_prefix/${tgz}.sha256sum" | sha256sum --check

  log_run tar xf "$tgz"

  log_run rm -rf "$NVIM_INSTALL_DIR" "$NVIM_BIN_SYMLINK"

  log_run mv "${tgz%.tar.gz}" "$NVIM_INSTALL_DIR"

  log_run ln -snfv "$NVIM_INSTALL_DIR/bin/nvim" "$NVIM_BIN_SYMLINK"
}

main
