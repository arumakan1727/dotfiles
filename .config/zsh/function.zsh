#======================================================================================
# Functions
# 参考: https://github.com/yutkat/dotfiles/blob/master/.config/zsh/rc/function.zsh
#======================================================================================

function 256color() {
  for code in {000..255}; do
    print -nP -- "%F{$code}$code %f";
    if [ $((${code} % 16)) -eq 15 ]; then
      echo ""
    fi
  done
}

function ascii_color_code() {
  seq 30 47 | xargs -n 1 -i{} printf "\x1b[%dm#\x1b[0m %d\n" {} {}
}

function truecolor_test() {
  awk 'BEGIN{
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum = 0; colnum<77; colnum++) {
        r = 255-(colnum*255/76);
        g = (colnum*510/76);
        b = (colnum*255/76);
        if (g>255) g = 510-g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n";
  }'
}

function tmux_colors() {
  for i in {0..255}; do
    printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
  done | column -x
}

function find_no_new_line_at_end_of_file() {
  find * -type f -print0 | xargs -0 -L1 bash -c 'test "$(tail -c 1 "$0")" && echo "No new line at end of $0"'
}

function xkb_reload_my_settings() {
  xkbcomp -I${HOME}/.xkb ~/.xkb/keymap/mykbd $DISPLAY 2> /dev/null
}

function rm-trash() {
  readonly local trashRootDir="$HOME/.trash"
  readonly local date=$(date "+%Y/%m/%d")
  readonly local time=$(date "+%H:%M:%S")
  readonly local destDir="$trashRootDir/$date/$time"

  command mkdir -p "$destDir"

  for arg in $@; do
    # '-'(ハイフン) で始まる引数は無視
    if [ "$arg" =~ '^-' ]; then
      echo "Info: ignore option '$arg'" 1>&2
      continue
    fi

    if [ ! -e "$arg" ]; then
      echo "Error: '$arg': not found" 1>&2
      continue
    fi

    # .trash/ 内のファイルは .trash/ に退避せず削除
    if [ "$(realpath "$arg")" =~ "^${trashRootDir}" ]; then
      command rm --verbose -rf "$arg"
      continue
    fi

    # .trash/ に退避
    command mv --verbose "$arg" "$destDir"
  done
}

# Blank lines of half the height of the terminal
function blank-half() {
  local count=10
  if [[ $@ -eq 0 ]]; then
    count=$(($(stty size| cut -d' ' -f1)/2))
  else
    count=$1
  fi
  for i in $(seq $count); do
    echo
  done
}

# Remove executable ELF binary in specified directory. It does not searches recursively (maxdepth=1).
function rm-exebin() {
  if [[ $# -ne 1 ]]; then
    echo 'Please specify target directory.' >&2
    return 1
  fi

  for binary in $(find "$1" -maxdepth 1 -type f -exec sh -c "file {} | grep -Pi ': elf (32|64)-bit' > /dev/null" \; -print); do
    command rm -v "$binary"
  done
}

# random string (default length: 6)
function randstr() {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c ${1:-6}
  echo
  return 0
}

# random bytes (default bytes: 32B)
function randbytes() {
  cat /dev/urandom | head -c ${1:-32}
  return 0
}

function dl() {
  rm -rf test
  oj dl $1
}
