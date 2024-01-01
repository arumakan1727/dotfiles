#!/usr/bin/env bash
set -Eeuo pipefail
# ref: https://betterdev.blog/minimal-safe-bash-script-template/

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
readonly repo_root

usage() {
  cat <<EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(
    basename "${BASH_SOURCE[0]}"
  ) [-h] [-v|--verbose] [-N|--dryrun]

1. Apply this dotfiles to to your home dir using symlink.

Available options:

-h, --help      Print this help and exit.
-v, --verbose   Print script debug info.
-N, --dryrun    Just show what to do. This enables '--verbose'.
EOF
  exit
}

# options default value
verbose=0
dryrun=0

parse_params() {
  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) verbose=1 ;;
    -N | --dryrun)
      dryrun=1
      verbose=1
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  local args=("$@")
  [[ ${#args[@]} -eq 0 ]] || die "This script does NOT receive any arguments"

  readonly verbose dryrun
}

run() {
  if [[ $dryrun -eq 0 ]]; then
    "$@"
  fi
}

verbose_msg() {
  if [[ $verbose -eq 1 ]]; then
    echo -e "$1"
  fi
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    readonly NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    # shellcheck disable=SC2034
    readonly NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

die() {
  echo -e "${RED}[ERR] $1${NOFORMAT}"
  exit "${2-1}" # default exit status 1
}

assert_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || die "No such directory: $dir"
}

symlink() {
  # NOTE: $src and $dst must be absolute path.
  local src="$1"
  local dst="$2"

  local human_readable_src="${src#"$repo_root/"}"
  local human_readable_dst="~${dst#"$HOME"}"

  if [[ -L "$dst" && "$(realpath "$dst")" == "$src" ]]; then
    echo -e "${GREEN}[SKIP] already correctly symlinked: ${human_readable_src}  ->  ${human_readable_dst}${NOFORMAT}"
    return
  fi

  echo -e "${CYAN}[APPLY] $human_readable_src  ->  $human_readable_dst${NOFORMAT}"

  local indent="    "
  verbose_msg "${indent}src=$src"
  verbose_msg "${indent}dst=$dst"

  # If $dst is regular file and not symlink, remove it.
  if [[ -f "$dst" && ! -L "$dst" ]]; then
    verbose_msg "${indent}Removing regular file: rm $human_readable_dst"
    run rm "$dst"

  # If $dst is directory, sync dotfile content to dst and move dst to dotfiles.
  elif [[ -d "$dst" ]]; then
    verbose_msg "${indent}Sync dir content: $human_readable_src  ->  $human_readable_dst"
    run rsync -aP "$src/" "$dst"

    verbose_msg "${indent}Remove src dir: $human_readable_src"
    run rm -rf "$src"

    verbose_msg "${indent}Move dir: $human_readable_dst  ->  $human_readable_src"
    run mv "$dst" "$src"
  fi

  verbose_msg "${indent}Symlink: $human_readable_src  ->  $human_readable_dst"
  run ln -snf "$src" "$dst"
}

symlink_each_child() {
  local src_dir="$repo_root/homedir/$1"
  local dst_dir="$HOME/$1"
  local glob="$2"
  local src dst

  # strip last slash if exists
  src_dir="${src_dir%/}"
  dst_dir="${dst_dir%/}"

  run mkdir -p "$dst_dir"

  find "$src_dir" -mindepth 1 -maxdepth 1 -name "$glob" -print0 | while read -rd $'\0' src; do
    # replace prefix of $src: $src_dir -> $dst_dir
    dst="$dst_dir${src#"${src_dir}"}"
    symlink "$src" "$dst"
  done
}

symlink_same_name() {
  local name="$1"
  symlink "$repo_root/homedir/$name" "$HOME/$name"
}

install() {
  assert_dir "$repo_root/homedir"

  symlink_each_child '' '.*' # only dot file
  symlink_each_child 'bin' '*'
  symlink_same_name 'Library/Application Support/AquaSKK'
}

setup_colors
parse_params "$@"
install
