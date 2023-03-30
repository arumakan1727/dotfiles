#!/bin/bash
scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
source "$scriptDir"/_helpers_.sh

pkgName='xh'
kernel="$(uname -s)"

case "$kernel" in
  'Darwin')
    logRun brew install "$pkgName" && exit 0
    ;;
  'Linux')
    logRun curl -sfL https://raw.githubusercontent.com/ducaale/xh/master/install.sh | sh
    ;;
  *) die "Unsupported kernel: $kernel" ;;
esac
