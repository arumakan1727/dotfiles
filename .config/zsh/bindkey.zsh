# Emacs 風のキーバインドを使用 (他に Vim 風もある)
bindkey -e 

function ghq-fzf() {
  local src="$(ghq list | fzf)"
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ghq-fzf
bindkey '^]' ghq-fzf

# Shift+Tab で前の選択肢へ移動
bindkey '^[[Z' reverse-menu-complete
