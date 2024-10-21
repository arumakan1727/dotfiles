#!/bin/bash
set -Eeuo pipefail

export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"

if [[ -d "$RUSTUP_HOME/toolchains" && -x "$CARGO_HOME/bin/rustup" ]]; then
  echo "[OK] rustup is already installed!"
else
  # install stable toolchain
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --no-modify-path --default-toolchain stable --profile default
fi

# install cargo-binstall
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
