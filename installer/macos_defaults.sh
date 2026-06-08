#!/bin/bash
set -Eeuo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
  echo "Not on macOS! Skip configration."
  exit
fi

# Dock
defaults write com.apple.dock orientation left # Show dock on left side
defaults write com.apple.dock autohide -bool true # Autohide the dock
defaults write com.apple.dock autohide-delay -float 0 # No delay before showing
defaults delete com.apple.dock autohide-time-modifier 2>/dev/null || true # Reset show/hide animation to default (undo a previously-written value)
defaults write com.apple.dock show-recents -bool false # Don't show recently used aps
defaults write com.apple.dock mru-spaces -bool false # Don't rearrange space order
defaults write com.apple.dock magnification -bool true # Zoom up on cursor hover
defaults write com.apple.dock largesize -int 45 # # Icon size when enlarged

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true # Show hidden files by default
defaults write NSGlobalDomain AppleShowAllExtensions -bool true # Show files with all extensions
defaults write com.apple.finder ShowStatusBar -bool true # Display the status bar
defaults write com.apple.finder ShowPathbar -bool true # Display the path bar

set +e
killall Dock
killall Finder
killall SystemUIServer
