#!/bin/bash
set -Eeuo pipefail

readonly WORK_DIR="${WORK_DIR:-/tmp/armkn-dotfiles-font-install}"

case "$(uname -s)" in
  Darwin) fonts_dir="$HOME/Library/Fonts" ;;
  *) fonts_dir="$HOME/.local/share/fonts" ;;
esac

readonly fonts_dir
mkdir -p "$fonts_dir" "$WORK_DIR"

cd "$WORK_DIR"

log_run() {
  echo -e >&2 "$@"
  "$@"
}

install_yuru7_nerd_font() {
  local repo="$1"
  local install_name="$2"

  local url
  url="$(curl -fsSL "https://api.github.com/repos/yuru7/$repo/releases/latest" | jq -r '.assets | .[].browser_download_url' | grep -F -e '_NF_' -e 'Nerd')"

  if [[ ! -s "${install_name}.zip" ]]; then
    log_run curl --progress-bar -fL "$url" -o "tmp.${install_name}.zip"
    mv "tmp.${install_name}.zip" "${install_name}.zip"
  fi
  unzip -j -o "${install_name}.zip" -d "$fonts_dir/$install_name"
}

ensure_ryanoasis_nerd_font_release_meta_json_downloaded() {
  local json="ryanoasis_nerd_font_release_meta.json"
  [[ -s "$json" ]] || curl -fsSL 'https:/api.github.com/repos/ryanoasis/nerd-fonts/releases/latest' -o "$json"
  echo "$json"
}

install_ryanoasis_nerd_font() {
  local font_name="$1"
  local install_name="${font_name}-NF"

  local release_meta_json
  release_meta_json="$(ensure_ryanoasis_nerd_font_release_meta_json_downloaded)"

  local url
  url="$(< "$release_meta_json" jq -r ".assets[] | select(.name == \"${font_name}.tar.xz\") | .browser_download_url")"

  local xz="${install_name}.tar.xz"
  if [[ ! -s "$xz" ]]; then
    log_run curl --progress-bar -fL "$url" -o "tmp.$xz"
    mv "tmp.$xz" "$xz"
  fi

  mkdir -p "$fonts_dir/$install_name"
  log_run tar xf "$xz" -C "$fonts_dir/$install_name"
}

install_yuru7_nerd_font udev-gothic UDEVGothic
install_yuru7_nerd_font Firge Firge
install_yuru7_nerd_font HackGen HackGen
install_yuru7_nerd_font PlemolJP PlemolJP

install_ryanoasis_nerd_font JetBrainsMono
install_ryanoasis_nerd_font FiraCode
install_ryanoasis_nerd_font Hack
install_ryanoasis_nerd_font IBMPlexMono
install_ryanoasis_nerd_font JetBrainsMono

# Don't check `command -v fc-cache` because fc-cache can be installed in macOS via Homebrew
if [[ $(uname -s) == Linux ]]; then
  fc-cache -fv
fi

rm -rf "$WORK_DIR"
