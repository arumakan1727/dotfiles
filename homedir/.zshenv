typeset -U path manpath infopath sudo_path
typeset -xT PATH path
typeset -xT MANPATH manpath
typeset -xT INFOPATH infopath
typeset -xT SUDO_PATH sudo_path


if [[ -d /opt/homebrew ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew
  export HOMEBREW_CELLAR=/opt/homebrew/Cellar
  export HOMEBREW_REPOSITORY=/opt/homebrew
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # GNU コマンドは確実にインストールするので (N-/) によるチェックはしない
  path=(
    /opt/homebrew/opt/coreutils/libexec/gnubin
    /opt/homebrew/opt/findutils/libexec/gnubin
    /opt/homebrew/opt/gnu-sed/libexec/gnubin
    /opt/homebrew/opt/gnu-tar/libexec/gnubin
    /opt/homebrew/opt/grep/libexec/gnubin
    /opt/homebrew/opt/unzip/bin
    /opt/homebrew/bin
    /opt/homebrew/sbin
    $path
  )
  manpath=(
    /opt/homebrew/opt/coreutils/libexec/gnuman
    /opt/homebrew/opt/findutils/libexec/gnuman
    /opt/homebrew/opt/gnu-sed/libexec/gnuman
    /opt/homebrew/opt/gnu-tar/libexec/gnuman
    /opt/homebrew/opt/grep/libexec/gnuman
    /opt/homebrew/share/man
    $manpath
  )
  infopath=(
    /opt/homebrew/share/info
    $infopath
  )
fi

path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.deno/bin"
  "$HOME/.go/bin"
  "$HOME/.volta/bin"
  "$HOME/.nimble/bin"(N-/)
  $path
  /usr/local/go/bin
  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
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

source "$HOME/.config/zsh/env.sh"
