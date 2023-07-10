# shellcheck shell=bash

if [[ -d /opt/homebrew ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew
  export HOMEBREW_CELLAR=/opt/homebrew/Cellar
  export HOMEBREW_REPOSITORY=/opt/homebrew
  eval "$(/opt/homebrew/bin/brew shellenv)"

  path=(
    /opt/homebrew/opt/coreutils/libexec/gnubin
    /opt/homebrew/opt/findutils/libexec/gnubin
    /opt/homebrew/opt/gnu-sed/libexec/gnubin
    /opt/homebrew/opt/gnu-tar/libexec/gnubin
    /opt/homebrew/opt/grep/libexec/gnubin
    /opt/homebrew/opt/unzip/bin
    /opt/homebrew/opt/bash/bin
    /opt/homebrew/opt/llvm/bin
    /opt/homebrew/bin
    /opt/homebrew/sbin
  )
  manpath=(
    /opt/homebrew/opt/coreutils/libexec/gnuman
    /opt/homebrew/opt/findutils/libexec/gnuman
    /opt/homebrew/opt/gnu-sed/libexec/gnuman
    /opt/homebrew/opt/gnu-tar/libexec/gnuman
    /opt/homebrew/opt/grep/libexec/gnuman
    /opt/homebrew/share/man
  )
fi

path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.deno/bin"
  "$HOME/.go/bin"
  "$HOME/.volta/bin"
  "$HOME/.nimble/bin"
  "${path[@]}"
  /usr/local/go/bin
  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
)
PATH="$(echo "${path[@]}" | tr ' ' :)"
MANPATH="$(echo "${manpath[@]}" | tr ' ' :)"
export PATH MANPATH
unset  path manpath

export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline

safe_source() {
  [[ -s "$1" ]] && . "$1"
}

safe_source "$HOME/.config/sh/env.sh"
