#!/bin/bash
scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
source "$scriptDir"/_helpers_.sh

installDir="${NVIM_INSTALL_DIR:-/usr/local}"
[ ! -e "$installDir" ] && die "Directory not found: $installDir"

workDir="${dotfilesCacheHome}/nvim-nightly"
mkdir -p "$workDir"

pkgName='Neovim-nightly'

case "$(uname -s)" in
  'Darwin') tgz='nvim-macos.tar.gz' ;;
  'Linux') tgz='nvim-linux64.tar.gz' ;;
  *) die "Unsupported kernel: $(uname -s)" ;;
esac

cd "${workDir}"
logInfo "installDir=${installDir}"
logInfo "workDir=${PWD}"

# Delte files older than 3days from now
find . -type f -name '*.tar.gz' -mtime +3 -delete

if [ -e "$tgz" ]; then
  logInfo "Skip curl: using cached {$tgz}"
else
  urlPrefix='https://github.com/neovim/neovim/releases/download/nightly/'
  logInfo "fetching ${urlPrefix}${tgz} ..."
  curl --progress-bar -fLO "${urlPrefix}${tgz}"

  logInfo "verifying sha256sum ..."
  curl -fsSL "${urlPrefix}${tgz}.sha256sum" | sha256sum --check
fi

tar xf "$tgz"
extractedDir="${tgz%.tar.gz}"

if [ ! -O "$installDir" ]; then
  sudo chown -R 0:0 "$extractedDir"
  sudo=sudo
else
  sudo=''
fi

# NOTE: DO NOT remove trailing slash at 1st argument.
$sudo rsync -au "$extractedDir/" "$installDir"
$sudo rm -rf "$extractedDir"
logOK "Installed ${pkgName} in ${installDir}"
