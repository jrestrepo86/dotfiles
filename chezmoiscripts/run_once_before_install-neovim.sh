#!/bin/bash
# Save this as: .chezmoiscripts/run_once_before_install-neovim.sh

set -e

NVIM_DIR="$HOME/.local/share/nvim"
NVIM_BIN_DIR="$HOME/.local/bin"
ARCH=$(uname -m)

# Check if Neovim is already installed
if [ -d "$NVIM_DIR" ]; then
  echo "Neovim already installed at $NVIM_DIR"
  exit 0
fi

echo "Fetching latest Neovim stable version..."
# Get the latest stable release tag
NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$NVIM_VERSION" ]; then
  echo "Failed to fetch latest version, using fallback v0.10.2"
  NVIM_VERSION="v0.10.2"
fi

# Map architecture names
case $ARCH in
x86_64)
  NVIM_ARCHIVE="nvim-linux-x86_64.tar.gz"
  NVIM_EXTRACT_DIR="nvim-linux-x86_64"
  ;;
aarch64 | arm64)
  echo "For ARM64, using appimage..."
  NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage"
  ;;
*)
  echo "Unsupported architecture: $ARCH"
  exit 1
  ;;
esac

echo "Installing Neovim ${NVIM_VERSION}..."

# Create directories
mkdir -p "$NVIM_DIR"
mkdir -p "$NVIM_BIN_DIR"

if [ "$ARCH" = "x86_64" ]; then
  # Download and install tarball for x86_64
  NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_ARCHIVE}"

  echo "Downloading Neovim from ${NVIM_URL}..."
  wget "$NVIM_URL"

  echo "Extracting Neovim..."
  tar -xzf "$NVIM_ARCHIVE"

  # Move contents to install directory
  mv "$NVIM_EXTRACT_DIR"/* "$NVIM_DIR/"

  # Clean up
  rm -rf "$NVIM_ARCHIVE" "$NVIM_EXTRACT_DIR"

  # Create symlink in .local/bin
  ln -sf "$NVIM_DIR/bin/nvim" "$NVIM_BIN_DIR/nvim"
else
  # Download appimage for ARM
  echo "Downloading Neovim appimage..."
  wget "$NVIM_URL" -O "$NVIM_BIN_DIR/nvim"
  chmod +x "$NVIM_BIN_DIR/nvim"
fi

echo "Neovim installed successfully!"
echo ""
echo "Neovim is available at: $NVIM_BIN_DIR/nvim"
echo "Make sure $NVIM_BIN_DIR is in your PATH"
echo ""
echo "Add to your shell config (~/.bashrc, ~/.zshrc, etc.):"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "Verify installation with: nvim --version"
