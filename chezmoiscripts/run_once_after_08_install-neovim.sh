#!/bin/bash
# Neovim installation
# Installs nvim to ~/.local (bin and share directories)
set -e

# Installation paths
NVIM_INSTALL_DIR="$HOME/.local/share/nvim-install" # Where nvim program files go
NVIM_BIN_DIR="$HOME/.local/bin"
ARCH=$(uname -m)
TMP_DIR="/tmp/nvim-install-$$"

# Check if Neovim is already installed and working
if [ -f "$NVIM_BIN_DIR/nvim" ]; then
  if "$NVIM_BIN_DIR/nvim" --version &>/dev/null; then
    echo "Neovim already installed at $NVIM_BIN_DIR"
    echo "Current version: $("$NVIM_BIN_DIR/nvim" --version | head -n1)"
    exit 0
  else
    echo "Neovim binary exists but doesn't work - reinstalling..."
    rm -f "$NVIM_BIN_DIR/nvim"
    rm -rf "$NVIM_INSTALL_DIR"
  fi
fi

echo "Fetching latest Neovim stable version..."
# Get the latest stable release tag
NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$NVIM_VERSION" ]; then
  echo "Failed to fetch latest version, using fallback v0.10.4"
  NVIM_VERSION="v0.10.4"
fi

echo "Installing Neovim ${NVIM_VERSION} for architecture: ${ARCH}..."

# Create directories
mkdir -p "$NVIM_INSTALL_DIR"
mkdir -p "$NVIM_BIN_DIR"
mkdir -p "$TMP_DIR"

cd "$TMP_DIR"

# Map architecture names and determine installation method
case $ARCH in
x86_64)
  echo "Using tarball installation for x86_64..."
  NVIM_ARCHIVE="nvim-linux-x86_64.tar.gz"
  NVIM_EXTRACT_DIR="nvim-linux-x86_64"
  NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_ARCHIVE}"

  echo "Downloading Neovim tarball..."
  if ! wget -q --show-progress "$NVIM_URL"; then
    echo "Error: Failed to download Neovim from $NVIM_URL"
    rm -rf "$TMP_DIR"
    exit 1
  fi

  echo "Extracting Neovim..."
  if ! tar -xzf "$NVIM_ARCHIVE"; then
    echo "Error: Failed to extract Neovim archive"
    rm -rf "$TMP_DIR"
    exit 1
  fi

  # Move contents to install directory
  rm -rf "$NVIM_INSTALL_DIR"
  mv "$NVIM_EXTRACT_DIR" "$NVIM_INSTALL_DIR"

  # Create symlink in .local/bin
  ln -sf "$NVIM_INSTALL_DIR/bin/nvim" "$NVIM_BIN_DIR/nvim"
  ;;

aarch64 | arm64)
  echo "Using tarball installation for ARM64..."
  NVIM_ARCHIVE="nvim-linux-arm64.tar.gz"
  NVIM_EXTRACT_DIR="nvim-linux-arm64"
  NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_ARCHIVE}"

  echo "Downloading Neovim tarball..."
  if wget -q --show-progress "$NVIM_URL" 2>/dev/null; then
    echo "Extracting Neovim..."
    if tar -xzf "$NVIM_ARCHIVE"; then
      rm -rf "$NVIM_INSTALL_DIR"
      mv "$NVIM_EXTRACT_DIR" "$NVIM_INSTALL_DIR"
      ln -sf "$NVIM_INSTALL_DIR/bin/nvim" "$NVIM_BIN_DIR/nvim"
    else
      echo "Error: Failed to extract Neovim archive"
      rm -rf "$TMP_DIR"
      exit 1
    fi
  else
    echo "ARM64 tarball not available for ${NVIM_VERSION}, trying AppImage..."

    # Fallback to AppImage
    NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage"

    if wget -4 --show-progress "$NVIM_URL" -O nvim.appimage; then
      chmod +x nvim.appimage

      # Try to extract AppImage (works even without FUSE)
      echo "Extracting AppImage..."
      if ./nvim.appimage --appimage-extract &>/dev/null; then
        rm -rf "$NVIM_INSTALL_DIR"
        mv squashfs-root "$NVIM_INSTALL_DIR"
        ln -sf "$NVIM_INSTALL_DIR/usr/bin/nvim" "$NVIM_BIN_DIR/nvim"
        echo "✓ AppImage extracted successfully"
      else
        # If extraction fails, try running directly (needs FUSE)
        echo "⚠ AppImage extraction failed"
        echo "Trying direct AppImage installation (requires libfuse2)..."
        mv nvim.appimage "$NVIM_BIN_DIR/nvim"
        chmod +x "$NVIM_BIN_DIR/nvim"

        if ! "$NVIM_BIN_DIR/nvim" --version &>/dev/null; then
          echo ""
          echo "⚠ AppImage doesn't work. Install libfuse2:"
          echo "  sudo apt-get update && sudo apt-get install -y libfuse2"
          rm -f "$NVIM_BIN_DIR/nvim"
          rm -rf "$TMP_DIR"
          exit 1
        fi
      fi
    else
      echo "Error: Failed to download Neovim AppImage"
      rm -rf "$TMP_DIR"
      exit 1
    fi
  fi
  ;;

*)
  echo "Error: Unsupported architecture: $ARCH"
  echo "Neovim prebuilt binaries support: x86_64, aarch64"
  echo ""
  echo "For other architectures, please build from source:"
  echo "  https://github.com/neovim/neovim/wiki/Building-Neovim"
  rm -rf "$TMP_DIR"
  exit 1
  ;;
esac

# Clean up temp directory
rm -rf "$TMP_DIR"

# Verify installation
if [ -f "$NVIM_BIN_DIR/nvim" ] && "$NVIM_BIN_DIR/nvim" --version &>/dev/null; then
  echo ""
  echo "========================================"
  echo "✓ Neovim installed successfully!"
  echo "========================================"
  echo ""
  echo "Version: $("$NVIM_BIN_DIR/nvim" --version | head -n1)"
  echo "Location: $NVIM_BIN_DIR/nvim"
else
  echo "Error: Neovim installation completed but verification failed"
  exit 1
fi
