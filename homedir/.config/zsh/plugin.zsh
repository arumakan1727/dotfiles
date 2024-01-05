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
plugin yuki-yano/zeno.zsh
unset -f plugin

# autosuggestions
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# Hooks
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v direnv   &>/dev/null && eval "$(direnv hook zsh)"
command -v mise >/dev/null 2>&1 && eval "$(mise activate -s zsh)"

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
export FZF_ALT_C_COMMAND='fd --type=d --follow --hidden --follow --exclude=.git'
source "$HOME/.fzf.zsh"

export ZIPINFOOPT="-OCP932"
export UNZIPOPT="-OCP932"



# Zeno
# https://github.com/yuki-yano/zeno.zsh

# if enable fzf-tmux
# export ZENO_ENABLE_FZF_TMUX=1

# if setting fzf-tmux options
# export ZENO_FZF_TMUX_OPTIONS="-p"

export ZENO_ENABLE_SOCK=1

# if disable builtin completion
# export ZENO_DISABLE_BUILTIN_COMPLETION=1

export ZENO_GIT_CAT="bat --color=always"

# default
export ZENO_GIT_TREE="lsd -a --tree --depth 4 -I .git -I node_modules -I .venv -I __pycache__"
# git folder preview with color
# export ZENO_GIT_TREE="exa --tree"

if [[ -n $ZENO_LOADED ]]; then
  bindkey ' '  zeno-auto-snippet
  bindkey '^m' zeno-auto-snippet-and-accept-line

  bindkey '^x^i' zeno-completion
  bindkey '^X' zeno-insert-snippet

  # fallback if completion not matched
  # (default: fzf-completion if exists; otherwise expand-or-complete)
  # export ZENO_COMPLETION_FALLBACK=expand-or-complete
fi
