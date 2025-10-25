#!/bin/bash
# Ruby installation - depends on miniconda (01)
set -e

MINICONDA_DIR="$HOME/.local/share/miniconda"
CONDA_BIN="$MINICONDA_DIR/bin/conda"
export GEM_HOME="$HOME/.local/share/gem"

# Check if Miniconda is installed
if [ ! -f "$CONDA_BIN" ]; then
  echo "Error: Miniconda not found at $MINICONDA_DIR"
  echo "The miniconda installation script should have run first"
  exit 1
fi

# Check if Ruby is already installed via conda
if "$CONDA_BIN" list ruby 2>/dev/null | grep -q "^ruby "; then
  echo "Ruby already installed via conda"
  echo "Ruby version: $("$MINICONDA_DIR/bin/ruby" --version)"
  exit 0
fi

echo "Installing Ruby via conda..."
echo "GEM_HOME: $GEM_HOME"

# Install Ruby and build tools from conda-forge
if ! "$CONDA_BIN" install -y -c conda-forge \
  ruby \
  gcc_linux-64 \
  gxx_linux-64 \
  make; then
  echo "Error: Ruby installation via conda failed"
  exit 1
fi

# Create gem home directory
mkdir -p "$GEM_HOME"

# Configure gem to install to GEM_HOME
echo "gem: --user-install" >"$HOME/.gemrc"

# Get Ruby version for PATH
RUBY_VERSION=$("$MINICONDA_DIR/bin/ruby" -e 'puts RbConfig::CONFIG["ruby_version"]' 2>/dev/null || echo "")

if [ -z "$RUBY_VERSION" ]; then
  echo "Warning: Could not determine Ruby version"
  RUBY_VERSION="3.x.x" # Fallback
fi

echo "Ruby installed successfully!"
echo ""
echo "Ruby version: $("$MINICONDA_DIR/bin/ruby" --version)"
echo "Ruby binary: $MINICONDA_DIR/bin/ruby"
echo "Gem home: $GEM_HOME"
echo ""
echo "Your .bash_profile should already have the correct PATH configuration:"
echo '  export GEM_HOME="$HOME/.local/share/gem"'
echo "  export PATH=\"\$GEM_HOME/ruby/$RUBY_VERSION/bin:\$PATH\""
echo ""
echo "To install gems: gem install <gem-name>"
echo "Example: gem install neovim"
