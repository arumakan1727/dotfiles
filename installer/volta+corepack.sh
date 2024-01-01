#!/bin/bash
set -Eeuo pipefail

export VOLTA_HOME="${VOLTA_HOME:-$HOME/.volta}"
readonly volta="$VOLTA_HOME/bin/volta"

if [[ ! -x "$volta" ]]; then
  curl -sSf https://get.volta.sh | bash -s -- --skip-setup
else
  echo "volta is already installed."
fi

# corepack requires node
[[ -e "$VOLTA_HOME/bin/node" ]] || "$volta" install node

[[ -e "$VOLTA_HOME/bin/corepack" ]] || "$volta" install corepack

"$VOLTA_HOME/bin/corepack" enable --install-directory "$VOLTA_HOME/bin" \
  npm yarn pnpm
