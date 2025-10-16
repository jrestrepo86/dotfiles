#!/bin/bash
# Save this as: .chezmoiscripts/run_once_after_install-ruby.sh

set -e

MINICONDA_DIR="$HOME/.local/share/miniconda"
CONDA_BIN="$MINICONDA_DIR/bin/conda"
export GEM_HOME="$HOME/.local/share/gem"

# Check if Miniconda is installed
if [ ! -f "$CONDA_BIN" ]; then
  echo "Error: Miniconda not found at $MINICONDA_DIR"
  echo "Please run the miniconda installation script first"
  exit 1
fi

echo "Installing Ruby via conda..."
echo "GEM_HOME: $GEM_HOME"

# Install Ruby and build tools from conda-forge
"$CONDA_BIN" install -y -c conda-forge \
  ruby \
  gcc_linux-64 \
  gxx_linux-64 \
  make

# Create gem home directory
mkdir -p "$GEM_HOME"

# Configure gem to install to GEM_HOME
echo "gem: --user-install" >"$HOME/.gemrc"

echo "Ruby installed successfully!"
echo ""
echo "Ruby version: $("$MINICONDA_DIR/bin/ruby" --version)"
echo ""
echo "Add this line to your .bashrc:"
echo '  export GEM_HOME="$HOME/.local/share/gem"'
echo '  export PATH="$GEM_HOME/bin:$PATH"'
echo ""
echo "To install gems: gem install <gem-name>"
