### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk


# コマンドラインの色付け
zinit light zdharma/fast-syntax-highlighting

# コマンドラインに入力されている文字列をもとに薄い色でコマンドを提案
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
zinit light zsh-users/zsh-autosuggestions

# Ctrl+x -> Ctrl+b で Git ブランチを表示してインタラクティブに絞り込みして切り替え
# zinit ice wait'!3' lucid atload"bindkey '^x^b' anyframe-widget-checkout-git-branch"

zinit wait'!1' atinit'zpcompinit' lucid light-mode for \
  zsh-users/zsh-completions \
  agkozak/zsh-z \
  zsh-users/zsh-history-substring-search

zinit wait'!3' lucid light-mode for \
  mollifier/cd-gitroot \
  paulirish/git-open \
  Tarrasch/zsh-bd
