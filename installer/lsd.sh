#!/bin/bash
scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
source "$scriptDir"/_helpers_.sh

pkgName='lsd'
binName='lsd'
gitRepo='lsd-rs/lsd'
latestVer="$(fetchLatestTagInGitHub $gitRepo)"
currentVer="$($binName --version 2>/dev/null | grep -wo '[0-9][0-9.]*' || echo 'Not-installed')"
logInfo "${pkgName} latest version:  ${latestVer}"
logInfo "${pkgName} current version: ${currentVer}"

if [ "$currentVer" == "$latestVer" ] && [ "${LSD_FORCE_INSTALL:-off}" == off ]; then
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
  local installDir
  installDir=$(realpath "${LSD_INSTALL_DIR:-/opt}")
  [ ! -e "$installDir" ] && die "Directory not found: $installDir"

  case "$(uname -m)" in
    'x86_64' | 'amd64') local archCode='x86_64' ;;
    'aarch64' | 'arm64') local archCode='aarch64' ;;
    *) die "Unsupported arch: $(uname -m)" ;;
  esac
  local tgz="${pkgName}-${latestVer}-${archCode}-unknown-linux-gnu.tar.gz"
  local url="https://github.com/$gitRepo/releases/download/$latestVer/$tgz"

  switchToTempDir
  logInfo "installDir=${installDir}"
  logInfo "workDir=${PWD}"
  logRun curl --progress-bar -fLO "$url"

  tar xf "$tgz"
  local extractedDir="${tgz%.tar.gz}"
  local pkgDir="$installDir/$binName"

  if [ ! -O "$installDir" ]; then
    sudo chown -R 0:0 "$extractedDir"
    sudo mkdir -p /usr/local/share/{man/man1,bash-completion/completions,zsh/site-functions}

    sudo rm -rf "$pkgDir"
    logRun sudo mv "$extractedDir" "$pkgDir"

    logRun sudo ln -sf "$pkgDir/${binName}" /usr/local/bin/
    logRun sudo ln -sf "$pkgDir/${binName}.1" /usr/local/share/man/man1/
    logRun sudo ln -sf "$pkgDir/autocomplete/_${binName}" /usr/local/share/zsh/site-functions/
    logRun sudo ln -sf "$pkgDir/autocomplete/${binName}.bash-completion" /usr/local/share/bash-completion/completions/${binName}
  else
    rm -rf "$pkgDir"
    logRun mv "$extractedDir" "$pkgDir"
  fi
}

distribName="$(fetchDistribName)"
case "$distribName" in
  'Ubuntu') installByTar ;;
  *) die "Unsupported distribution: $distribName" ;;
esac

logOK "Installed ${pkgName}"
