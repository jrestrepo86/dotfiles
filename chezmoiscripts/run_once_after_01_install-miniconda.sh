#!/bin/bash
# Save this as: .chezmoiscripts/run_once_install-miniconda.sh

set -e

MINICONDA_DIR="$HOME/.local/share/miniconda"
INSTALLER="Miniconda3-latest-Linux-x86_64.sh"

# Check if Miniconda is already installed
if [ -d "$MINICONDA_DIR" ]; then
  echo "Miniconda already installed at $MINICONDA_DIR"
  exit 0
fi

echo "Installing Miniconda..."

# Download installer
wget https://repo.anaconda.com/miniconda/$INSTALLER

# Make executable
chmod +x $INSTALLER

# Run installer in batch mode
./$INSTALLER -b -p "$MINICONDA_DIR"

# Clean up installer
rm $INSTALLER

# Initialize conda for bash (optional - uncomment if desired)
# "$MINICONDA_DIR/bin/conda" init bash

echo "Miniconda installed successfully at $MINICONDA_DIR"
echo "To use conda, either:"
echo "  1. Restart your shell, or"
echo "  2. Run: source $MINICONDA_DIR/bin/activate"
