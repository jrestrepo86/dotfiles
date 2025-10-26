#!/bin/bash
# Desktop applications installation via apt
# Only runs on desktop machines (skips neptuno/cluster)
# To add more packages: just add them to the arrays below
set -e

##################################################
# CONFIGURATION
##################################################
# Standard apt packages - add or remove as needed
APT_PACKAGES=(
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
  "curl"                # HTTP tool
  # Add more packages below:
  # "firefox"
  # "thunderbird"
  # "inkscape"
  # "blender"
)

# Custom browser installations (need special setup)
INSTALL_CHROME=true # Set to false to skip
INSTALL_BRAVE=true  # Set to false to skip

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
# CHECK SUDO
##################################################
if ! command -v sudo &>/dev/null; then
  echo "Error: sudo not available"
  exit 1
fi

##################################################
# APT PACKAGES
##################################################
echo "Installing apt packages..."
echo ""

sudo apt-get update -qq

INSTALLED=0
FAILED=()

# Install all packages at once (faster than one-by-one)
echo "Installing ${#APT_PACKAGES[@]} packages..."
if sudo apt-get install -y -qq "${APT_PACKAGES[@]}" 2>&1 | grep -v "is already the newest version" | grep -v "^$"; then
  echo "✓ All packages installed successfully"
  INSTALLED=${#APT_PACKAGES[@]}
else
  # Some failed - check individually
  echo ""
  for pkg in "${APT_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $pkg "; then
      echo "  ✓ $pkg"
      INSTALLED=$((INSTALLED + 1))
    else
      echo "  ✗ $pkg"
      FAILED+=("$pkg")
    fi
  done
fi

echo ""

##################################################
# GOOGLE CHROME
##################################################
if [ "$INSTALL_CHROME" = true ]; then
  echo "→ Google Chrome"

  if command -v google-chrome &>/dev/null; then
    echo "  ✓ Already installed"
  else
    # Add repo and install
    if wget -q -O /tmp/chrome-key.gpg https://dl.google.com/linux/linux_signing_key.pub &&
      sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg /tmp/chrome-key.gpg &&
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null &&
      sudo apt-get update -qq &&
      sudo apt-get install -y -qq google-chrome-stable; then
      echo "  ✓ Installed successfully"
      INSTALLED=$((INSTALLED + 1))
    else
      echo "  ✗ Installation failed"
      FAILED+=("google-chrome")
    fi
    rm -f /tmp/chrome-key.gpg
  fi
  echo ""
fi

##################################################
# BRAVE BROWSER
##################################################
if [ "$INSTALL_BRAVE" = true ]; then
  echo "→ Brave Browser"

  if command -v brave-browser &>/dev/null; then
    echo "  ✓ Already installed"
  else
    # Add repo and install
    if sudo apt-get install -y -qq curl &&
      sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg &&
      echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null &&
      sudo apt-get update -qq &&
      sudo apt-get install -y -qq brave-browser; then
      echo "  ✓ Installed successfully"
      INSTALLED=$((INSTALLED + 1))
    else
      echo "  ✗ Installation failed"
      FAILED+=("brave-browser")
    fi
  fi
  echo ""
fi

##################################################
# SUMMARY
##################################################
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Packages processed: $((${#APT_PACKAGES[@]} + ($INSTALL_CHROME ? 1 : 0) + ($INSTALL_BRAVE ? 1 : 0)))"
echo "Successfully installed: $INSTALLED"
echo "Failed: ${#FAILED[@]}"

if [ ${#FAILED[@]} -gt 0 ]; then
  echo ""
  echo "Failed packages:"
  printf '  ✗ %s\n' "${FAILED[@]}"
  echo ""
  echo "Retry manually: sudo apt-get install <package>"
fi

echo ""
echo "Installed applications: $INSTALLED packages"
echo ""
echo "Check installed apps:"
echo "  dpkg -l | grep -E '(okular|zathura|gimp|vlc|gedit)'"
[ "$INSTALL_CHROME" = true ] && echo "  google-chrome --version"
[ "$INSTALL_BRAVE" = true ] && echo "  brave-browser --version"

echo ""
echo "Installation complete!"
echo ""
echo "Note: Some applications may require logout/login to appear in menu"
