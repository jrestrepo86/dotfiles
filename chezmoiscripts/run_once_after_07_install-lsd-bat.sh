#!/bin/bash
# lsd and bat installation - independent of other tools
set -e

BIN_DIR="$HOME/.local/bin"
TMP_DIR="/tmp/lsd-bat-install-$$"
ARCH=$(uname -m)

# Create directories
mkdir -p "$BIN_DIR"
mkdir -p "$TMP_DIR"

# Map architecture names
case $ARCH in
x86_64)
  ARCH_SUFFIX="x86_64-unknown-linux-gnu"
  ;;
aarch64 | arm64)
  ARCH_SUFFIX="aarch64-unknown-linux-gnu"
  ;;
armv7l)
  ARCH_SUFFIX="armv7-unknown-linux-gnueabihf"
  ;;
*)
  echo "Warning: Unsupported architecture: $ARCH"
  echo "Supported: x86_64, aarch64, armv7l"
  exit 0 # Don't fail, just skip
  ;;
esac

echo "Installing lsd and bat for $ARCH_SUFFIX to $BIN_DIR..."

# Install lsd
if [ ! -f "$BIN_DIR/lsd" ]; then
  echo "Installing lsd..."
  cd "$TMP_DIR"

  LSD_VERSION=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' || echo "")

  if [ -z "$LSD_VERSION" ]; then
    echo "Warning: Could not fetch lsd version, skipping"
  else
    LSD_URL="https://github.com/lsd-rs/lsd/releases/download/${LSD_VERSION}/lsd-${LSD_VERSION}-${ARCH_SUFFIX}.tar.gz"

    if wget -q "$LSD_URL" -O lsd.tar.gz 2>/dev/null; then
      tar -xzf lsd.tar.gz
      mv "lsd-${LSD_VERSION}-${ARCH_SUFFIX}/lsd" "$BIN_DIR/" 2>/dev/null || {
        # Fallback: try to find lsd binary in extracted files
        find . -name "lsd" -type f -executable -exec mv {} "$BIN_DIR/" \;
      }
      echo "lsd installed successfully"
    else
      echo "Warning: Could not download lsd for $ARCH_SUFFIX"
    fi
  fi
else
  echo "lsd already installed"
fi

# Install bat
if [ ! -f "$BIN_DIR/bat" ]; then
  echo "Installing bat..."
  cd "$TMP_DIR"

  BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' || echo "")

  if [ -z "$BAT_VERSION" ]; then
    echo "Warning: Could not fetch bat version, skipping"
  else
    BAT_URL="https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat-${BAT_VERSION}-${ARCH_SUFFIX}.tar.gz"

    if wget -q "$BAT_URL" -O bat.tar.gz 2>/dev/null; then
      tar -xzf bat.tar.gz
      mv "bat-${BAT_VERSION}-${ARCH_SUFFIX}/bat" "$BIN_DIR/" 2>/dev/null || {
        # Fallback: try to find bat binary in extracted files
        find . -name "bat" -type f -executable -exec mv {} "$BIN_DIR/" \;
      }
      echo "bat installed successfully"
    else
      echo "Warning: Could not download bat for $ARCH_SUFFIX"
    fi
  fi
else
  echo "bat already installed"
fi

# Clean up
rm -rf "$TMP_DIR"

# Verify installations
echo ""
echo "Installation summary:"
if [ -f "$BIN_DIR/lsd" ]; then
  echo "✓ lsd: $("$BIN_DIR/lsd" --version)"
else
  echo "✗ lsd: not installed"
fi

if [ -f "$BIN_DIR/bat" ]; then
  echo "✓ bat: $("$BIN_DIR/bat" --version)"
else
  echo "✗ bat: not installed"
fi

echo ""
echo "Make sure $BIN_DIR is in your PATH"
echo "Your .bash_profile should already have: export PATH=\"\$HOME/.local/bin:\$PATH\""
