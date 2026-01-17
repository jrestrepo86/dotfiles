#!/bin/bash
# Miniconda installation - runs first in the after sequence
set -e

MINICONDA_DIR="$HOME/.local/share/miniconda"
ARCH=$(uname -m)

# Check if Miniconda is already installed
if [ -d "$MINICONDA_DIR" ] && [ -f "$MINICONDA_DIR/bin/conda" ]; then
  echo "Miniconda already installed at $MINICONDA_DIR"
  exit 0
fi

echo "Installing Miniconda for architecture: $ARCH"

# Determine the correct installer based on architecture
case $ARCH in
x86_64)
  INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
  ;;
aarch64 | arm64)
  INSTALLER="Miniconda3-latest-Linux-aarch64.sh"
  ;;
*)
  echo "Error: Unsupported architecture: $ARCH"
  echo "Miniconda supports: x86_64, aarch64"
  exit 1
  ;;
esac

# Download installer
echo "Downloading $INSTALLER..."
if ! wget -4 "https://repo.anaconda.com/miniconda/$INSTALLER"; then
  echo "Error: Failed to download Miniconda installer"
  exit 1
fi

# Make executable
chmod +x "$INSTALLER"

# Run installer in batch mode
echo "Installing to $MINICONDA_DIR..."
if ! ./"$INSTALLER" -b -p "$MINICONDA_DIR"; then
  echo "Error: Miniconda installation failed"
  rm -f "$INSTALLER"
  exit 1
fi

# Clean up installer
rm "$INSTALLER"

# Verify installation
if [ -f "$MINICONDA_DIR/bin/conda" ]; then
  echo "Miniconda installed successfully at $MINICONDA_DIR"
  echo "Conda version: $("$MINICONDA_DIR/bin/conda" --version)"
else
  echo "Error: Miniconda installation completed but conda binary not found"
  exit 1
fi

echo ""
echo "Note: Conda is available at $MINICONDA_DIR/bin/conda"
echo "Your .bash_profile should already have the correct PATH configuration"
