#!/bin/bash
# Snap packages installation
# Only runs on machines that are NOT neptuno (cluster/server)
# Installs: Ghostty (terminal), Chromium (browser)
#
# Requires: snapd (installed by run_once_after_14_install-desktop-apps.sh)
set -e

SNAP_PACKAGES=(
  "ghostty"  # Modern terminal emulator
  "chromium" # Web browser
  "obsidean" # md files
)

HOSTNAME=$(hostname)

echo "=========================================="
echo "Snap Packages Installer"
echo "=========================================="
echo "Current hostname: $HOSTNAME"
echo ""

# Check if running on neptuno
if [[ "$HOSTNAME" == "neptuno" ]] || [[ "$HOSTNAME" == neptuno* ]]; then
  echo "⚠ Running on neptuno (cluster/server)"
  echo "Skipping snap packages installation"
  echo ""
  echo "Snap packages are for desktop machines only."
  exit 0
fi

echo "✓ Running on desktop machine"
echo "Proceeding with snap packages installation..."
echo ""

##################################################
# CHECK SNAPD
##################################################
if ! command -v snap &>/dev/null; then
  echo "✗ snap command not found"
  echo ""
  echo "snapd should have been installed by script 14:"
  echo "  run_once_after_14_install-desktop-apps.sh"
  echo ""
  echo "Install it manually:"
  echo "  sudo apt-get update"
  echo "  sudo apt-get install -y snapd"
  echo ""
  exit 1
fi

echo "✓ snap command available"
echo ""

# Ensure snapd service is running
if ! systemctl is-active --quiet snapd.service 2>/dev/null; then
  echo "Starting snapd service..."
  if sudo systemctl start snapd.service 2>/dev/null; then
    echo "✓ snapd service started"
  else
    echo "⚠ Could not start snapd service"
  fi

  sudo systemctl enable snapd.service 2>/dev/null || true
  sleep 3
fi

if systemctl is-active --quiet snapd.service 2>/dev/null; then
  echo "✓ snapd service is active"
else
  echo "⚠ snapd service is not active, but continuing anyway..."
fi
echo ""

##################################################
# SNAP PACKAGES
##################################################
echo "=========================================="
echo "Installing Snap Packages"
echo "=========================================="
echo ""

