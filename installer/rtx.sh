#!/bin/bash
set -Eeuo pipefail

# ref: https://rtx.jdx.dev/getting-started.html#alternate-installation-methods

export RTX_INSTALL_PATH=${RTX_INSTALL_PATH:-"$HOME/.local/bin/rtx"}

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

ensure_rtx_installed() {
  if [[ -x "$RTX_INSTALL_PATH" ]]; then
    echo '[OK] rtx is already installed.'
    return
  fi

  ensure_gpg_key_installed
  sh -c "$(curl -sSf https://rtx.jdx.dev/install.sh.sig | gpg --decrypt)"
}

# install tools defined in ~/.config/rtx/config.toml
"$RTX_INSTALL_PATH" install

"$RTX_INSTALL_PATH" doctor
