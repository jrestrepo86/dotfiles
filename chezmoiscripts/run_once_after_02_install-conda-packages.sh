#!/bin/bash
# Conda packages installation - depends on miniconda (01)
set -e

MINICONDA_DIR="$HOME/.local/share/miniconda"
CONDA_BIN="$MINICONDA_DIR/bin/conda"

# Check if Miniconda is installed
if [ ! -f "$CONDA_BIN" ]; then
  echo "Error: Miniconda not found at $MINICONDA_DIR"
  echo "The miniconda installation script should have run first"
  exit 1
fi

echo "Installing conda packages..."

# Add conda-forge channel
"$CONDA_BIN" config --add channels conda-forge
"$CONDA_BIN" config --add channels pytorch
"$CONDA_BIN" config --set channel_priority flexible

# Update conda itself
echo "Updating conda..."
"$CONDA_BIN" update -n base -c defaults conda -y

# Install packages in base environment
echo "Installing essential packages (required for dotfiles setup)..."
if ! "$CONDA_BIN" install -c conda-forge -y \
  pip \
  cmake \
  nodejs \
  fzf \
  "starship>=1.23.0" \
  mc \
  lazygit; then
  echo "Warning: Some essential conda packages failed to install"
  echo "You may need to install them manually later"
fi

echo ""
echo "Essential conda packages installation complete"
echo ""
echo "Installed essential packages:"
"$CONDA_BIN" list | grep -E "(pip|cmake|fzf|starship|mc|lazygit)"
echo ""
echo "Note: Data science packages (numpy, pandas, pytorch, etc.) will be installed"
echo "      by a separate script (run_once_after_10_install-datascience.sh)"