TOTAL_APPS=${#SNAP_PACKAGES[@]}
INSTALLED_APPS=0
FAILED_APPS=()

echo "Packages to install:"
printf '  - %s\n' "${SNAP_PACKAGES[@]}"
echo ""

for snap_pkg in "${SNAP_PACKAGES[@]}"; do
  echo "----------------------------------------"
  echo "Package: $snap_pkg"
  echo "----------------------------------------"

  # Check if already installed
  if snap list 2>/dev/null | grep -q "^$snap_pkg "; then
    echo "✓ $snap_pkg already installed"
    echo ""
    echo "Current version:"
    snap info "$snap_pkg" | grep "installed:" || true
    echo ""
    echo "To update: sudo snap refresh $snap_pkg"
    INSTALLED_APPS=$((INSTALLED_APPS + 1))
  else
    echo "Installing $snap_pkg..."

    # Install snap package
    if sudo snap install "$snap_pkg"; then
      echo "✓ $snap_pkg installed successfully"
      echo ""
      snap info "$snap_pkg" | grep "installed:" || true
      INSTALLED_APPS=$((INSTALLED_APPS + 1))
    else
      echo "✗ Failed to install $snap_pkg"
      FAILED_APPS+=("$snap_pkg")

      echo ""
      echo "Troubleshooting:"
      echo "  1. Check internet connection"
      echo "  2. Try: sudo snap refresh"
      echo "  3. Check: snap find $snap_pkg"
      echo "  4. Manual install: sudo snap install $snap_pkg"
    fi
  fi
  echo ""
done

##################################################
# INSTALLATION SUMMARY
##################################################
echo "=========================================="
echo "Installation Summary"
echo "=========================================="
echo ""
echo "Total packages: $TOTAL_APPS"
echo "Successfully installed: $INSTALLED_APPS"
echo "Failed: $((TOTAL_APPS - INSTALLED_APPS))"

if [ ${#FAILED_APPS[@]} -gt 0 ]; then
  echo ""
  echo "Failed installations:"
  printf '  ✗ %s\n' "${FAILED_APPS[@]}"
  echo ""
  echo "Try installing manually:"
  for pkg in "${FAILED_APPS[@]}"; do
    echo "  sudo snap install $pkg"
  done
fi

echo ""
echo "=========================================="
echo "Installed Snap Packages"
echo "=========================================="
echo ""

snap list ghostty &>/dev/null && {
  echo "✓ Ghostty Terminal:"
  echo "    Launch: ghostty"
  echo "    Config: ~/.config/ghostty/config"
} || echo "✗ Ghostty"

echo ""

snap list chromium &>/dev/null && {
  echo "✓ Chromium Browser:"
  echo "    Launch: chromium"
  echo "    Profile: ~/.config/chromium/"
} || echo "✗ Chromium"

echo ""
echo "=========================================="
echo "Snap Information & Commands"
echo "=========================================="
echo ""
echo "Installed snaps:"
snap list 2>/dev/null || echo "  (none)"
echo ""
echo "Useful commands:"
echo "  snap list                    # List installed snaps"
echo "  snap refresh                 # Update all snaps"
echo "  snap refresh <package>       # Update specific snap"
echo "  snap info <package>          # Show package details"
echo "  snap remove <package>        # Uninstall snap"
echo "  snap find <term>             # Search for snaps"
echo ""
echo "Snap updates:"
echo "  - Snaps auto-update 4 times per day"
echo "  - To prevent updates: sudo snap refresh --hold <package>"
echo "  - To allow updates:   sudo snap refresh --unhold <package>"
echo "  - Check schedule:     snap refresh --time"
echo ""
echo "Snap connections (for file access):"
echo "  snap connections <package>   # Show what snap can access"
echo "  snap connect <plug>:<slot>   # Grant access"
echo "  snap disconnect <plug>       # Revoke access"
echo ""

##################################################
# POST-INSTALLATION NOTES
##################################################
echo "=========================================="
echo "Post-Installation Notes"
echo "=========================================="
echo ""
echo "Ghostty Terminal:"
echo "  - Fast, GPU-accelerated terminal"
echo "  - Configuration file already in your dotfiles"
echo "  - First launch may take a few extra seconds"
echo "  - Check config: cat ~/.config/ghostty/config"
echo ""
echo "Chromium Browser:"
echo "  - Sandboxed snap version"
echo "  - Auto-updates daily"
echo "  - Has access to:"
echo "    - Home directory"
echo "    - Downloads folder"
echo "    - Removable media (if connected)"
echo ""
echo "Application Menu:"
echo "  - Snap apps may require logout/login to appear in menu"
echo "  - Can always launch from terminal"
echo ""
echo "Troubleshooting:"
echo "  - Apps not appearing? Try: xdg-desktop-menu forceupdate"
echo "  - Chromium file access issues? Check: snap connections chromium"
echo "  - Service issues? Restart: sudo systemctl restart snapd"
echo ""

##################################################
# VERIFY INSTALLATION
##################################################
if command -v ghostty &>/dev/null; then
  echo "✓ ghostty command is available"
else
  echo "⚠ ghostty command not found in PATH"
  echo "  You may need to restart your shell or add to PATH:"
  echo "  export PATH=\"/snap/bin:\$PATH\""
fi

if command -v chromium &>/dev/null; then
  echo "✓ chromium command is available"
else
  echo "⚠ chromium command not found in PATH"
  echo "  You may need to restart your shell"
fi

echo ""
echo "Installation complete!"
echo ""
echo "To test:"
echo "  ghostty --version"
echo "  chromium --version"
