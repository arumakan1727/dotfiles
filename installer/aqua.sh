#!/bin/bash
set -Eeuo pipefail

AQUA_BIN="${AQUA_BIN:-$HOME/.local/bin/aqua}"

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  echo >&2 "Cleanup tempdir: $tempdir"
  rm -rf "$tempdir"
}

log_run() {
  echo -e >&2 "$@"
  "$@"
}

download_and_install() {
  local os arch url tgz
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"
  url="https://github.com/aquaproj/aqua/releases/latest/download/aqua_${os}_${arch}.tar.gz"
  tgz="aqua.tar.gz"

  log_run curl --progress-bar -fL "$url" -o "$tgz"
  tar xvf "$tgz"

  chmod +x ./aqua
  mkdir -p "$(dirname "$AQUA_BIN")"
  mv ./aqua "$AQUA_BIN"
}

main() {
  if [[ ! -x "$AQUA_BIN" ]]; then
    tempdir="$(mktemp -d)"
    trap cleanup SIGINT SIGTERM ERR EXIT

    cd "$tempdir"
    download_and_install
  fi

  "$AQUA_BIN" i -a
}

main
