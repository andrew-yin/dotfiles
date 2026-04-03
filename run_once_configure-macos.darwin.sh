#!/usr/bin/env bash
set -euo pipefail

# Dock settings
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
killall Dock || true
echo "✓ Dock configured: autohide on, delay=0s, animation=0.15s"

# Trackpad: enable three-finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool false
echo "✓ Three-finger drag enabled"

# VS Code
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
