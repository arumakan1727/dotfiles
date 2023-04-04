# shellcheck shell=sh

safe_source() {
  if [[ -s "$1" ]]; then
    source "$1"
  fi
}

command -v nvim >/dev/null 2>&1 \
  && export EDITOR=nvim \
  || export EDITOR=vim

export PAGER=less
export LESS='--no-init --quit-if-one-screen -R --LONG-PROMPT -i --shift 4 --jump-target=3'
export GROFF_NO_SGR=1  # for konsole and gnome-terminal

if command -v dircolors >/dev/null 2>&1 ; then
    [ -r "$HOME/.dircolors" ] && source "$HOME/.dircolors" || eval "$(dircolors -b)"
fi

export GOPATH="$HOME/.go"
export PNPM_HOME="$HOME/.pnpm"
export PYENV_ROOT="$HOME/.pyenv"
export SDKMAN_DIR="$HOME/.sdkman"
export VOLTA_HOME="$HOME/.volta"

command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"
command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"
safe_source "$HOME/.sdkman/bin/sdkman-init.sh"
