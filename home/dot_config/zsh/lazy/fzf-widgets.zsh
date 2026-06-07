# fzf integration ZLE widgets.
# All widgets support multi-select (Tab) and insert shell-quoted paths.
#
#   Ctrl-X Ctrl-F   files under cwd          (fd, bat preview)
#   Ctrl-X Ctrl-D   directories under cwd    (fd, lsd tree preview)
#   Ctrl-X Ctrl-X   git-tracked + untracked (non-ignored) files in the whole
#                   repo, as cwd-relative paths
#                                            (git ls-files, bat preview)
#   Ctrl-R          history search           (fc, no preview, replaces buffer)

# Hard exclusions for fd-based widgets (regardless of .gitignore).
# Build/cache/generated dirs we never want in command-line completion.
# Deliberately *not* excluded: tmp/, tests/, fixtures/, .env*, Dockerfile,
# Makefile — those are things we typically want to find.
typeset -ga _FZF_FD_EXCLUDES=(
  # VCS / OS
  .git .DS_Store

  # JS/TS deps & build outputs & framework caches
  node_modules .turbo .tanstack .nitro .vite .pnpm-store
  'dist*'

  # Python venv / build / cache
  .venv venv __pycache__ .mypy_cache .ruff_cache .pytest_cache
  htmlcov '*.egg-info' wheels

  # AWS CDK
  .cdk.staging 'cdk.out*' 'cdk.*.out'

  # Tool caches / state
  .cache .history .serena .lsmcp .spec-workflow .task .coverage
)

function _fzf-insert-files() {
  emulate -L zsh
  (( $+commands[fd] && $+commands[fzf] )) || { zle -M 'fd or fzf not found'; return 1 }
  local selected
  selected="$(fd --type f --hidden --follow ${_FZF_FD_EXCLUDES[@]/#/--exclude=} \
    | fzf --multi --preview='bat --color=always --line-range :200 -- {} 2>/dev/null')"
  if [[ -n $selected ]]; then
    local items=("${(@f)selected}")
    LBUFFER+="${(j: :)${(@q-)items}} "
  fi
  zle reset-prompt
}
zle -N _fzf-insert-files
bindkey '^X^F' _fzf-insert-files

function _fzf-insert-dirs() {
  emulate -L zsh
  (( $+commands[fd] && $+commands[fzf] )) || { zle -M 'fd or fzf not found'; return 1 }
  local selected
  selected="$(fd --type d --hidden --follow ${_FZF_FD_EXCLUDES[@]/#/--exclude=} \
    | fzf --multi --preview='lsd -a --color=always --tree --depth 2 -- {} 2>/dev/null')"
  if [[ -n $selected ]]; then
    local items=("${(@f)selected}")
    LBUFFER+="${(j: :)${(@q-)items}} "
  fi
  zle reset-prompt
}
zle -N _fzf-insert-dirs
bindkey '^X^D' _fzf-insert-dirs

function _fzf-insert-git-files() {
  emulate -L zsh
  (( $+commands[git] && $+commands[fzf] )) || { zle -M 'git or fzf not found'; return 1 }
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    zle -M 'not in a git repository'
    return 1
  fi
  local selected
  # `:/` pathspec scopes to the whole repo; output paths are relative to cwd.
  # `--others --exclude-standard` adds untracked files while honoring .gitignore.
  selected="$(git ls-files --cached --others --exclude-standard :/ \
    | fzf --multi --preview='bat --color=always --line-range :200 -- {} 2>/dev/null')"
  if [[ -n $selected ]]; then
    local items=("${(@f)selected}")
    LBUFFER+="${(j: :)${(@q-)items}} "
  fi
  zle reset-prompt
}
zle -N _fzf-insert-git-files
bindkey '^X^X' _fzf-insert-git-files

function _fzf-history() {
  emulate -L zsh
  (( $+commands[fzf] )) || { zle -M 'fzf not found'; return 1 }
  local selected
  selected="$(fc -rln 1 | awk '!seen[$0]++' \
    | fzf --no-sort --tiebreak=index --query="$LBUFFER" +m)"
  if [[ -n $selected ]]; then
    BUFFER="$selected"
    CURSOR=${#BUFFER}
  fi
  zle reset-prompt
}
zle -N _fzf-history
bindkey '^R' _fzf-history
