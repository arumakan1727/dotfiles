#!/bin/bash
set -Eeuo pipefail

os="$(uname -s)"

out="$HOME/.gnupg/gpg-agent.conf"

case "$os" in
  Darwin)
    echo "pinentry-program $(which pinentry-mac)" > "$out"
    ;;
  *)
    echo "[WARN] Unsupported OS Type: $os"
    ;;
esac

gpgconf --kill gpg-agent
