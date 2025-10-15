#!/bin/bash
# Save this as: .chezmoiscripts/run_once_after_configure-starship.sh

set -e

BASHRC="$HOME/.bashrc"
STARSHIP_INIT='eval "$(starship init bash)"'
STARSHIP_CONFIG="$HOME/.config/starship.toml"
MINICONDA_DIR="$HOME/.local/share/miniconda"

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Configure starship with catppuccin-powerline preset
echo "Configuring starship with catppuccin-powerline preset..."
"$MINICONDA_DIR/bin/starship" preset catppuccin-powerline -o "$STARSHIP_CONFIG"

# Check if starship init is already in .bashrc
if grep -qF "$STARSHIP_INIT" "$BASHRC"; then
  echo "Starship already configured in .bashrc"
  exit 0
fi

echo "Adding starship initialization to .bashrc..."

# Add starship init to .bashrc
echo "" >>"$BASHRC"
echo "# Initialize starship prompt" >>"$BASHRC"
echo "$STARSHIP_INIT" >>"$BASHRC"

echo "Starship configured successfully"
echo "Run 'source ~/.bashrc' or restart your shell to see changes"
