(command -v pyenv > /dev/null 2>&1) && eval "$(pyenv init --path)"
(command -v direnv > /dev/null 2>&1) && eval "$(direnv hook zsh)"
(command -v starship > /dev/null 2>&1) && eval "$(starship init zsh)"
(command -v rebenv > /dev/null 2>&1) && eval "$(rbenv init -)"
(command -v phpenv > /dev/null 2>&1) && eval "$(phpenv init -)"

[ -r ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow'
export FZF_DEFAULT_OPTS='--height 60% --reverse --border'
export FZF_ALT_C_COMMAND='fd --type=d --follow --hidden --follow --exclude=.git'
