#!/bin/bash
# Save this as: .chezmoiscripts/run_once_after_install-conda-packages.sh

set -e

MINICONDA_DIR="$HOME/.local/share/miniconda"
CONDA_BIN="$MINICONDA_DIR/bin/conda"

# Check if Miniconda is installed
if [ ! -f "$CONDA_BIN" ]; then
  echo "Error: Miniconda not found at $MINICONDA_DIR"
  echo "Please run the miniconda installation script first"
  exit 1
fi

echo "Installing conda packages..."
# Add conda-forge channel
"$CONDA_BIN" config --add channels conda-forge
"$CONDA_BIN" config --add channels pytorch
"$CONDA_BIN" config --set channel_priority flexible

# Update conda itself
"$CONDA_BIN" update -n base -c defaults conda -y

# Install packages in base environment
# Modify this list with your desired packages
"$CONDA_BIN" install -c conda-forge -y \
  pip \
  numpy \
  pandas \
  matplotlib \
  plotly \
  pandas \
  scipy \
  scikit-learn \
  pytorch \
  seaborn \
  dash \
  scikit-build \
  tqdm \
  debugpy \
  cmake \
  fzf \
  "starship>=1.23.0" \
  mc \
  lazygit

# Optional: Create a named environment with specific packages
# Uncomment and modify as needed
# "$CONDA_BIN" create -n myenv python=3.11 -y
# "$CONDA_BIN" install -n myenv -y scipy scikit-learn

echo "Conda packages installed successfully"
