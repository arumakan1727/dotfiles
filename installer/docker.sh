#!/bin/bash
scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
source "$scriptDir"/_helpers_.sh

### see: https://docs.docker.com/desktop/install/mac-install/
installDockerDesktopForMac() {
  case "$(uname -m)" in
    aarch64 | arm64) archCode=arm64 ;;
    x86_64 | x64 | amd64) archCode=amd64 ;;
    *) die "Unsupported processor: $(uname -m)" ;;
  esac

  local workDir="$dotfilesCacheHome/docker"
  mkdir -p "$workDir" && cd "$workDir"
  logInfo "workDir=$PWD"

  # Delte files older than 14days from now
  find . -type f -mtime +14 -delete

  dmg=Docker.dmg
  if [ -e "$dmg" ]; then
    logInfo "Skip curl: using cached $dmg"
  else
    logRun curl --progress-bar -fsSLO "https://desktop.docker.com/mac/main/$archCode/$dmg"
    logRun softwareupdate --install-rosetta
  fi

  logRun sudo hdiutil attach Docker.dmg
  logRun sudo /Volumes/Docker/Docker.app/Contents/MacOS/install
  logRun sudo hdiutil detach /Volumes/Docker
  logOK "Installed Docker Desktop"
}


### see: https://docs.docker.com/engine/install/ubuntu/#install-docker-engine
installDockerEngine+ComposeForUbuntu() {
  aptSource=/etc/apt/sources.list.d/docker.list

  if [ ! -e $aptSource ]; then
    logRun sudo apt-get update
    logRun sudo apt-get install ca-certificates gnupg
    logRun sudo mkdir -m 0755 -p /etc/apt/keyrings
    logRun curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      | logRun sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu" \
      "$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | sudo tee $aptSource > /dev/null
  fi

  logRun sudo apt-get update
  logRun sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

case "$(uname -s)" in
  Darwin) installDockerDesktopForMac ;;
  Linux) ;;
  *) die "Unsupported kernel: $(uname -s)" ;;
esac

distrib="$(fetchDistribName)"
case "$distrib" in
  Ubuntu) installDockerEngine+ComposeForUbuntu ;;
  *) die "Unsupported linux distribution: $distrib" ;;
esac
