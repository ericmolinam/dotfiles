#!/usr/bin/env bash
set -euo pipefail

echo "Setting macOS defaults..."

# Close any open System Preferences panes to prevent overrides
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# Finder: show hidden files, all filename extensions
defaults write com.apple.finder AppleShowAllFiles -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Dock: automatically hide and show the Dock, adjust speed
defaults write com.apple.dock autohide -bool false

# Restart affected applications
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo "macOS defaults configured."
