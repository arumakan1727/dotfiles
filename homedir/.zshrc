# Select tmux session interactively
#====================================
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
#====================================
d="$HOME/.config/zsh"
source "$d/base.zsh"
source "$d/completion.zsh"
source "$d/bindkey.zsh"
source "$HOME/.config/sh/alias.sh"
unset d


# plugins
#====================================
export ZSH_PLUGIN_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zsh-plugin"

plugin() {
  local repo="$1"
  local dir="$ZSH_PLUGIN_HOME/$repo"
  if [[ ! -d "$dir" ]]; then
    echo >&2 -e "\x1b[36;1m[INFO] Installing zsh plugin $repo\x1b[m"
    git clone --depth 1 https://github.com/$repo "$dir"
  fi
  source "$dir/$(basename $repo).plugin.zsh"
}
plugin zdharma-continuum/fast-syntax-highlighting
plugin zsh-users/zsh-autosuggestions
plugin zsh-users/zsh-completions
plugin zsh-users/zsh-history-substring-search
unset -f plugin

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v direnv   &>/dev/null && eval "$(direnv hook zsh)"

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow'
export FZF_DEFAULT_OPTS='--height 60% --reverse --border'
export FZF_ALT_C_COMMAND='fd --type=d --follow --hidden --follow --exclude=.git'
safe_source "$HOME/.fzf.zsh"


safe_source "$HOME/.zshrc.local"
