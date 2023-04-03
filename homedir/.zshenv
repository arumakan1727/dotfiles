typeset -U path PATH manpath sudo_path
typeset -xT SUDO_PATH sudo_path

if [[ -d /opt/homebrew ]]; then
  # GNU コマンドは確実にインストールするので (N-/) によるチェックはしない
  path=(
    /opt/homebrew/opt/coreutils/libexec/gnubin
    /opt/homebrew/opt/findutils/libexec/gnubin
    /opt/homebrew/opt/gnu-sed/libexec/gnubin
    /opt/homebrew/opt/gnu-tar/libexec/gnubin
    /opt/homebrew/opt/grep/libexec/gnubin
    $path
  )
  manpath=(
    /opt/homebrew/opt/coreutils/libexec/gnuman
    /opt/homebrew/opt/findutils/libexec/gnuman
    /opt/homebrew/opt/gnu-sed/libexec/gnuman
    /opt/homebrew/opt/gnu-tar/libexec/gnuman
    /opt/homebrew/opt/grep/libexec/gnuman
  )
fi

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
