#!/bin/bash
# pnpm installation - independent of other tools
set -e

export PNPM_HOME="$HOME/.local/share/pnpm"

# Check if pnpm is already installed
if [ -f "$PNPM_HOME/pnpm" ]; then
  echo "pnpm already installed at $PNPM_HOME"
  echo "Current version: $("$PNPM_HOME/pnpm" --version)"
  exit 0
fi

echo "Installing pnpm..."
echo "PNPM_HOME: $PNPM_HOME"

# Create directory
mkdir -p "$PNPM_HOME"

# Download and install pnpm using the official installer
if ! curl -fsSL https://get.pnpm.io/install.sh | env PNPM_HOME="$PNPM_HOME" sh -; then
  echo "Error: pnpm installation failed"
  exit 1
fi

# Verify installation
if [ -f "$PNPM_HOME/pnpm" ]; then
  echo "pnpm installed successfully!"
  echo "pnpm version: $("$PNPM_HOME/pnpm" --version)"
  echo ""
  echo "Your .bash_profile should already have the correct PATH configuration:"
  echo '  export PNPM_HOME="$HOME/.local/share/pnpm"'
  echo '  export PATH="$PNPM_HOME:$PATH"'
else
  echo "Error: pnpm installation completed but binary not found"
  exit 1
fi
