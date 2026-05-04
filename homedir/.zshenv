export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export GOPATH="$HOME/.go"
export CARGO_HOME="$HOME/.cargo"
export PNPM_HOME="$HOME/.pnpm"
export RYE_HOME="$HOME/.rye"
export VOLTA_HOME="$HOME/.volta"

export MISE_DATA_DIR="$XDG_DATA_HOME/mise"
export MISE_CACHE_DIR="$XDG_CACHE_HOME/mise"

export AQUA_GLOBAL_CONFIG="$XDG_CONFIG_HOME/aquaproj-aqua/aqua.yaml"
export AQUA_ROOT_DIR="$HOME/.aqua"

if [[ -r "/run/user/$UID/docker.sock" ]]; then
  export DOCKER_HOST="unix:///run/user/$UID/docker.sock"
fi

typeset -U path manpath infopath sudo_path
typeset -xT SUDO_PATH sudo_path

# load locale.conf in XDG paths.
# /etc/locale.conf loads and overrides by kernel command line is done by systemd
# But we override it here, see FS#56688
if [[ -z "$LANG" ]]; then
  if [[ -r "$XDG_CONFIG_HOME/locale.conf" ]]; then
    . "$XDG_CONFIG_HOME/locale.conf"
  elif [[ -r "$HOME/.config/locale.conf" ]]; then
    . "$HOME/.config/locale.conf"
  elif [[ -r /etc/locale.conf ]]; then
    . /etc/locale.conf
  fi
fi

# define default LANG to C if not already defined
LANG=${LANG:-C}

# export all locale (7) variables when they exist
export LANG LANGUAGE LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY \
       LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT \
       LC_IDENTIFICATION


if [[ $OSTYPE = darwin* ]]; then
  if [[ -d /opt/homebrew ]]; then
    export HOMEBREW_PREFIX=/opt/homebrew
    export HOMEBREW_REPOSITORY=$HOMEBREW_PREFIX
    export HOMEBREW_CELLAR=$HOMEBREW_PREFIX/Cellar
  elif [[ -d /usr/local/Homebrew ]]; then
    export HOMEBREW_PREFIX=/usr/local
    export HOMEBREW_REPOSITORY=$HOMEBREW_PREFIX/Homebrew
    export HOMEBREW_CELLAR=$HOMEBREW_PREFIX/Cellar
  fi
fi

# PATH, fpath, manpath, infopath are set in ~/.zshrc (after path_helper)

if (( $+commands[nvim] )); then
  export EDITOR=nvim
  # 親プロセスから注入された値を尊重 (Claude Code の settings.json 等)
  export MANPAGER="${MANPAGER:-nvim +Man!}"
else
  export EDITOR=vim
fi

export LESS='--no-init --quit-if-one-screen -R --LONG-PROMPT -i --shift 4 --jump-target=3'

if [[ -o interactive ]]; then
  # setopt no_global_rcs # Don't read /etc/zprofile, etc.

  export GPG_TTY="$TTY"

  if [[ ! -s ~/.zshrc.zwc || ~/.zshrc -nt ~/.zshrc.zwc ]]; then
    zcompile ~/.zshrc 2>/dev/null
  fi
fi
