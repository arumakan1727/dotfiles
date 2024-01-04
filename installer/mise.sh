#!/bin/bash
set -Eeuo pipefail

# ref: https://mise.jdx.dev/getting-started.html#alternate-installation-methods

export MISE_INSTALL_PATH=${MISE_INSTALL_PATH:-"$HOME/.local/bin/mise"}

check_gpg_command_installed() {
  if ! command -v gpg &> /dev/null; then
    echo '[ERR] gpg command not found!'
    exit 1
  fi
}

ensure_gpg_key_installed() {
  readonly key_id="0x29DDE9E0"

  check_gpg_command_installed

  if ! gpg --list-keys "$key_id" &> /dev/null; then
    gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "$key_id"
  fi
}

ensure_mise_installed() {
  if [[ -x "$MISE_INSTALL_PATH" ]]; then
    echo '[OK] mise is already installed.'
    return
  fi

  ensure_gpg_key_installed
  sh -c "$(curl -sSf https://mise.jdx.dev/install.sh.sig | gpg --decrypt)"
}

ensure_mise_installed

# install tools defined in ~/.config/mise/config.toml
"$MISE_INSTALL_PATH" install

"$MISE_INSTALL_PATH" doctor
