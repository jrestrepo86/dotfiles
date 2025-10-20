#!/bin/bash
# Save this as: .chezmoiscripts/run_once_install-lsd-bat.sh

set -e

BIN_DIR="$HOME/.local/bin"
TMP_DIR="/tmp/lsd-bat-install"

# Create directories
mkdir -p "$BIN_DIR"
mkdir -p "$TMP_DIR"

echo "Installing lsd and bat to $BIN_DIR..."

# Install lsd
if [ ! -f "$BIN_DIR/lsd" ]; then
  echo "Installing lsd..."
  cd "$TMP_DIR"

  # Get latest lsd release for Linux x86_64
  LSD_VERSION=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
  LSD_URL="https://github.com/lsd-rs/lsd/releases/download/${LSD_VERSION}/lsd-${LSD_VERSION}-x86_64-unknown-linux-gnu.tar.gz"

  wget "$LSD_URL" -O lsd.tar.gz
  tar -xzf lsd.tar.gz
  mv lsd-${LSD_VERSION}-x86_64-unknown-linux-gnu/lsd "$BIN_DIR/"

  echo "lsd installed successfully"
else
  echo "lsd already installed"
fi

# Install bat
if [ ! -f "$BIN_DIR/bat" ]; then
  echo "Installing bat..."
  cd "$TMP_DIR"

  # Get latest bat release for Linux x86_64
  BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
  BAT_URL="https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat-${BAT_VERSION}-x86_64-unknown-linux-gnu.tar.gz"

  wget "$BAT_URL" -O bat.tar.gz
  tar -xzf bat.tar.gz
  mv bat-${BAT_VERSION}-x86_64-unknown-linux-gnu/bat "$BIN_DIR/"

  echo "bat installed successfully"
else
  echo "bat already installed"
fi

# Clean up
rm -rf "$TMP_DIR"

echo "Installation complete!"
echo "Make sure $BIN_DIR is in your PATH"
echo "Add this to your .bashrc if not already present:"
echo '  export PATH="$HOME/.local/bin:$PATH"'
