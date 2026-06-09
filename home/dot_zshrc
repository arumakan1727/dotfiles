if [[ -n "$ZSHRC_PROFILE" ]]; then
  zmodload zsh/zprof && zprof > /dev/null
fi

function zsh-profile() {
  ZSHRC_PROFILE=1 zsh -i -c zprof
}

# PATH setup (placed here to run after /etc/zprofile's path_helper)
# Reset path to avoid path_helper's reordering being preserved via $path
path=()

if (( $+HOMEBREW_PREFIX )); then
  path=(
    $HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin
    $HOMEBREW_PREFIX/opt/findutils/libexec/gnubin
    $HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin
    $HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin
    $HOMEBREW_PREFIX/opt/grep/libexec/gnubin
    $HOMEBREW_PREFIX/opt/unzip/bin
    $HOMEBREW_PREFIX/opt/bash/bin
    $HOMEBREW_PREFIX/bin
    $HOMEBREW_PREFIX/sbin
  )
  fpath=(
    $HOMEBREW_PREFIX/share/zsh/site-functions
  )
  manpath=(
    $HOMEBREW_PREFIX/opt/coreutils/libexec/gnuman
    $HOMEBREW_PREFIX/opt/findutils/libexec/gnuman
    $HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnuman
    $HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnuman
    $HOMEBREW_PREFIX/opt/grep/libexec/gnuman
    $HOMEBREW_PREFIX/share/man
    $manpath
  )
  infopath=(
    $HOMEBREW_PREFIX/share/info
    $infopath
  )
fi

path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.pnpm"
  "$CARGO_HOME/bin"
  "$GOPATH/bin"
  "$AQUA_ROOT_DIR/bin"
  /usr/local/bin
  $path
  /System/Cryptexes/App/usr/bin(N-/)
  /Applications/Wireshark.app/Contents/MacOS(N-/)
  /Applications/Keybase.app/Contents/SharedSupport/bin(N-/)
  /usr/bin
  /bin
  /usr/sbin
  /sbin
)
fpath=(
  "$HOME/.config/zsh/completion"
  /usr/local/share/zsh/site-functions
  /usr/share/zsh/site-functions
  /usr/share/zsh/*/functions(N-/)
  $fpath
)

# Select tmux session interactively
function select_tmux_session() {
  local sessions="$(tmux list-sessions)"
  [[ -z "$sessions" ]] && exec tmux new-session

  local dont_use_tmux="-- Don't use tmux"
  local create_new_session="-- Create New Session"
  local exit="-- Exit"

  local ans="$(echo -e "$sessions\n$create_new_session\n$dont_use_tmux\n$exit" | fzf | cut -d: -f1)"

  case "$ans" in
    "$dont_use_tmux") ;; # do nothing
    "$create_new_session") exec tmux new-session ;;
    "$exit") exit ;;
    *) exec tmux attach-session -t "$ans" ;;
  esac
}

# VSCode または Cursor から呼び出された場合は tmux セッションの選択をしない
if [[ -z "$TMUX" && -o interactive && "$TERM_PROGRAM" != "vscode" && $TERM_PROGRAM != "WarpTerminal" ]] && (( $+commands[tmux] )) && (( $+commands[fzf] )); then
  # select_tmux_session
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# https://zenn.dev/fuzmare/articles/zsh-plugin-manager-cache
function ensure_zcompiled {
  local compiled="$1.zwc"
  if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
    zcompile "$1" 2>/dev/null
  fi
}

function source {
  ensure_zcompiled "$1"
  builtin source "$1"
}

function source_if_exists {
  if [[ -s "$1" ]]; then source "$1"; fi
}

source "$HOME/.config/zsh/nonlazy/base.zsh"
source "$HOME/.config/zsh/nonlazy/sheldon.zsh"

# mise: source cached activation but defer the initial hook-env subprocess
() {
  local mise_bin="${commands[mise]}"
  local mise_cache="$XDG_CACHE_HOME/zsh/mise.zsh"
  local mise_cache_deferred="$XDG_CACHE_HOME/zsh/mise-deferred.zsh"
  if [[ -n $mise_bin ]]; then
    if [[ ! -s $mise_cache || $mise_bin -nt $mise_cache || ~/.zshrc -nt $mise_cache || ~/.zshenv -nt $mise_cache ]]; then
      mkdir -p "$(dirname "$mise_cache")"
      mise activate -s zsh > $mise_cache
    fi
    if [[ ! -s $mise_cache_deferred || $mise_cache -nt $mise_cache_deferred ]]; then
      sed '/^_mise_hook$/d' $mise_cache > $mise_cache_deferred
    fi
    builtin source $mise_cache_deferred
    zsh-defer _mise_hook
  fi
}

# ~/.npmrc の min-release-age=7 (会社ポリシー) と MISE_INSTALL_BEFORE の --before が
# npm 11 で衝突するため、npm バックエンドの mise install のときだけ専用 npmrc を読ませる
if (( ${+functions[mise]} )); then
  functions -c mise _mise_orig
  mise() {
    case "${1:-}" in
      use|install|i|upgrade|up)
        if [[ "$*" == *npm:* ]]; then
          NPM_CONFIG_USERCONFIG="$HOME/.config/mise/npmrc" _mise_orig "$@"
          return
        fi
        ;;
    esac
    _mise_orig "$@"
  }
fi

# zoxide: cache init output to a file so it can be zcompiled, then source lazily.
# Deferred via zsh-defer (after _mise_hook) because zoxide is installed by mise
# and only appears on PATH once the hook has injected the active tool's bindir.
function _setup_zoxide() {
  local zoxide_bin="${commands[zoxide]}"
  local zoxide_cache="$XDG_CACHE_HOME/zsh/zoxide.zsh"
  if [[ -n $zoxide_bin ]]; then
    if [[ ! -s $zoxide_cache || $zoxide_bin -nt $zoxide_cache || ~/.zshrc -nt $zoxide_cache ]]; then
      mkdir -p "$(dirname "$zoxide_cache")"
      zoxide init zsh > $zoxide_cache
    fi
    source $zoxide_cache
  fi
  unfunction _setup_zoxide
}
zsh-defer _setup_zoxide

# workmux: same pattern as zoxide. workmux is installed via mise, so its bindir
# only appears on PATH after the mise activation block above has sourced.
function _setup_workmux() {
  local workmux_bin="${commands[workmux]}"
  local workmux_cache="$XDG_CACHE_HOME/zsh/workmux.zsh"
  if [[ -n $workmux_bin ]]; then
    if [[ ! -s $workmux_cache || $workmux_bin -nt $workmux_cache || ~/.zshrc -nt $workmux_cache ]]; then
      mkdir -p "$(dirname "$workmux_cache")"
      workmux completions zsh > $workmux_cache 2>/dev/null
    fi
    source $workmux_cache
  fi
  unfunction _setup_workmux
}
zsh-defer _setup_workmux

zsh-defer source "$HOME/.config/zsh/lazy/aliases.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/bindkey.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/cli-opts.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/colors.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/completion.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/ghq-fzf.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/snippets.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/fzf-widgets.zsh"

source "$HOME/.p10k.zsh"

[[ -s ~/.zshrc.local ]] && zsh-defer source "$HOME/.zshrc.local"

zsh-defer unfunction source

fpath+=~/.zfunc; autoload -Uz compinit; compinit -C

zstyle ':completion:*' menu select

export UV_EXCLUDE_NEWER=P7D
export MISE_INSTALL_BEFORE=7d

if command -v wt >/dev/null 2>&1; then zsh-defer eval 'eval "$(command wt config shell init zsh)"'; fi
