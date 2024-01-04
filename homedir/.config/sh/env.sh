# shellcheck shell=sh

safe_source() {
  if [[ -s "$1" ]]; then
    source "$1"
  fi
}

export EDITOR=nvim
export MANPAGER='nvim +Man!'
export PAGER=less
export LESS='--no-init --quit-if-one-screen -R --LONG-PROMPT -i --shift 4 --jump-target=3'
export GROFF_NO_SGR=1  # for konsole and gnome-terminal

if command -v dircolors >/dev/null 2>&1 ; then
    [ -r "$HOME/.dircolors" ] && source "$HOME/.dircolors" || eval "$(dircolors -b)"
fi

export ZIPINFOOPT="-OCP932"
export UNZIPOPT="-OCP932"

export AQUA_GLOBAL_CONFIG="$HOME/.config/aquaproj-aqua/aqua.yaml"

export GOPATH="$HOME/.go"
export PNPM_HOME="$HOME/.pnpm"
export VOLTA_HOME="$HOME/.volta"
export MISE_DATA_DIR="$HOME/.local/share/mise"

command -v mise >/dev/null 2>&1 && eval "$(mise activate -s $(basename $SHELL))"
