#!/bin/bash
set -euo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

installDir="${NVIM_INSTALL_DIR:-/usr/local}"
workDir="$(mktemp -d)"

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  echo -e "${CYAN}cleanup ${workDir}${NOFORMAT}"
  rm -rf "$workDir"
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}


###### Application logic ######
setup_colors
cd "$workDir"

case "$(uname -s)" in
  'Darwin') tgz='nvim-macos.tar.gz' ;;
  'Linux') tgz='nvim-linux64.tar.gz' ;;
  *)
    die "Error: Only supported 'Darwin' or 'Linux', but got $(uname -s)"
    ;;
esac

if [ ! -e "$installDir" ]; then
  die "Error: Directory not found: $installDir"
fi

urlPrefix='https://github.com/neovim/neovim/releases/download/nightly/'
echo "fetching ${urlPrefix}${tgz} ..."
curl --progress-bar -fLO "${urlPrefix}${tgz}"
echo "verifying sha256sum ..."
curl -fsSL "${urlPrefix}${tgz}.sha256sum" | sha256sum --check

tar xf "$tgz"
extractedDir="${tgz%.tar.gz}"

if [ ! -O "$installDir" ]; then
  sudo chown -R root:root "$extractedDir"
  sudo=sudo
else
  sudo=''
fi

# NOTE: DO NOT remove trailing slash at 1st argument.
$sudo rsync -au "$extractedDir/" "$installDir"
echo -e "${GREEN}Successfully installed neovim nightly in ${installDir}${NOFORMAT}"
