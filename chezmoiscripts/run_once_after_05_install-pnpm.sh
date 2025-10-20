#!/bin/bash
# Save this as: .chezmoiscripts/run_once_install-pnpm.sh

set -e

export PNPM_HOME="$HOME/.local/share/pnpm"

# Check if pnpm is already installed
if [ -f "$PNPM_HOME/pnpm" ]; then
  echo "pnpm already installed at $PNPM_HOME"
  exit 0
fi

echo "Installing pnpm..."
echo "PNPM_HOME: $PNPM_HOME"

# Create directory
mkdir -p "$PNPM_HOME"

# Download and install pnpm using the official installer
curl -fsSL https://get.pnpm.io/install.sh | env PNPM_HOME="$PNPM_HOME" sh -

echo "pnpm installed successfully!"
echo ""
echo "Add these lines to your .bashrc:"
echo '  export PNPM_HOME="$HOME/.local/share/pnpm"'
echo '  export PATH="$PNPM_HOME:$PATH"'
