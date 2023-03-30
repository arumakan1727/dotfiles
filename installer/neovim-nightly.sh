#!/bin/bash
scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
source "$scriptDir"/_helpers_.sh

pkgName='Neovim-nightly'
urlPrefix='https://github.com/neovim/neovim/releases/download/nightly/'

case "$(uname -s)" in
  'Darwin') tgz='nvim-macos.tar.gz' ;;
  'Linux') tgz='nvim-linux64.tar.gz' ;;
  *) die "Unsupported kernel: $(uname -s)" ;;
esac

installDir="${NVIM_INSTALL_DIR:-/usr/local}"
[ ! -e "$installDir" ] && die "Directory not found: $installDir"

switchToTempDir
logInfo "installDir=${installDir}"
logInfo "workDir=${PWD}"

logInfo "fetching ${urlPrefix}${tgz} ..."
curl --progress-bar -fLO "${urlPrefix}${tgz}"

logInfo "verifying sha256sum ..."
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
logOK "Installed ${pkgName} in ${installDir}"
