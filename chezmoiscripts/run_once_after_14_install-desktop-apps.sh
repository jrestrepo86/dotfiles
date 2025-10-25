#!/bin/bash
# Desktop applications installation - System packages and web browsers
# Only runs on machines that are NOT neptuno (cluster/server)
#
# APT packages:
#   - System: okular, zathura, gdebi, gimp, gparted, gedit, tilda, vlc
#   - Network: openssh-client, openssh-server, openssh-sftp-server, curl
#   - Package managers: snapd, flatpak
#
# Custom installs: Google Chrome, Brave Browser
#
# Note: Snap packages are installed by: run_once_after_15_install-snap-packages.sh
#       Obsidian is installed by: run_once_after_16_install-obsidian.sh
set -e

SYSTEM_PACKAGES=(
  "okular"              # KDE PDF viewer
  "zathura"             # Lightweight PDF viewer
  "gdebi"               # .deb package installer
  "gimp"                # Image editor
  "gparted"             # Partition editor
  "snapd"               # Snap package manager
  "openssh-client"      # SSH client
  "openssh-server"      # SSH server
  "openssh-sftp-server" # SFTP server
  "gedit"               # Text editor
  "flatpak"             # Flatpak package manager
  "tilda"               # Drop-down terminal
  "vlc"                 # Media player
  "curl"                # Command line tool for transferring data
)

HOSTNAME=$(hostname)

echo "=========================================="
echo "Desktop Applications Installer"
echo "=========================================="
echo "Current hostname: $HOSTNAME"
echo ""

# Check if running on neptuno
if [[ "$HOSTNAME" == "neptuno" ]] || [[ "$HOSTNAME" == neptuno* ]]; then
  echo "⚠ Running on neptuno (cluster/server)"
  echo "Skipping desktop applications installation"
  echo ""
  echo "This script only runs on desktop machines."
  exit 0
fi

echo "✓ Running on desktop machine"
echo "Proceeding with installation..."
echo ""

# Check for sudo
if ! command -v sudo &>/dev/null; then
  echo "Error: sudo not available"
  echo "This script requires sudo to install packages"
  exit 1
fi

# Track installation status
TOTAL_APPS=0
INSTALLED_APPS=0
FAILED_APPS=()

##################################################
# SYSTEM PACKAGES (via apt)
##################################################
echo "=========================================="
echo "1. Installing System Packages via apt"
echo "=========================================="
echo ""

echo "Updating apt cache..."
if ! sudo apt-get update; then
  echo "Warning: apt update failed, continuing anyway..."
fi

echo ""
echo "Installing all packages via apt in one command:"
printf '  - %s\n' "${SYSTEM_PACKAGES[@]}"
echo ""

