#!/bin/zsh
set -eu

for c in {0..255}; do
  print -nP "%${c}F"
  printf ' %3d ' $c

  print -nP "%f%${c}K"
  printf ' %3d ' $c
  print -nP '%k'
  if (( c % 16 == 15 )); then
    echo
  fi
done
