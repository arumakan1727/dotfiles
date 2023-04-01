typeset -U path PATH manpath sudo_path
typeset -xT SUDO_PATH sudo_path

path=(
  /usr/local/go/bin
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.deno/bin"
  "$HOME/.go/bin"
  "$HOME/.volta/bin"
  "$HOME/.pyenv/bin"
  "$HOME/.nimble/bin"(N-/)
  "$HOME/.rbenv/shims"(N-/)
  $path
)

fpath=(
  $HOME/.config/zsh/zfunc(N-/)
  $HOME/.config/zsh/completion(N-/)
  /usr/local/share/zsh/site-functions
  /usr/share/zsh/site-functions
  $fpath
)

command -v nvim &>/dev/null \
  && export EDITOR=nvim \
  || export EDITOR=vim

export PAGER=less
export LESS='--no-init --quit-if-one-screen -R --LONG-PROMPT -i --shift 4 --jump-target=3'
export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline
export GROFF_NO_SGR=1                  # for konsole and gnome-terminal

safe_source() {
  [[ -s "$1" ]] && . "$1"
}

command -v pyenv &>/dev/null && eval "$(pyenv init -)"
command -v rbenv &>/dev/null && eval "$(rbenv init -)"
safe_source "$HOME/.sdkman/bin/sdkman-init.sh"
