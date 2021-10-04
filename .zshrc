source $HOME/.config/zsh/base.zsh
source $HOME/.config/zsh/completion.zsh
source $HOME/.config/zsh/function.zsh
source $HOME/.config/zsh/alias.zsh
source $HOME/.config/zsh/bindkey.zsh
source $HOME/.config/zsh/plugins.zsh
source $HOME/.config/zsh/external_tool_init.zsh

[[ -r $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

if command -v zprof > /dev/null 2>&1 ; then
  zprof
fi
