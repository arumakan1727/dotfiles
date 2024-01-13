#!/bin/bash
set -Eeuo pipefail

os="$(uname -s)"
readonly os

if [[ "$os" != Darwin ]]; then
  echo "Not on macOS. Skipping Homebrew installation."
  exit
fi

arch="$(uname -m)"
readonly arch

if [[ "${arch}" == "arm64" ]]; then
  readonly homebrew_prefix="/opt/homebrew"
  readonly homebrew_repository="$homebrew_prefix"
else
  readonly homebrew_prefix="/usr/local"
  readonly homebrew_repository="${homebrew_prefix}/Homebrew"
fi

if [[ -d "$homebrew_repository" ]]; then
  echo "Found ${homebrew_repository}. Skipping Homebrew installation."
  exit
fi

# shellcheck disable=SC2016
echo "/bin/bash -c" '"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
