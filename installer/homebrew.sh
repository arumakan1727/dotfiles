#!/bin/bash
set -Eeuo pipefail

# 複数ユーザでも Homebrew がうまく動作するように、専用のユーザ (ユーザ名 'homebrew') でインストールする。
# 参考: https://www.codejam.info/2021/11/homebrew-multi-user.html#the-good-dedicate-a-single-user-account-to-homebrew
#
# 既に homebrew_repository (Apple silicon の場合は /opt/homebrew/) が存在する場合はインストール作業をスキップする。
#
# zshrc には alias brew='sudo -Hu homebrew brew' を記載すること。

die() {
  echo >&2 "$1"
  exit 1
}

readonly os
os="$(uname -s)"

if [[ "$os" != Darwin ]]; then
  echo "Not on macOS. Skip installing Homebrew."
  exit
fi

readonly homebrew_user=homebrew

if ! id -u "$homebrew_user" &> /dev/null ; then
  die "Please create a user named '$homebrew_user'"
fi

readonly arch
arch="$(uname -m)"

if [[ "${arch}" == "arm64" ]]; then
  readonly homebrew_prefix="/opt/homebrew"
  readonly homebrew_repository="${homebrew_prefix}"
else
  readonly homebrew_prefix="/usr/local"
  readonly homebrew_repository="${homebrew_prefix}/Homebrew"
fi

# If the directory doesn't exists, install it.
if [[ ! -d "$homebrew_repository" ]]; then
  # shellcheck disable=SC2016
  echo "sudo -Hu $homebrew_user /bin/bash -c" '"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  sudo -Hu "$homebrew_user" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

readonly owner_name
owner_name="$(stat -f '%Su' "$homebrew_repository")"

if [[ "$owner_name" != "$homebrew_user" ]]; then
  echo "owner_name of $homebrew_repository is $owner_name. Changing it to '$homebrew_user' recursively."
  sudo chown -R "$homebrew_user" "$homebrew_repository"
fi
