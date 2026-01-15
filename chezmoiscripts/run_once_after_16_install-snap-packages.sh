#!/bin/bash
# Snap packages installation
# Only runs on desktop machines (skips neptuno/cluster)
set -e

##################################################
# CONFIGURATION
##################################################
SNAP_PACKAGES=(
  "chromium"
)

SNAP_CLASSIC_PACKAGES=(
  "ghostty"
  "obsidian"
  "code"
)

##################################################
# HOSTNAME CHECK
##################################################
HOSTNAME=$(hostname)

if [[ "$HOSTNAME" == "neptuno" ]] || [[ "$HOSTNAME" == neptuno* ]] ||
  [[ "$HOSTNAME" == "jupiter" ]] || [[ "$HOSTNAME" == jupiter* ]]; then
  echo "Running on server (neptuno/jupiter) - skipping snap packages"
  exit 0
fi

##################################################
# CHECK SNAPD
##################################################
if ! command -v snap &>/dev/null; then
  echo "Error: snap command not found"
  echo "Install snapd first: sudo apt-get install snapd"
  exit 1
fi

if ! systemctl is-active --quiet snapd.service 2>/dev/null; then
  echo "Starting snapd service..."
  sudo systemctl start snapd.service 2>/dev/null || true
  sudo systemctl enable snapd.service 2>/dev/null || true
  sleep 3
fi

##################################################
# INSTALL PACKAGES
##################################################
echo "Installing snap packages..."
echo ""

INSTALLED=0
SKIPPED=0
FAILED=()

# Install regular (sandboxed) packages
for pkg in "${SNAP_PACKAGES[@]}"; do
  [[ "$pkg" =~ ^#.*$ ]] || [[ -z "$pkg" ]] && continue
  pkg_name=$(echo "$pkg" | awk '{print $1}' | tr -d '"')

  echo "→ $pkg_name"

  if snap list 2>/dev/null | grep -q "^$pkg_name "; then
    echo "  ✓ Already installed"
    SKIPPED=$((SKIPPED + 1))
  else
    if sudo snap install "$pkg_name" 2>&1 | grep -v "^$"; then
      if snap list 2>/dev/null | grep -q "^$pkg_name "; then
        echo "  ✓ Installed successfully"
        INSTALLED=$((INSTALLED + 1))
      else
        echo "  ✗ Installation failed"
        FAILED+=("$pkg_name")
      fi
    else
      echo "  ✗ Installation failed"
      FAILED+=("$pkg_name")
    fi
  fi
  echo ""
done

# Install classic confinement packages
for pkg in "${SNAP_CLASSIC_PACKAGES[@]}"; do
  [[ "$pkg" =~ ^#.*$ ]] || [[ -z "$pkg" ]] && continue
  pkg_name=$(echo "$pkg" | awk '{print $1}' | tr -d '"')

  echo "→ $pkg_name (classic)"

  if snap list 2>/dev/null | grep -q "^$pkg_name "; then
    echo "  ✓ Already installed"
    SKIPPED=$((SKIPPED + 1))
  else
    if sudo snap install "$pkg_name" --classic 2>&1 | grep -v "^$"; then
      if snap list 2>/dev/null | grep -q "^$pkg_name "; then
        echo "  ✓ Installed successfully (classic confinement)"
        INSTALLED=$((INSTALLED + 1))
      else
        echo "  ✗ Installation failed"
        FAILED+=("$pkg_name")
      fi
    else
      echo "  ✗ Installation failed"
      FAILED+=("$pkg_name")
    fi
  fi
  echo ""
done

##################################################
# SUMMARY
##################################################
echo "=========================================="
echo "Summary"
echo "=========================================="
TOTAL_PACKAGES=$((${#SNAP_PACKAGES[@]} + ${#SNAP_CLASSIC_PACKAGES[@]}))
echo "Total packages: $TOTAL_PACKAGES"
echo "Newly installed: $INSTALLED"
echo "Already installed: $SKIPPED"
echo "Failed: ${#FAILED[@]}"

if [ ${#FAILED[@]} -gt 0 ]; then
  echo ""
  echo "Failed packages:"
  printf '  ✗ %s\n' "${FAILED[@]}"
fi

echo ""
echo "Installed snaps:"
snap list 2>/dev/null | grep -E "(ghostty|chromium|obsidian|code)" || echo "  (none from this script)"

echo ""
echo "Installation complete!"
