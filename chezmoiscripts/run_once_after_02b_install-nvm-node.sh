#!/bin/bash
# nvm and Node.js installation - independent of other tools
set -e

export NVM_DIR="$HOME/.local/share/nvm"

# Check if nvm is already installed
if [ -s "$NVM_DIR/nvm.sh" ]; then
  echo "nvm already installed at $NVM_DIR"
  # shellcheck disable=SC1091
  source "$NVM_DIR/nvm.sh"
  echo "Current nvm version: $(nvm --version)"
  if command -v node &> /dev/null; then
    echo "Current node version: $(node --version)"
  fi
  exit 0
fi

echo "Installing nvm (Node Version Manager)..."
echo "NVM_DIR: $NVM_DIR"

# Create directory
mkdir -p "$NVM_DIR"

# Try multiple methods to get latest version
NVM_VERSION=""

# Method 1: Try GitHub API (might be rate limited)
echo "Attempting to fetch latest nvm version..."
NVM_VERSION=$(curl -s -f https://api.github.com/repos/nvm-sh/nvm/releases/latest 2> /dev/null | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' || echo "")

# Method 2: If that fails, try scraping the releases page
if [ -z "$NVM_VERSION" ]; then
  echo "API failed, trying releases page..."
  NVM_VERSION=$(curl -s -f https://github.com/nvm-sh/nvm/releases/latest 2> /dev/null | grep -oP 'tag/\Kv[0-9.]+' | head -1 || echo "")
fi

# Method 3: Use a recent known good version as fallback
if [ -z "$NVM_VERSION" ]; then
  echo "Warning: Could not fetch latest version, using fallback v0.40.1"
  NVM_VERSION="v0.40.1"
fi

echo "Installing nvm ${NVM_VERSION}..."

# Download and install nvm using direct download (more reliable than install.sh)
INSTALL_SCRIPT="/tmp/nvm-install-$$.sh"

# Try to download the install script
if curl -s -f -o "$INSTALL_SCRIPT" "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh"; then
  echo "✓ Downloaded install script"

  # Verify it's actually the install script (not an error page)
  if grep -q "nvm" "$INSTALL_SCRIPT" && ! grep -q "<!DOCTYPE" "$INSTALL_SCRIPT"; then
    echo "✓ Install script validated"

    # Run the install script
    if bash "$INSTALL_SCRIPT"; then
      echo "✓ nvm installation completed"
    else
      echo "Error: nvm installation script failed"
      rm -f "$INSTALL_SCRIPT"
      exit 1
    fi
  else
    echo "Error: Downloaded file is not the nvm install script (possibly rate limited)"
    rm -f "$INSTALL_SCRIPT"
    exit 1
  fi
else
  echo "Error: Failed to download nvm install script"
  echo "You may be rate limited by GitHub. Please try again in a few minutes."
  echo ""
  echo "Alternative: Install nvm manually:"
  echo "  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
  exit 1
fi

# Clean up
rm -f "$INSTALL_SCRIPT"

# Load nvm for this session
export NVM_DIR="$HOME/.local/share/nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck disable=SC1091
  \. "$NVM_DIR/nvm.sh"
else
  echo "Error: nvm.sh not found after installation"
  exit 1
fi

# Verify nvm installation
if ! command -v nvm &> /dev/null; then
  echo "Error: nvm command not found after installation"
  echo "Try running: source $NVM_DIR/nvm.sh"
  exit 1
fi

echo "✓ nvm installed successfully!"
echo "nvm version: $(nvm --version)"
echo ""

# Install latest LTS version of Node.js
echo "Installing Node.js LTS..."
if ! nvm install --lts; then
  echo "Error: Node.js LTS installation failed"
  echo "Try manually: nvm install --lts"
  exit 1
fi

# Set LTS as default
echo "Setting LTS as default version..."
nvm alias default 'lts/*'

# Verify Node.js installation
if command -v node &> /dev/null; then
  echo ""
  echo "✓ Node.js installed successfully!"
  echo "Node version: $(node --version)"
  echo "npm version: $(npm --version)"
  echo ""
  echo "Your .bashrc already has the correct nvm configuration"
  echo ""
  echo "To use nvm in the current session:"
  echo '  source "$NVM_DIR/nvm.sh"'
  echo ""
  echo "Common nvm commands:"
  echo "  nvm install node       # Install latest version"
  echo "  nvm install --lts      # Install latest LTS"
  echo "  nvm install 20         # Install specific version"
  echo "  nvm use 20             # Switch to version 20"
  echo "  nvm ls                 # List installed versions"
  echo "  nvm ls-remote --lts    # List available LTS versions"
  echo "  nvm alias default node # Set default version"
else
  echo "Error: Node.js installation completed but node binary not found"
  echo "Try running: source ~/.bashrc && nvm use --lts"
  exit 1
fi
