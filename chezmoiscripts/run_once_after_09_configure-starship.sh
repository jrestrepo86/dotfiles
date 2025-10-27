#!/bin/bash
# Starship configuration - depends on miniconda (01) and conda packages (02)
set -e

BASHRC="$HOME/.bashrc"
STARSHIP_INIT='eval "$(starship init bash)"'
STARSHIP_CONFIG="$HOME/.config/starship.toml"
CARGO_HOME="$HOME/.local/share/cargo"
STARSHIP_BIN="$CARGO_HOME/bin/starship"

# Check if starship is installed via conda
if [ ! -f "$STARSHIP_BIN" ]; then
  echo "Error: starship not found at $STARSHIP_BIN"
  echo "Make sure the conda packages installation script ran successfully"
  echo "You can manually install it with: conda install -c conda-forge starship"
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

# Check if starship init is already in .bashrc
if [ -f "$BASHRC" ] && grep -qF "$STARSHIP_INIT" "$BASHRC"; then
  echo "Starship already configured in .bashrc"
  exit 0
fi

echo "Adding starship initialization to .bashrc..."

# Add starship init to .bashrc
if [ -f "$BASHRC" ]; then
  echo "" >> "$BASHRC"
  echo "# Initialize starship prompt" >> "$BASHRC"
  echo "$STARSHIP_INIT" >> "$BASHRC"
  echo "✓ Starship initialization added to .bashrc"
else
  echo "Warning: .bashrc not found, creating it"
  echo "# Initialize starship prompt" > "$BASHRC"
  echo "$STARSHIP_INIT" >> "$BASHRC"
fi

echo ""
echo "Starship configured successfully"
echo "Starship version: $("$STARSHIP_BIN" --version)"
echo ""
echo "To see changes, run: source ~/.bashrc"
echo "Or restart your shell"
