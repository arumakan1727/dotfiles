if [[ -n "$ZSHRC_PROFILE" ]]; then
  zmodload zsh/zprof && zprof > /dev/null
fi

function zsh-profile() {
  ZSHRC_PROFILE=1 zsh -i -c zprof
}

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

if [[ -z "$TMUX" && -o interactive ]] && (( $+commands[tmux] )) && (( $+commands[fzf] )); then
  select_tmux_session
fi

# https://zenn.dev/fuzmare/articles/zsh-plugin-manager-cache
function ensure_zcompiled {
  local compiled="$1.zwc"
  if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
    echo "Compiling $1"
    zcompile "$1"
  fi
}

function source {
  ensure_zcompiled "$1"
  builtin source "$1"
}

function source_if_exists {
  if [[ -s "$1" ]]; then source "$1"; fi
}

ensure_zcompiled "$HOME/.zshenv"
ensure_zcompiled "$HOME/.zshrc"

source "$HOME/.config/zsh/nonlazy/base.zsh"
source "$HOME/.config/zsh/nonlazy/hooks.zsh"
source "$HOME/.config/zsh/nonlazy/sheldon.zsh"

zsh-defer source "$HOME/.config/zsh/lazy/aliases.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/colors.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/completion.zsh"

if [[ -s ~/.zshrc.local ]]; then
  zsh-defer source "$HOME/.zshrc.local"
fi

zsh-defer unfunction source
