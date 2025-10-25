#!/bin/bash
# Data science packages installation - runs after all essential tools are installed
# This is separate to speed up initial setup and allow skipping if not needed
set -e

MINICONDA_DIR="$HOME/.local/share/miniconda"
CONDA_BIN="$MINICONDA_DIR/bin/conda"

# Check if Miniconda is installed
if [ ! -f "$CONDA_BIN" ]; then
  echo "Error: Miniconda not found at $MINICONDA_DIR"
  exit 1
fi

echo "Installing Data Science Packages"
echo "This may take 5-15 minutes..."
echo ""

# List of packages to install
PACKAGES=(
  numpy
  pandas
  matplotlib
  plotly
  scipy
  scikit-learn
  pytorch
  seaborn
  dash
  scikit-build
  tqdm
  debugpy
)

# Check if already installed
ALL_INSTALLED=true
for pkg in "${PACKAGES[@]}"; do
  if ! "$CONDA_BIN" list "$pkg" 2>/dev/null | grep -q "^$pkg "; then
    ALL_INSTALLED=false
    break
  fi
done

if $ALL_INSTALLED; then
  echo "All data science packages already installed!"
  echo ""
  "$CONDA_BIN" list | grep -E "(numpy|pandas|matplotlib|plotly|scipy|scikit-learn|pytorch|seaborn|dash|scikit-build|tqdm|debugpy)"
  exit 0
fi

# Install packages
echo "Installing packages..."
if "$CONDA_BIN" install -c conda-forge -c pytorch -y "${PACKAGES[@]}"; then
  echo ""
  echo "✓ All packages installed successfully!"
else
  echo ""
  echo "⚠ Some packages may have failed to install"
  echo "Check installed packages with: conda list"
fi

# Show summary
echo ""
echo "Installed packages:"
"$CONDA_BIN" list | grep -E "(numpy|pandas|matplotlib|plotly|scipy|scikit-learn|pytorch|seaborn|dash|scikit-build|tqdm|debugpy)"
echo ""
echo "Quick test:"
echo "  python -c 'import numpy, pandas, torch; print(\"All imports work!\")'"
