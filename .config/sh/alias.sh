# shellcheck shell=sh
alias quit='exit'
alias rezsh='exec zsh'

alias rm='rm -iv'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -v'

# ls
if command -v lsd 2>/dev/null 1>&2 ; then
  alias ls='lsd'
else
  alias ls='ls --color=auto'
fi
alias l='ls -1'
alias ll='ls -l'
alias la='ls -a'
alias lla='ll -a'
alias ltr='ll -tr'

# human readable
alias df='df -h'
alias free='free -h'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

# Translate-shell
alias ja='trans :ja'
alias en='trans :en'

# Change directory to Parent Dir
alias ..='cd ..'
alias ...='cd ../..'

# Imitate macOS
if [ "$(uname -s)" = Linux ]; then
  alias pbcopy='xsel --input --clipboard'
  alias pbpaste='xsel --output --clipboard'
  alias open='xdg-open'
fi

# g++
alias g+='g++ -std=c++17 -g -DLOCAL_DEBUG -Wall -Wextra -Wshadow -Wconversion -fsanitize=address,undefined -fno-omit-frame-pointer'
