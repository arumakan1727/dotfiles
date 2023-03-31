#!/bin/bash
scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
source "$scriptDir"/_helpers_.sh

installDir="$HOME/.local/bin"
[ -x "$installDir/gibo" ] && logOK "gibo is already installed"

mkdir -p "$installDir"

url=https://raw.githubusercontent.com/simonwhitaker/gibo/master/gibo
logRun curl --progress-bar -fL $url -o "$installDir/gibo"
logRun chmod +x "$installDir/gibo"
