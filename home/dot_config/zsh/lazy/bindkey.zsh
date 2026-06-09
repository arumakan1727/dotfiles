autoload -Uz edit-command-line && zle -N edit-command-line
zle -N edit-command-line
bindkey "^o" edit-command-line # コマンドラインをテキストエディタで編集
