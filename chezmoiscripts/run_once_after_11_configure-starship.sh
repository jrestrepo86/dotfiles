#!/bin/bash
# Starship configuration - depends on starship (10)
set -e

BASHRC="$HOME/.bashrc"
STARSHIP_CONFIG="$HOME/.config/starship.toml"
CARGO_HOME="$HOME/.local/share/cargo"
STARSHIP_BIN="$CARGO_HOME/bin/starship"

# Check if starship is installed
if [ ! -f "$STARSHIP_BIN" ]; then
  echo "Error: starship not found at $STARSHIP_BIN"
  echo "Make sure the starship installation script ran successfully"
  exit 1
fi

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Check if starship config already exists
if [ -f "$STARSHIP_CONFIG" ]; then
  echo "Starship config already exists at $STARSHIP_CONFIG"
  echo "Skipping preset configuration"
else
  # Configure starship with catppuccin-powerline preset
  echo "Configuring starship with catppuccin-powerline preset..."
  if "$STARSHIP_BIN" preset catppuccin-powerline -o "$STARSHIP_CONFIG"; then
    echo "✓ Starship config created at $STARSHIP_CONFIG"
  else
    echo "Warning: Failed to create starship preset"
    echo "You can manually configure it later with: starship preset catppuccin-powerline"
  fi
fi

echo ""
echo "Starship configured successfully"
echo "Starship version: $("$STARSHIP_BIN" --version)"
echo ""
echo "Starship init is already in .bashrc"
