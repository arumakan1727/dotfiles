# Self-hosted snippet expansion (replacement for zeno auto-snippet).
# Trigger: <Space>. Expands the word right before the cursor when it matches a
# registered keyword. Use {{cursor}} in expansions to position the cursor.

typeset -gA _SNIP
typeset -ga _SNIP_CTX_RE _SNIP_CTX_KEY _SNIP_CTX_VAL

# DSL:
#   snip <keyword> <expansion>             -- global
#   snip -c <regex> <keyword> <expansion>  -- only when LBUFFER (left of keyword) matches <regex>
function snip() {
  emulate -L zsh
  if [[ $1 == -c ]]; then
    _SNIP_CTX_RE+=("$2")
    _SNIP_CTX_KEY+=("$3")
    _SNIP_CTX_VAL+=("$4")
  else
    _SNIP[$1]="$2"
  fi
}

##### git #####
snip gs   'git status --short --branch'
snip gsu  'git status --short --branch -u'
snip gbm  'git branch -m'
snip ga   'git add'
snip gau  'git add -u'
snip gaa  'git add --all'
snip gap  'git add -p'
snip gc   'git commit'
snip gcm  $'git commit -m $\'{{cursor}}\''
snip gsw  'git switch'
snip gswc 'git switch -c'
snip gd   'git diff {{cursor}}'
snip gds  'git diff --staged'
snip gck  'git checkout'
snip grs  'git restore --staged'
snip gsh  'git stash --include-untracked'
snip gl   'git log --oneline -20'
snip gpl  'git pull'
snip gpu  'git push'
snip gw   'git worktree'
snip gwa  'git worktree add'

# git commit context
snip -c 'git commit[[:space:]]+' ';a'  '--amend'
snip -c 'git commit[[:space:]]+' ';an' '--amend --no-edit'
snip -c 'git commit[[:space:]]+' ';f'  '--fixup'

# git push context
snip -c 'git push[[:space:]]+' ';u' '--set-upstream origin HEAD'
snip -c 'git push[[:space:]]+' ';f' '-f --force-with-lease --force-if-includes'

# (npm|pnpm|yarn) run context
snip -c '(npm|pnpm|yarn) run[[:space:]]+' ';t' 'typecheck'
snip -c 'turbo [[:space:]]+' ';t' 'typecheck'

##### misc #####
snip t  'task'
snip b  'turbo'
snip tm 'tmux'
snip lg 'lazygit'
snip dc 'docker compose'
snip nr 'npm run'
snip pr 'pnpm run'
snip mr 'mise run'
snip ,i '| pbcopy'
snip ,o 'pbpaste'

unfunction snip

function _snip-expand-or-space() {
  emulate -L zsh
  local word="${LBUFFER##*[[:space:]]}"
  if [[ -z $word ]]; then
    zle self-insert
    return
  fi
  local before="${LBUFFER%$word}"

  local snippet=""
  local i
  for (( i = 1; i <= ${#_SNIP_CTX_KEY}; i++ )); do
    if [[ $word == ${_SNIP_CTX_KEY[i]} && $before =~ ${_SNIP_CTX_RE[i]} ]]; then
      snippet="${_SNIP_CTX_VAL[i]}"
      break
    fi
  done
  if [[ -z $snippet && -n ${_SNIP[$word]+x} ]]; then
    snippet="${_SNIP[$word]}"
  fi

  if [[ -z $snippet ]]; then
    zle self-insert
    return
  fi

  local marker='{{cursor}}'
  if [[ $snippet == *${marker}* ]]; then
    local left="${snippet%%${marker}*}"
    local right="${snippet#*${marker}}"
    LBUFFER="${before}${left}"
    RBUFFER="${right}${RBUFFER}"
  else
    LBUFFER="${before}${snippet} "
  fi

  # fast-syntax-highlighting incrementally diffs against the prior buffer; a
  # large LBUFFER mutation can leave stale highlights for the original prefix.
  # Force a full re-highlight when FSH is loaded.
  (( $+functions[_zsh_highlight] )) && _zsh_highlight
}
zle -N _snip-expand-or-space
bindkey ' ' _snip-expand-or-space
