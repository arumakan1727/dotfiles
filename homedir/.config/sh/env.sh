# shellcheck shell=sh

command -v nvim >/dev/null 2>&1 \
  && export EDITOR=nvim \
  || export EDITOR=vim

export PAGER=less
export LESS='--no-init --quit-if-one-screen -R --LONG-PROMPT -i --shift 4 --jump-target=3'
export GROFF_NO_SGR=1  # for konsole and gnome-terminal

if command -v dircolors >/dev/null 2>&1 ; then
    [ -r "$HOME/.dircolors" ] && eval "$(dircolors -b "$HOME/.dircolors")" || eval "$(dircolors -b)"
fi

command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"
command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"

safe_source() {
  [[ -s "$1" ]] && . "$1"
}

safe_source "$HOME/.sdkman/bin/sdkman-init.sh"
