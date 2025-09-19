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

source "$HOME/.config/zsh/nonlazy/base.zsh"
source "$HOME/.config/zsh/nonlazy/hooks.zsh"
source "$HOME/.config/zsh/nonlazy/sheldon.zsh"

zsh-defer source "$HOME/.config/zsh/lazy/aliases.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/bindkey.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/cli-opts.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/colors.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/completion.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/ghq-fzf.zsh"
zsh-defer source "$HOME/.config/zsh/lazy/zeno.zsh"

source "$HOME/.p10k.zsh"

[[ -s ~/.zshrc.local ]] && zsh-defer source "$HOME/.zshrc.local"

zsh-defer unfunction source
