if [[ -z "$TMUX" && -o interactive ]] && { command -v tmux > /dev/null 2>&1 }; then
  sessions="$(tmux list-sessions)"

  if [[ -z "$sessions" ]]; then
    exec tmux new-session
  fi

  dont_use_tmux="-- Don't use tmux"
  create_new_session="-- Create New Session"

  if command -v fzf > /dev/null 2>&1 ; then
    id="$(echo "$sessions\n$create_new_session\n$dont_use_tmux" | fzf | cut -d: -f1)"
  else
    sessions=( ${(@f)"$(echo "$sessions\n$create_new_session\n$dont_use_tmux")"} )
    select res in $sessions
    do
      id="$(echo $res | cut -d: -f1)"
      break
    done
  fi

  if [[ "$id" = "$create_new_session" ]]; then
    exec tmux new-session
  elif [[ "$id" = "$dont_use_tmux" ]]; then
    :  # do nothing
  else
    exec tmux attach-session -t "$id"
  fi
fi

source $HOME/.config/zsh/base.zsh
source $HOME/.config/zsh/completion.zsh
source $HOME/.config/zsh/function.zsh
source $HOME/.config/zsh/alias.zsh
source $HOME/.config/zsh/bindkey.zsh
source $HOME/.config/zsh/plugins.zsh
source $HOME/.config/zsh/external_tool_init.zsh

[[ -r $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

if command -v zprof > /dev/null 2>&1 ; then
  zprof
fi

# fnm
export PATH=/home/armkn/.fnm:$PATH
(command -v fnm > /dev/null 2>&1) && eval "`fnm env`"
