#!/bin/bash
set -euo pipefail
CYAN='\033[36m'
RESET='\033[m'

if [ "$(uname -s)" != "Darwin" ]; then
  exit 0
fi

cmd="brew install coreutils diffutils findutils gawk gnu-sed gnu-tar grep gzip"

echo -e "${CYAN}${cmd}${RESET}"
"$cmd"
