#!/bin/bash
# Desktop applications installation via apt
# Only runs on desktop machines (skips neptuno/cluster)
set -e

##################################################
# CONFIGURATION
##################################################
APT_PACKAGES=(
  "okular"
  "zathura"
  "gdebi"
  "gimp"
  "gparted"
  "snapd"
  "openssh-client"
  "openssh-server"
  "openssh-sftp-server"
  "gedit"
  "flatpak"
  "tilda"
  "curl"
)

INSTALL_CHROME=true
INSTALL_BRAVE=true

##################################################
# HOSTNAME CHECK
##################################################
HOSTNAME=$(hostname)

if [[ "$HOSTNAME" == "neptuno" ]] || [[ "$HOSTNAME" == neptuno* ]] ||
  [[ "$HOSTNAME" == "jupiter" ]] || [[ "$HOSTNAME" == jupiter* ]]; then
  echo "Running on server (neptuno/jupiter) - skipping desktop packages"
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

echo "Installing ${#APT_PACKAGES[@]} packages..."
if sudo apt-get install -y -qq "${APT_PACKAGES[@]}" 2>&1 | grep -v "is already the newest version" | grep -v "^$"; then
  echo "✓ All packages installed successfully"
  INSTALLED=${#APT_PACKAGES[@]}
else
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
echo "Successfully installed: $INSTALLED"
echo "Failed: ${#FAILED[@]}"

if [ ${#FAILED[@]} -gt 0 ]; then
  echo ""
  echo "Failed packages:"
  printf '  ✗ %s\n' "${FAILED[@]}"
fi

echo ""
echo "Installation complete!"
