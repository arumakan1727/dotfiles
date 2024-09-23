# Zeno https://github.com/yuki-yano/zeno.zsh
if (( ! $+commands[deno] )); then
  return
fi

export ZENO_HOME="$HOME/.config/zsh/zeno"

export ZENO_ENABLE_SOCK=1

export ZENO_GIT_CAT="bat --color=always"

export ZENO_GIT_TREE="lsd -a --tree --depth 4 -I .git -I node_modules -I .venv -I __pycache__"

if [[ -n $ZENO_LOADED ]]; then
  bindkey ' '    zeno-auto-snippet
  bindkey '^n'   zeno-completion
  bindkey '^x^s' zeno-insert-snippet
  bindkey '^r'   zeno-history-selection
fi

# kill all zeno process to spawn new zeno with loading latest config.toml
function kill_all_zeno {
  ps -o 'pid=,command=' | sed -nE 's/^\s*([0-9]+)\s+deno run .*zeno\.zsh.*/\1/p' | xargs kill
}
