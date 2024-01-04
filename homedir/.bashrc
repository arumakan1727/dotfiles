# shellcheck shell=bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [[ -z "${debian_chroot:-}" ]] && [[ -r /etc/debian_chroot ]]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [[ -n "$force_color_prompt" ]]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [[ "$color_prompt" = yes ]]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n \$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\n \$ '
fi
unset color_prompt force_color_prompt

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -r /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi

if command -v nvim &> /dev/null; then
  export EDITOR=nvim
  export MANPAGER='nvim +Man!'
else
  export EDITOR=vim
fi

export PAGER=less
export LESS='--no-init --quit-if-one-screen -R --LONG-PROMPT -i --shift 4 --jump-target=3'

export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline

alias rm='rm -iv'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -v'

# ls
if command -v lsd &> /dev/null; then
  alias ls='lsd'
  alias lt='lsd -a --tree --depth 3 -I .git -I node_modules -I .venv -I __pycache__'
else
  alias ls='ls --color=auto'
fi

alias l='ls -1'
alias ll='ls -l'
alias la='ls -a'
alias lla='ll -a'
alias ltr='ll -tr'

alias df='df -h'
alias free='free -h'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

alias path='echo $PATH | tr -s ":" "\n"'

# Translate-shell
alias ja='trans :ja'
alias en='trans :en'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias cdgitroot='cd "$(git rev-parse --show-toplevel)"'

# Imitate macOS
if [[ "$(uname -s)" = Linux ]]; then
  alias pbcopy='xsel --input --clipboard'
  alias pbpaste='xsel --output --clipboard'
  alias open='xdg-open'
fi
