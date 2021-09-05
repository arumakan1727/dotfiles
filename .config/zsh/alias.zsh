alias mkdir="mkdir -p"
alias quit='exit'
alias rezsh='exec zsh'

if builtin command -v exa > /dev/null 2>&1; then
  alias e='exa --icons'
  alias ea='exa -a --icons'
  alias el='exa -l --icons'
  alias ela='exa -aal --icons'
  alias et='exa -T -L 3 --icons -I "node_modules|.git|.cache|.venv"'
  alias eta='exa -a -T -L 3 --icons -I "node_modules|.git|.cache|.venv"'
fi

alias rm='rm -iv'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -v'

# ls
alias ls='ls -F --color=auto'
alias ll='ls -lh'
alias la='ls -a'
alias lla='ll -a'
alias ltr='ll -tr'
alias l.='ls -d .[a-zA-Z]*'

# colorize
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'


# chmod
alias 644='chmod 644'
alias 755='chmod 755'
alias 777='chmod 777'

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

# Translate-shell
alias ja='trans :ja'
alias en='trans :en'

# Change directory to Parent Dir
alias ..='cd ..'
alias ...='cd ../..'

# Clipboard
alias pbcopy='xsel --input --clipboard'
alias pbpaste='xsel --output'

# move prompt to bottom of terminal
alias move-buttom='tput cup $(($(stty size|cut -d " " -f 1))) 0 && tput ed'

(command -v batcat > /dev/null 2>&1) && alias bat='batcat'

alias open='xdg-open'

# nim
alias nimr='nim cpp --hints:off --run'
alias nimfr='nim cpp -d:release --opt:speed --multimethods:on --warning[SmallLshouldNotBeUsed]:off --hints:off --run'
