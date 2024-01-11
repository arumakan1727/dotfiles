# See: `man zshoptions`

# A list of non-alphanumeric characters considered part of a word by the line editor.
WORDCHARS='~&;:!#$%'

# Remove write permission from `group` and `other`
umask 022

# Use emacs-like keybind
bindkey -e

# Shift-Tab to select prev entry
bindkey "^[[Z" reverse-menu-complete

## Change dir ##
setopt auto_cd
setopt auto_pushd
setopt chase_links
setopt pushd_ignore_dups
setopt pushd_silent

cdpath=(
  ..
  ~
  ~/.config
)

## Completion ##
setopt list_packed        # Try to make the completion list smaller

## Expansion and Globbing ##
setopt magic_equal_subst  # Allow file path completion after '=' (such as '--option=/path')
setopt mark_dirs          # Append a trailing `/' to all directory names resulting from globbing
setopt numeric_glob_sort
setopt warn_nested_var

## History ##
setopt extended_history   # Save each command's beginning timestamp and duration
setopt hist_fcntl_lock    # On writing history, lock using system's fcntl call (On recent OS this may provide better performance)
setopt hist_ignore_dups   # Don't save if the command lines are duplicates of prev entry
setopt hist_ignore_space  # Don't save if the first char of the command line is a space
setopt hist_reduce_blanks # Save with removing superfluous blanks
setopt hist_verify        # Whenever the user enters a line with history expansion, don't execute directly (instead, just expand)
setopt share_history      # See man page! (man zshoptions)
setopt no_hist_beep       # Don't beep when ZLE attempts to access a non-existent history entry

HISTFILE=~/.zsh_history
HISTSIZE=10000  # Number of histories in memory
SAVEHIST=100000 # Number of histories to be saved in HISTFILE
HISTORY_IGNORE='(ls|ll|la|lla|pwd|cd ..|cd|popd|ja *|en *|task *|jrnl *|git s|git sa|git ds|git aa|git au|git ap|git pull|git push)'

# Don't save failed command
# https://superuser.com/questions/902241/how-to-make-zsh-not-store-failed-command
function zshaddhistory() {
  # skip variable assignments
  local args=(${(z)1})
  local j=1

  while [[ ${args[$j]} == *=* ]]; do
    ((j++))
  done

  # NOTE: last element of args is ';'
  # So, if a command line is `echo "a b"`, the args=('echo' '"a b"' ';')
  if [[ $j -lt ${#args} ]] && ! whence ${args[$j]} >| /dev/null; then
    return 1
  fi

  # https://qiita.com/sho-t/items/d44bfbc783db7ca278c0
  emulate -L zsh
  [[ ${1%%$'\n'} != ${~HISTORY_IGNORE} ]]
}

## Input/Output ##
setopt no_flow_control      # Disable start/stop control characters (usually assigned to Ctrl+s, Ctrl+q)
setopt ignore_eof           # Don't exit on end-of-file (Ctrl+d)
setopt interactive_comments # Allow comments even in interactive shells
setopt path_dirs            # Search path even if command contains slashes
setopt short_loops          # Allow the short forms of for, repeat, select, if, and function constructs

## Job Control ##
setopt check_jobs     # Report the status of background and suspended jobs before exiting a shell with job control
setopt long_list_jobs # Print job notifications in the long format by default
setopt notify         # Report the status of bg jobs immediately, rather than waiting until just before printing a prompt.

## Zle ##
setopt no_beep