# Install all packages at once
if sudo apt-get install -y "${SYSTEM_PACKAGES[@]}"; then
  echo "✓ All apt packages installed successfully"
  INSTALLED_APPS=$((INSTALLED_APPS + ${#SYSTEM_PACKAGES[@]}))
else
  echo "⚠ Some packages may have failed to install"
  echo "Checking which packages were installed..."
  echo ""

  # Check each package individually
  for package in "${SYSTEM_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
      echo "  ✓ $package"
      INSTALLED_APPS=$((INSTALLED_APPS + 1))
    else
      echo "  ✗ $package"
      FAILED_APPS+=("$package")
    fi
  done
fi

TOTAL_APPS=$((TOTAL_APPS + ${#SYSTEM_PACKAGES[@]}))
echo ""

##################################################
# GOOGLE CHROME
##################################################
echo "=========================================="
echo "2. Installing Google Chrome"
echo "=========================================="
echo ""
TOTAL_APPS=$((TOTAL_APPS + 1))

if command -v google-chrome &>/dev/null; then
  echo "✓ Google Chrome already installed"
  google-chrome --version
  INSTALLED_APPS=$((INSTALLED_APPS + 1))
else
  echo "Installing Google Chrome..."

  # Download Google's signing key
  if wget -q -O /tmp/google-chrome-key.gpg https://dl.google.com/linux/linux_signing_key.pub; then
    # Add the key
    if sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg /tmp/google-chrome-key.gpg; then

      # Add Google Chrome repository
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" |
        sudo tee /etc/apt/sources.list.d/google-chrome.list

      # Update and install
      if sudo apt-get update && sudo apt-get install -y google-chrome-stable; then
        echo "✓ Google Chrome installed successfully"
        INSTALLED_APPS=$((INSTALLED_APPS + 1))
      else
        echo "✗ Failed to install Google Chrome"
        FAILED_APPS+=("google-chrome")
      fi
    else
      echo "✗ Failed to add Google Chrome GPG key"
      FAILED_APPS+=("google-chrome")
    fi

    rm -f /tmp/google-chrome-key.gpg
  else
    echo "✗ Failed to download Google Chrome signing key"
    FAILED_APPS+=("google-chrome")
  fi
fi
echo ""

##################################################
# BRAVE BROWSER
##################################################
echo "=========================================="
echo "3. Installing Brave Browser"
echo "=========================================="
echo ""
TOTAL_APPS=$((TOTAL_APPS + 1))

if command -v brave-browser &>/dev/null; then
  echo "✓ Brave Browser already installed"
  brave-browser --version
  INSTALLED_APPS=$((INSTALLED_APPS + 1))
else
  echo "Installing Brave Browser..."

  # Install prerequisites
  if sudo apt-get install -y curl; then
    # Add Brave's GPG key
    if sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
      https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg; then

      # Add Brave repository
      echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" |
        sudo tee /etc/apt/sources.list.d/brave-browser-release.list

      # Update and install
      if sudo apt-get update && sudo apt-get install -y brave-browser; then
        echo "✓ Brave Browser installed successfully"
        INSTALLED_APPS=$((INSTALLED_APPS + 1))
      else
        echo "✗ Failed to install Brave Browser"
        FAILED_APPS+=("brave-browser")
      fi
    else
      echo "✗ Failed to add Brave GPG key"
      FAILED_APPS+=("brave-browser")
    fi
  else
    echo "✗ Failed to install curl (needed for Brave)"
    FAILED_APPS+=("brave-browser")
  fi
fi
echo ""

##################################################
# INSTALLATION SUMMARY
##################################################
echo "=========================================="
echo "Installation Summary"
echo "=========================================="
echo ""
echo "Total applications: $TOTAL_APPS"
echo "Successfully installed: $INSTALLED_APPS"
echo "Failed: $((TOTAL_APPS - INSTALLED_APPS))"

if [ ${#FAILED_APPS[@]} -gt 0 ]; then
  echo ""
  echo "Failed installations:"
  printf '  ✗ %s\n' "${FAILED_APPS[@]}"
  echo ""
  echo "You can try installing failed packages manually:"
  echo "  sudo apt-get install <package-name>"
  echo "  Or follow instructions for Google Chrome: https://www.google.com/chrome/"
  echo "  Or follow instructions for Brave: https://brave.com/linux/"
fi

echo ""
echo "=========================================="
echo "Installed Applications"
echo "=========================================="
echo ""

# List installed applications
echo "System Tools:"
[ -f /usr/bin/okular ] && echo "  ✓ Okular:         okular <file.pdf>" || echo "  ✗ Okular"
[ -f /usr/bin/zathura ] && echo "  ✓ Zathura:        zathura <file.pdf>" || echo "  ✗ Zathura"
[ -f /usr/bin/gdebi-gtk ] && echo "  ✓ Gdebi:          gdebi-gtk <file.deb>" || echo "  ✗ Gdebi"
[ -f /usr/bin/gimp ] && echo "  ✓ GIMP:           gimp" || echo "  ✗ GIMP"
[ -f /usr/bin/gparted ] && echo "  ✓ GParted:        sudo gparted" || echo "  ✗ GParted"
[ -f /usr/bin/gedit ] && echo "  ✓ Gedit:          gedit" || echo "  ✗ Gedit"
[ -f /usr/bin/tilda ] && echo "  ✓ Tilda:          tilda" || echo "  ✗ Tilda"
[ -f /usr/bin/vlc ] && echo "  ✓ VLC:            vlc" || echo "  ✗ VLC"

echo ""
echo "Network Tools:"
command -v ssh &>/dev/null && echo "  ✓ SSH Client:     ssh" || echo "  ✗ SSH Client"
systemctl is-active --quiet ssh 2>/dev/null && echo "  ✓ SSH Server:     (active)" || echo "  ✓ SSH Server:     (installed, inactive)"
[ -f /usr/bin/curl ] && echo "  ✓ Curl:           curl" || echo "  ✗ Curl"

echo ""
echo "Package Managers:"
command -v snap &>/dev/null && echo "  ✓ Snap:           snap" || echo "  ✗ Snap"
command -v flatpak &>/dev/null && echo "  ✓ Flatpak:        flatpak" || echo "  ✗ Flatpak"

echo ""
echo "Web Browsers:"
command -v google-chrome &>/dev/null && echo "  ✓ Google Chrome:  google-chrome" || echo "  ✗ Google Chrome"
command -v brave-browser &>/dev/null && echo "  ✓ Brave:          brave-browser" || echo "  ✗ Brave"

echo ""
echo "Installation complete!"
echo ""
echo "Additional software available via:"
echo "  - Snap packages:  run_once_after_15_install-snap-packages.sh"
echo "  - Obsidian:       run_once_after_16_install-obsidian.sh"
echo ""
echo "Some applications may require logging out and back in"
echo "to appear in your application menu."
