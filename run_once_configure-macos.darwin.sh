#!/usr/bin/env bash
set -euo pipefail

# Dock settings
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
killall Dock || true
echo "✓ Dock configured: autohide on, delay=0s, animation=0.15s"

# VS Code
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
