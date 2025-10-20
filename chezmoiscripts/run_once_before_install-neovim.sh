#!/bin/bash
# Neovim installation - runs before files are applied
set -e

NVIM_DIR="$HOME/.local/share/nvim"
NVIM_BIN_DIR="$HOME/.local/bin"
ARCH=$(uname -m)

# Check if Neovim is already installed
if [ -f "$NVIM_BIN_DIR/nvim" ]; then
  echo "Neovim already installed at $NVIM_BIN_DIR"
  echo "Current version: $("$NVIM_BIN_DIR/nvim" --version | head -n1)"
  exit 0
fi

echo "Fetching latest Neovim stable version..."
# Get the latest stable release tag
NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$NVIM_VERSION" ]; then
  echo "Failed to fetch latest version, using fallback v0.10.2"
  NVIM_VERSION="v0.10.2"
fi

# Create directories
mkdir -p "$NVIM_DIR"
mkdir -p "$NVIM_BIN_DIR"

echo "Installing Neovim ${NVIM_VERSION} for architecture: ${ARCH}..."

# Map architecture names and determine installation method
case $ARCH in
x86_64)
  NVIM_ARCHIVE="nvim-linux-x86_64.tar.gz"
  NVIM_EXTRACT_DIR="nvim-linux-x86_64"
  NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_ARCHIVE}"

  echo "Downloading Neovim tarball from ${NVIM_URL}..."
  if ! wget "$NVIM_URL"; then
    echo "Error: Failed to download Neovim"
    exit 1
  fi

  echo "Extracting Neovim..."
  if ! tar -xzf "$NVIM_ARCHIVE"; then
    echo "Error: Failed to extract Neovim archive"
    rm -f "$NVIM_ARCHIVE"
    exit 1
  fi

  # Move contents to install directory
  mv "$NVIM_EXTRACT_DIR"/* "$NVIM_DIR/"

  # Clean up
  rm -rf "$NVIM_ARCHIVE" "$NVIM_EXTRACT_DIR"

  # Create symlink in .local/bin
  ln -sf "$NVIM_DIR/bin/nvim" "$NVIM_BIN_DIR/nvim"
  ;;

aarch64 | arm64)
  echo "Installing Neovim appimage for ARM64..."
  NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage"

  if ! wget "$NVIM_URL" -O "$NVIM_BIN_DIR/nvim"; then
    echo "Error: Failed to download Neovim appimage"
    exit 1
  fi

  chmod +x "$NVIM_BIN_DIR/nvim"

  # Test if appimage works
  if ! "$NVIM_BIN_DIR/nvim" --version &>/dev/null; then
    echo ""
    echo "Warning: AppImage may not work on this system."
    echo "This usually means libfuse2 is missing."
    echo ""
    echo "Try installing it with:"
    echo "  sudo apt-get update && sudo apt-get install -y libfuse2"
    echo ""
    echo "If that doesn't work, you may need to build from source or use a different method."
    echo ""
    echo "Alternative: Extract the appimage and use it directly:"
    echo "  $NVIM_BIN_DIR/nvim --appimage-extract"
    echo "  mv squashfs-root $NVIM_DIR"
    echo "  ln -sf $NVIM_DIR/usr/bin/nvim $NVIM_BIN_DIR/nvim"
  fi
  ;;

*)
  echo "Error: Unsupported architecture: $ARCH"
  echo "Neovim prebuilt binaries support: x86_64, aarch64"
  echo ""
  echo "For other architectures, please build from source:"
  echo "  https://github.com/neovim/neovim/wiki/Building-Neovim"
  echo ""
  echo "Quick build instructions:"
  echo "  sudo apt-get install ninja-build gettext cmake unzip curl"
  echo "  git clone https://github.com/neovim/neovim"
  echo "  cd neovim && git checkout stable"
  echo "  make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local/share/nvim"
  echo "  make install"
  echo "  ln -sf $HOME/.local/share/nvim/bin/nvim $HOME/.local/bin/nvim"
  exit 1
  ;;
esac

# Verify installation
if [ -f "$NVIM_BIN_DIR/nvim" ]; then
  echo ""
  echo "Neovim installed successfully!"
  echo "Version: $("$NVIM_BIN_DIR/nvim" --version | head -n1)"
  echo "Location: $NVIM_BIN_DIR/nvim"
  echo ""
  echo "Make sure $NVIM_BIN_DIR is in your PATH"
  echo "Your .bash_profile should already have: export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
  echo "Next steps:"
  echo "1. Restart your shell or run: source ~/.bash_profile"
  echo "2. Run: nvim --version"
  echo "3. First launch will trigger LazyVim plugin installation"
else
  echo "Error: Neovim installation completed but binary not found"
  exit 1
fi
