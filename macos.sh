#!/usr/bin/env bash
set -euo pipefail
 
# --------------
# Dock settings
# --------------

# Enable auto-hide
defaults write com.apple.dock autohide -bool true 
 
# Delay before the Dock shows when you hover the edge (seconds).
# Default: 0.5 — set to 0 for no delay.
defaults write com.apple.dock autohide-delay -float 0
 
# Animation duration for the Dock sliding in/out (seconds).
# Default: ~0.5 — set to 0.15 for snappy, 0 for instant.
defaults write com.apple.dock autohide-time-modifier -float 0.15
 
# Apply changes
killall Dock
 
echo "✓ Dock configured: autohide on, delay=0s, animation=0.15s"


# VS Code
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

