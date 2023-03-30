#!/bin/bash
scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
source "$scriptDir"/_helpers_.sh

pkgName='Golang'
latestVer="$(curl -fsSL https://go.dev/VERSION?m=text)"
currentVer="$(go version 2>/dev/null | grep -wo 'go[1-9][0-9.]*' || echo 'Not-installed')"
logInfo "${pkgName} latest version:  ${latestVer}"
logInfo "${pkgName} current version: ${currentVer}"

if [ "$currentVer" == "$latestVer" ] && [ "${GO_FORCE_INSTALL:-off}" == off ]; then
  logOK "Skip installation: already latest version"
  exit 0
fi

case "$(uname -sm)" in
  'Darwin arm64') archCode='darwin-arm64' ;;
  'Darwin x86_64') archCode='darwin-amd64' ;;
  'Linux x86_64') archCode='linux-amd64' ;;
  *) die "Unsupported architecture: $(uname -sm)" ;;
esac

installDir="${GO_INSTALL_DIR:-/usr/local}"
[ ! -e "$installDir" ] && die "Directory not found: $installDir"

switchToTempDir
logInfo "installDir=${installDir}"
logInfo "workDir=${PWD}"

tgz="${latestVer}.${archCode}.tar.gz"
url="https://go.dev/dl/$tgz"
logInfo "fetching ${url} ..."
curl --progress-bar -fLO "$url"

[ ! -O "$installDir" ] && sudo=sudo || sudo=''
$sudo rm -rf "$installDir/go"
$sudo tar -C "$installDir" -xf "$tgz"
logOK "Installed ${pkgName} in ${installDir}"
