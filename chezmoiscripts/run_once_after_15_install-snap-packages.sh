#!/bin/bash
# Snap packages installation
# Only runs on desktop machines (skips neptuno/cluster)
# To add more packages: just add them to the SNAP_PACKAGES array below
set -e

##################################################
# CONFIGURATION
##################################################
# Standard snap packages (sandboxed)
SNAP_PACKAGES=(
  "chromium" # Web browser
  # Add more sandboxed packages below:
  # "firefox"
  # "discord"
  # "spotify"
  # "vlc"
  # "slack"
)

# Classic confinement packages (need --classic flag)
# These have more system access - use with caution
SNAP_CLASSIC_PACKAGES=(
  "ghostty"  # Modern terminal emulator
  "obsidian" # Note-taking app (markdown)
  # Add more classic packages below:
  "code" # VS Code
  # "intellij-idea-community"
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

# Ensure snapd service is running
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
  # Skip comments and empty lines
  [[ "$pkg" =~ ^#.*$ ]] || [[ -z "$pkg" ]] && continue

  # Extract package name (everything before first space/comment)
  pkg_name=$(echo "$pkg" | awk '{print $1}' | tr -d '"')

  echo "→ $pkg_name"

  # Check if already installed
  if snap list 2>/dev/null | grep -q "^$pkg_name "; then
    echo "  ✓ Already installed"
    SKIPPED=$((SKIPPED + 1))
  else
    # Install package
    if sudo snap install "$pkg_name" 2>&1 | tee /tmp/snap_install_$$.log | grep -v "^$"; then
      # Check if actually installed (not just no error)
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
    rm -f /tmp/snap_install_$$.log
  fi
  echo ""
done

# Install classic confinement packages
for pkg in "${SNAP_CLASSIC_PACKAGES[@]}"; do
  # Skip comments and empty lines
  [[ "$pkg" =~ ^#.*$ ]] || [[ -z "$pkg" ]] && continue

  # Extract package name
  pkg_name=$(echo "$pkg" | awk '{print $1}' | tr -d '"')

  echo "→ $pkg_name (classic)"

  # Check if already installed
  if snap list 2>/dev/null | grep -q "^$pkg_name "; then
    echo "  ✓ Already installed"
    SKIPPED=$((SKIPPED + 1))
  else
    # Install with --classic flag
    if sudo snap install "$pkg_name" --classic 2>&1 | tee /tmp/snap_install_$$.log | grep -v "^$"; then
      # Verify installation
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
    rm -f /tmp/snap_install_$$.log
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
  echo ""
  echo "Try manually: sudo snap install <package>"
fi

echo ""
echo "Installed snaps:"
snap list 2>/dev/null | grep -E "(ghostty|chromium|obsidian)" || echo "  (none from this script)"

echo ""
echo "Note: Classic confinement packages have more system access"
echo ""
echo "Useful commands:"
echo "  snap list              # List all installed snaps"
echo "  snap refresh           # Update all snaps"
echo "  snap refresh <pkg>     # Update specific snap"
echo "  snap info <pkg>        # Show package info"
echo "  snap remove <pkg>      # Uninstall snap"

if [ $INSTALLED -gt 0 ]; then
  echo ""
  echo "Note: You may need to logout/login for apps to appear in menu"
  echo "      Or force update: xdg-desktop-menu forceupdate"
fi

echo ""
echo "Installation complete!"
