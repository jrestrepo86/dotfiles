#!/bin/bash
# npm installation script
# Installs npm globally to work alongside pnpm
# Depends on: pnpm (05) which already provides Node.js
set -e

PNPM_HOME="$HOME/.local/share/pnpm"
NPM_DIR="$HOME/.local/share/npm"
NPM_CONFIG="$HOME/.npmrc"

echo "========================================"
echo "npm Installation"
echo "========================================"
echo ""

# Check if pnpm is installed (provides Node.js)
if [ ! -f "$PNPM_HOME/pnpm" ]; then
  echo "Error: pnpm not found at $PNPM_HOME"
  echo "pnpm installation script should have run first"
  echo ""
  echo "Install pnpm first: chezmoiscripts/run_once_after_05_install-pnpm.sh"
  exit 1
fi

# Get Node.js version from pnpm
echo "Checking Node.js installation..."
NODE_VERSION=$("$PNPM_HOME/pnpm" node --version 2>/dev/null || echo "")

if [ -z "$NODE_VERSION" ]; then
  echo "Error: Node.js not available through pnpm"
  echo "Try: pnpm env use --global lts"
  exit 1
fi

echo "✓ Node.js ${NODE_VERSION} available via pnpm"
echo ""

# Check if npm is already installed
if [ -f "$NPM_DIR/bin/npm" ] || command -v npm &>/dev/null; then
  echo "npm already installed:"
  if [ -f "$NPM_DIR/bin/npm" ]; then
    NPM_BIN="$NPM_DIR/bin/npm"
  else
    NPM_BIN="npm"
  fi

  echo "  Version: $($NPM_BIN --version 2>/dev/null || echo 'unknown')"
  echo "  Location: $(which npm 2>/dev/null || echo "$NPM_DIR/bin/npm")"
  echo ""
  echo "To reinstall, remove:"
  echo "  rm -rf $NPM_DIR"
  exit 0
fi

echo "Installing npm..."
echo "NPM_DIR: $NPM_DIR"
echo ""

# Create npm directory structure
mkdir -p "$NPM_DIR/bin"
mkdir -p "$NPM_DIR/lib"

# Create .npmrc configuration
echo "Configuring npm..."
cat >"$NPM_CONFIG" <<EOF
# npm configuration
# Managed by chezmoi: ~/.npmrc

# Installation directories
prefix=$NPM_DIR
cache=$HOME/.cache/npm
init-module=$HOME/.npm-init.js

# Global package installation behavior
fund=false
audit=true
save-exact=false

# Performance
progress=true
loglevel=warn

# Network
fetch-retries=3
fetch-retry-mintimeout=10000
fetch-retry-maxtimeout=60000
EOF

echo "✓ npm configuration created at $NPM_CONFIG"

# Install npm using pnpm's Node.js
echo ""
echo "Installing npm via pnpm..."
echo "This may take a few minutes..."

# Use pnpm to install npm globally
if "$PNPM_HOME/pnpm" add -g npm; then
  # Create symlink in NPM_DIR for consistency
  if [ -f "$PNPM_HOME/npm" ]; then
    ln -sf "$PNPM_HOME/npm" "$NPM_DIR/bin/npm"
    echo "✓ npm installed successfully via pnpm"
  fi
else
  echo "✗ npm installation via pnpm failed"
  echo ""
  echo "Alternative installation method:"
  echo "  curl -L https://www.npmjs.com/install.sh | sh"
  exit 1
fi

# Verify installation
echo ""
echo "Verifying npm installation..."

NPM_BIN="$PNPM_HOME/npm"
if [ ! -f "$NPM_BIN" ]; then
  NPM_BIN="$NPM_DIR/bin/npm"
fi

if [ -f "$NPM_BIN" ]; then
  NPM_VERSION=$("$NPM_BIN" --version 2>/dev/null)
  NODE_VERSION=$("$PNPM_HOME/pnpm" node --version 2>/dev/null)

  echo "✓ npm installed successfully!"
  echo ""
  echo "Installation details:"
  echo "  npm version: ${NPM_VERSION}"
  echo "  Node.js version: ${NODE_VERSION}"
  echo "  npm binary: $NPM_BIN"
  echo "  Config file: $NPM_CONFIG"
  echo "  Global packages: $NPM_DIR/lib/node_modules"
  echo ""
else
  echo "✗ npm installation completed but binary not found"
  exit 1
fi

# Show PATH configuration
echo "PATH Configuration:"
echo "  Your .bashrc should already have pnpm in PATH:"
echo '  export PNPM_HOME="$HOME/.local/share/pnpm"'
echo '  export PATH="$PNPM_HOME:$PATH"'
echo ""
echo "  npm will be available through pnpm's PATH"
echo ""

# Usage information
echo "========================================"
echo "Usage Information"
echo "========================================"
echo ""
echo "Basic commands:"
echo "  npm --version              # Check npm version"
echo "  npm install <package>      # Install package locally"
echo "  npm install -g <package>   # Install package globally"
echo "  npm list -g --depth=0      # List global packages"
echo "  npm outdated -g            # Check outdated global packages"
echo "  npm update -g              # Update global packages"
echo ""
echo "Global packages location:"
echo "  $NPM_DIR/lib/node_modules"
echo ""
echo "Cache location:"
echo "  $HOME/.cache/npm"
echo ""
echo "Configuration:"
echo "  Edit: $NPM_CONFIG"
echo "  View: npm config list"
echo ""
echo "Note: You have both npm and pnpm installed:"
echo "  - Use npm for traditional npm workflow"
echo "  - Use pnpm for faster, disk-efficient installs"
echo "  - Both share the same Node.js installation"
echo ""
echo "To start using npm:"
echo "  1. Restart your shell or run: source ~/.bashrc"
echo "  2. Verify: npm --version"
echo "  3. Try: npm install -g npm-check-updates"
echo ""
echo "Installation complete!"
