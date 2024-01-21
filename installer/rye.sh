#!/bin/bash
set -Eeuo pipefail

export RYE_HOME="${RYE_HOME:-$HOME/.rye}"

if [[ ! -x "$RYE_HOME/shims/rye" ]]; then
  curl -sSf https://rye-up.com/get | RYE_INSTALL_OPTION="--yes" bash
fi
