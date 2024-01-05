alias quit='exit'
alias rezsh='exec zsh'

alias rm='rm -iv'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -v'

if (( $+commands[lsd] )); then
  alias ls='lsd'
  alias lt='lsd -a --tree --depth 3 -I .git -I node_modules -I .venv'
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
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'


alias history-import='fc -RI'

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

# Translate-shell
alias ja='trans :ja'
alias en='trans :en'

# Change directory to Parent Dir
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias cdgitroot='cd "$(git rev-parse --show-toplevel)"'

# Imitate macOS
if [[ $OSTYPE = linux* ]]; then
  alias pbcopy='xsel --input --clipboard'
  alias pbpaste='xsel --output --clipboard'
  alias open='xdg-open'
fi

alias g+='g++ -std=c++20 -g -DLOCAL_DEBUG -Wall -Wextra -Wshadow -Wconversion -fsanitize=address,undefined -fno-omit-frame-pointer'
