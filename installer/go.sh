#!/bin/bash
set -euo pipefail

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

setup_colors
goLatestVer="$(curl -fsSL https://go.dev/VERSION?m=text)"
goCurrentVer="$(go version 2>/dev/null | grep -wo 'go[1-9][0-9.]*' || echo 'Not-installed')"
echo -e "${CYAN}[INFO] Golang latest version:  ${goLatestVer}${NOFORMAT}"
echo -e "${CYAN}[INFO] Golang current version: ${goCurrentVer}${NOFORMAT}"

if [ "$goCurrentVer" == "$goLatestVer" ] && [[ ! -v FORCE_INSTALL_GO ]]; then
  echo "${CYAN}Skip installation: golang is already latest version${NOFORMAT}"
  exit 0
fi

installDir="${GO_INSTALL_DIR:-/usr/local}"
if [ ! -e "$installDir" ]; then
  die "Error: Directory not found: $installDir"
fi

workDir="$(mktemp -d)"
cd "$workDir"
trap cleanup SIGINT SIGTERM ERR EXIT
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  echo "cleanup ${workDir}"
  rm -rf "$workDir"
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

case "$(uname -sm)" in
  'Darwin x86_64') archCode='darwin-amd64' ;;
  'Darwin arm64') archCode='darwin-arm64' ;;
  'Linux x86_64') archCode='linux-amd64' ;;
  *)
    die "Error: Supported arch is 'Darwin x86_64' | 'Darwin arm64' | 'Linux x86_64', but got $(uname -sm)"
    ;;
esac

tgz="${goLatestVer}.${archCode}.tar.gz"
url="https://go.dev/dl/$tgz"

echo "fetching ${url} ..."
curl --progress-bar -fLO "$url"

if [ ! -O "$installDir" ]; then
  sudo=sudo
else
  sudo=''
fi
$sudo rm -rf "$installDir/go"
$sudo tar -C "$installDir" -xf "$tgz"
echo -e "${GREEN}Successfully installed golang into ${installDir}${NOFORMAT}"
