# Zeno
# https://github.com/yuki-yano/zeno.zsh

export ZENO_ENABLE_SOCK=1

export ZENO_GIT_CAT="bat --color=always"

export ZENO_GIT_TREE="lsd -a --tree --depth 4 -I .git -I node_modules -I .venv -I __pycache__"

if [[ -n $ZENO_LOADED ]]; then
  bindkey ' '  zeno-auto-snippet
  bindkey '^x^i' zeno-completion
  bindkey '^x^s' zeno-insert-snippet
  bindkey '^r'   zeno-history-selection
fi
