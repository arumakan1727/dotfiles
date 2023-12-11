#!/usr/bin/env bash
set -Eeuo pipefail

### このスクリプトの処理
# ~/.config/ と ~/Library/Application Support/ 以下の symlink を削除し、
# dotfile の内容をコピーする。

### 目的
# これまで ~/.config/ 以下のエントリを個別に symlink して dotfiles で管理していたのを、
# ~/.config ディレクトリそのものを symlink して dotfiles で管理するため。

SAVEIFS="$IFS"
IFS="$(echo -en '\n\b')"

for src in homedir/.config/* ; do
  dst="$HOME/.config/$(basename "$src")"

  if [[ ! -L "$dst" ]]; then
    echo "WARN: Not a symlink, skip: '$dst'"
    continue
  fi

  echo "$src  ->  $dst"

  rm "$dst"
  cp -r "$src" "$dst"
done

for src in $(find 'homedir/Library/Application Support/' -type f) ; do
  dst="${src//homedir/$HOME}"

  if [[ ! -L "$dst" ]]; then
    echo "WARN: Not a symlink, skip: '$dst'"
    continue
  fi

  echo "$src -> $dst"

  rm "$dst"
  cp -r "$src" "$dst"
done

IFS="$SAVEIFS"
