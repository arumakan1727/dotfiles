# Install plugin manager
if ! (( $+commands[sheldon] )); then
  mkdir -p ~/.local/bin
  curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
fi

export SHELDON_CONFIG_FILE="$HOME/.config/zsh/sheldon.toml"
sheldon_cache="$XDG_CACHE_HOME/zsh/sheldon.zsh"

if [[ ! -s "$sheldon_cache" || "$SHELDON_CONFIG_FILE" -nt "$sheldon_cache" ]]; then
  mkdir -p "$XDG_CACHE_HOME/zsh"
  sheldon source > "$sheldon_cache"
fi

source "$sheldon_cache"

unset sheldon_cache
