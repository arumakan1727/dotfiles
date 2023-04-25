# Emacs 風のキーバインドを使用 (他に Vim 風もある)
bindkey -e

## ghq 配下のリポジトリを fzf で選択 -> 自動で tmux セッションの作成/リネーム
function ghq-fzf-tmux() {
  local repo dir target_session current_session

  repo="$(ghq list | fzf)"
  [[ -z "$repo" ]] && return 1

  dir="$(ghq root)/$repo"

  if [[ -z $TMUX ]]; then
    BUFFER="cd $dir"
    zle accept-line && zle -R -c
    return 0
  fi

  # strip first path component + replace . to _ (because `.` cannot be used in session name)
  # ex) "github.com/arumakan1727/dotfiles" -> "arumakan1727/dotfiles"
  target_session="${${repo#*/}//./_}"
  current_session="$(tmux display-message -pF '#{session_name}')"

  if [[ "$current_session" = "$target_session" ]]; then
    BUFFER="cd $dir"
    zle accept-line && zle -R -c
    return 0
  fi

  # もし target_session が存在しなければセッションを作成
  if [[ -z "$(tmux ls -F '#S' -f "#{m:${target_session},#S}")" ]]; then
    tmux new-session -d -c "$dir" -s "$target_session"
  fi
  tmux switch-client -t "$target_session"
}

zle -N ghq-fzf-tmux
bindkey '^]' ghq-fzf-tmux

# Shift+Tab で前の選択肢へ移動
bindkey '^[[Z' reverse-menu-complete
