export ZSH_PLUGIN_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zsh-plugin"

plugin() {
  local repo="$1"
  local dir="$ZSH_PLUGIN_HOME/$repo"
  if [[ ! -d "$dir" ]]; then
    echo >&2 -e "\x1b[36;1m[INFO] Installing zsh plugin $repo\x1b[m"
    git clone --depth 1 https://github.com/$repo "$dir"
  fi

  local s=${$(basename $repo)%.zsh}
  if [[ -e "$dir/$s.zsh" ]]; then
    source "$dir/$s.zsh"
  elif [[ -e "$dir/$s.plugin.zsh" ]]; then
    source "$dir/$s.plugin.zsh"
  fi
}

# Plugin list
plugin zdharma-continuum/fast-syntax-highlighting
plugin zsh-users/zsh-autosuggestions
plugin zsh-users/zsh-completions
unset -f plugin

# autosuggestions
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# Hooks
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v direnv   &>/dev/null && eval "$(direnv hook zsh)"

# fzf
if [[ ! -d "$HOME/.fzf" ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install"
fi
FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
FZF_DEFAULT_COMMAND+=" -g '!.git/'"
FZF_DEFAULT_COMMAND+=" -g '!node_modules/'"
FZF_DEFAULT_COMMAND+=" -g '!.venv'"
export FZF_DEFAULT_COMMAND
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 60% --reverse --border'
export FZF_ALT_C_COMMAND='fd --type=d --follow --hidden --follow --exclude=.git'
source "$HOME/.fzf.zsh"
