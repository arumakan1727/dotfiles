# shellcheck shell=bash
set -Eeuo pipefail

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

setup_colors

logOK() {
  echo >&2 -e "${GREEN}[OK] ${1-}${NOFORMAT}"
}

logInfo() {
  echo >&2 -e "${CYAN}[INFO] ${1-}${NOFORMAT}"
}

logWarn() {
  echo >&2 -e "${YELLOW}[WARN] ${1-}${NOFORMAT}"
}

logErr() {
  echo >&2 -e "${RED}[ERROR] ${1-}${NOFORMAT}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  logErr "$msg"
  exit "$code"
}

_tempDir1234xyz=""

switchToTempDir() {
  _tempDir1234xyz="$(mktemp -d)"
  trap _cleanupTempDir1234xyz SIGINT SIGTERM ERR EXIT
  cd "$_tempDir1234xyz"
}

_cleanupTempDir1234xyz() {
    trap - SIGINT SIGTERM ERR EXIT
    echo >&2 "cleanup $_tempDir1234xyz"
    rm -rf "$_tempDir1234xyz"
}
