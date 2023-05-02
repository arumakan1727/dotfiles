# shellcheck shell=bash

d=/opt/homebrew/opt
path=""
manpath=""
if [[ -d $d ]]; then
  path+=$d/coreutils/libexec/gnubin:
  path+=$d/findutils/libexec/gnubin:
  path+=$d/gnu-sed/libexec/gnubin:
  path+=$d/gnu-tar/libexec/gnubin:
  path+=$d/grep/libexec/gnubin:

  manpath+=$d/coreutils/libexec/gnuman:
  manpath+=$d/findutils/libexec/gnuman:
  manpath+=$d/gnu-sed/libexec/gnuman:
  manpath+=$d/gnu-tar/libexec/gnuman:
  manpath+=$d/grep/libexec/gnuman:
fi

path+="$HOME/bin:"
path+="$HOME/.cargo/bin:"
path+="$HOME/.rye/shims:"
path+="$HOME/.deno/bin:"
path+="$HOME/.go/bin:"
path+="$HOME/.volta/bin:"
path+="$HOME/.pyenv/bin:"
path+="$HOME/.nimble/bin:"
path+="$HOME/.rbenv/shims:"
path+=/usr/local/go/bin:

export PATH="$path$PATH"
export MANPATH="$manpath$MANPATH"
unset d path manpath

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
