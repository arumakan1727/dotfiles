## mise ##
mise_bin="${commands[mise]}"
mise_cache="$XDG_CACHE_HOME/zsh/mise.zsh"

if [[ -n $mise_bin ]]; then
  if [[ ! -s $mise_cache || $mise_bin -nt $mise_cache ]]; then
    mise activate -s zsh > $mise_cache
  fi
  source $mise_cache
fi

unset mise_bin mise_cache
