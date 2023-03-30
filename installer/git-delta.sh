#!/bin/bash
scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
source "$scriptDir"/_helpers_.sh

pkgName='git-delta'
latestVer="$(fetchLatestTagInGitHub dandavison/delta)"
currentVer="$(delta --version 2>/dev/null | grep -wo '[0-9][0-9.]*' || echo 'Not-installed')"
logInfo "${pkgName} latest version:  ${latestVer}"
logInfo "${pkgName} current version: ${currentVer}"

if [ "$currentVer" == "$latestVer" ] && [ "${DELTA_FORCE_INSTALL:-off}" == off ]; then
  logOK "Skip installation: already latest version"
  exit 0
fi

kernel="$(uname -s)"
case "$kernel" in
  'Darwin') logRun brew install "$pkgName" && exit 0 ;;
  'Linux') ;;
  *) die "Unsupported kernel: $kernel" ;;
esac

installByTar() {
  installDir="${DELTA_INSTALL_DIR:-/usr/local}"
  [ ! -e "$installDir" ] && die "Directory not found: $installDir"

  case "$(uname -m)" in
    'x86_64' | 'amd64') archCode='x86_64' ;;
    'aarch64' | 'arm64') archCode='aarch64' ;;
    *) die "Unsupported arch: $(uname -m)" ;;
  esac
  tgz="delta-${latestVer}-${archCode}-unknown-linux-gnu.tar.gz"
  url="https://github.com/dandavison/delta/releases/download/$latestVer/$tgz"

  switchToTempDir
  logInfo "installDir=${installDir}"
  logInfo "workDir=${PWD}"
  logRun curl --progress-bar -fLO "$url"

  tar xf "$tgz"
  extractedDir="${tgz%.tar.gz}"

  if [ ! -O "$installDir" ]; then
    sudo chown 0:0 "$extractedDir/delta"
    sudo=sudo
  else
    sudo=''
  fi

  $sudo mkdir -p "$installDir/bin"
  logRun $sudo mv "$extractedDir/delta" "$installDir/bin"
}

distribName="$(fetchDistribName)"
case "$distribName" in
  'Ubuntu') installByTar ;;
  *) die "Unsupported distribution: $distribName" ;;
esac

logOK "Installed ${pkgName}"
