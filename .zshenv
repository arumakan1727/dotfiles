# zmodload zsh/zprof && zprof
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

typeset -U path PATH manpath sudo_path
typeset -xT SUDO_PATH sudo_path

path=(
  $HOME/.bin(N-/)
  $HOME/bin(N-/)
  $HOME/.local/bin(N-/)
  $HOME/.pyenv/bin(N-/)
  $HOME/.poetry/bin(N-/)
  $HOME/.rbenv/shims(N-/)
  $HOME/go/bin(N-/)
  $HOME/.go/bin(N-/)
  $HOME/.nimble/bin(N-/)
  $HOME/.yarn/bin(N-/)
  $HOME/.config/yarn/global/node_modules/.bin(N-/)
  $HOME/.deno/bin(N-/)
  $HOME/.fnm(N-/)
  $HOME/.cargo/bin(N-/)
  /usr/local/go/bin(N-/)
  $path
)

# zsh関数のサーチパス
fpath=(
  $HOME/.zfunc(N-/)
  $HOME/.config/zsh/zfunc(N-/)
  $HOME/.config/zsh/completion.local(N-/)
  $HOME/.config/zsh/completion(N-/)
  /usr/local/share/zsh/site-functions
  /usr/share/zsh/site-functions
  $fpath
)

## SHELL
if SHELL=$(builtin command -v zsh); then
  export SHELL
else
  unset SHELL
fi

## EDITOR
if builtin command -v nvim > /dev/null 2>&1; then
  export EDITOR=nvim
else
  export EDITOR=vim
fi

## LESS
export PAGER=less
export LESS='--no-init --quit-if-one-screen -R --LONG-PROMPT -i --shift 4 --jump-target=3'

export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline
export GROFF_NO_SGR=1                  # for konsole and gnome-terminal

# LS_COLORS
if builtin command -v dircolors > /dev/null 2>&1 && [ -f "$HOME/.config/dircolors" ]; then
  eval "$(dircolors "$HOME/.config/dircolors")"
else
  eval "$(dircolors -b)"
fi

if [ -z "$LS_COLORS" ]; then
  export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
fi

## Language tools
export GOPATH="$HOME/.go"
export PYENV_ROOT="$HOME/.pyenv"
export SDKMAN_DIR="$HOME/.sdkman"
export PIPENV_VENV_IN_PROJECT=true

[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && \
  source "$HOME/.sdkman/bin/sdkman-init.sh"

[[ -s "$HOME/.cargo/env" ]] && \
  source "$HOME/.cargo/env"

builtin command -v fnm > /dev/null 2>&1 && \
  eval "$(fnm env)"

builtin command -v opam > /dev/null 2>&1 && \
  eval "$(opam env)"
