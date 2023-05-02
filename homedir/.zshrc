if [[ -n "$ARMKN_ZSHRC_PROFILE" ]]; then
  zmodload zsh/zprof && zprof > /dev/null
fi

function zsh-profile() {
  ARMKN_ZSHRC_PROFILE=1 zsh -i -c zprof
}

# Select tmux session interactively
select_tmux_session() {
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

if [[ -z "$TMUX" && -o interactive ]] && { command -v tmux &>/dev/null } && { command -v fzf &>/dev/null }; then
  select_tmux_session
fi

safe_source() {
  if [[ -s "$1" ]]; then source "$1"; fi
}

# my config modules
d="$HOME/.config/zsh"
source "$d/base.zsh"
source "$d/completion.zsh"
source "$d/bindkey.zsh"
source "$d/alias.sh"
source "$d/plugin.zsh"
unset d

safe_source "$HOME/.zshrc.local"
