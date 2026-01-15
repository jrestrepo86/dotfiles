#!/bin/bash
# Install Alacritty terminal and create desktop launcher
# Depends on: rust (03) for Alacritty
# Script: run_once_after_14_install-alacritty.sh
set -e

CARGO_HOME="$HOME/.local/share/cargo"
LOCAL_BIN="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor"

echo "========================================"
echo "Alacritty Terminal Installation"
echo "========================================"
echo ""

# Create directories
mkdir -p "$LOCAL_BIN"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR/scalable/apps"
mkdir -p "$ICON_DIR/128x128/apps"

# Track installation status
ALACRITTY_INSTALLED=false

##################################################
# ALACRITTY INSTALLATION (via cargo)
##################################################
echo "Installing Alacritty..."
echo "----------------------------"

# Check if already installed
if [ -f "$CARGO_HOME/bin/alacritty" ]; then
  echo "✓ Alacritty already installed"
  "$CARGO_HOME/bin/alacritty" --version
  ALACRITTY_INSTALLED=true
else
  # Check cargo
  if [ ! -f "$CARGO_HOME/bin/cargo" ]; then
    echo "⚠ Cargo not found - skipping Alacritty"
    echo "  Install Rust first: run_once_after_03_install-rust.sh"
  else
    echo "Installing Alacritty via cargo..."

    # Install build dependencies (if sudo available)
    DEPS="cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3"

    if command -v sudo &> /dev/null; then
      echo "Installing build dependencies (requires sudo)..."
      if sudo apt-get update -qq && sudo apt-get install -y -qq $DEPS 2> /dev/null; then
        echo "✓ Dependencies installed"
      else
        echo "⚠ Could not install all dependencies - build may fail"
      fi
    else
      echo "⚠ Sudo not available - assuming dependencies are installed"
    fi

    # Build Alacritty
    echo "Building Alacritty (this may take 5-10 minutes)..."
    if "$CARGO_HOME/bin/cargo" install alacritty; then
      echo "✓ Alacritty installed successfully!"
      "$CARGO_HOME/bin/alacritty" --version
      ALACRITTY_INSTALLED=true
    else
      echo "✗ Alacritty installation failed"
    fi
  fi
fi

echo ""

##################################################
# CREATE DESKTOP ENTRY
##################################################
if [ "$ALACRITTY_INSTALLED" = true ]; then
  echo "Creating desktop entry..."
  echo "----------------------------"

  cat > "$DESKTOP_DIR/alacritty.desktop" << EOF
[Desktop Entry]
Type=Application
TryExec=$CARGO_HOME/bin/alacritty
Exec=$CARGO_HOME/bin/alacritty
Icon=Alacritty
Terminal=false
Categories=System;TerminalEmulator;

Name=Alacritty
GenericName=Terminal
Comment=A fast, cross-platform, OpenGL terminal emulator
StartupWMClass=Alacritty
Actions=New;

[Desktop Action New]
Name=New Terminal
Exec=$CARGO_HOME/bin/alacritty
EOF

  echo "✓ Alacritty desktop entry created"

  # Download Alacritty icons
  echo "Downloading Alacritty icons..."

  if wget -4 "https://raw.githubusercontent.com/alacritty/alacritty/master/extra/logo/alacritty-term.svg" \
    -O "$ICON_DIR/scalable/apps/Alacritty.svg" 2> /dev/null; then
    echo "  ✓ SVG icon"
  else
    echo "  ⚠ Could not download SVG icon"
  fi

  if wget -4 "https://raw.githubusercontent.com/alacritty/alacritty/master/extra/logo/compat/alacritty-term.png" \
    -O "$ICON_DIR/128x128/apps/Alacritty.png" 2> /dev/null; then
    echo "  ✓ PNG icon"
  else
    echo "  ⚠ Could not download PNG icon"
  fi

  ##################################################
  # UPDATE DESKTOP DATABASE
  ##################################################
  echo ""
  echo "Updating desktop database..."

  if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR" 2> /dev/null || true
    echo "✓ Desktop database updated"
  fi

  if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$ICON_DIR" 2> /dev/null || true
    echo "✓ Icon cache updated"
  fi

  # Force menu update
  if command -v xdg-desktop-menu &> /dev/null; then
    xdg-desktop-menu forceupdate 2> /dev/null || true
  fi
fi

##################################################
# INSTALLATION SUMMARY
##################################################
echo ""
echo "========================================"
echo "Installation Summary"
echo "========================================"
echo ""

if [ "$ALACRITTY_INSTALLED" = true ]; then
  echo "✓ Alacritty"
  echo "  Binary: $CARGO_HOME/bin/alacritty"
  echo "  Config: ~/.config/alacritty/alacritty.toml"
  echo "  Run: alacritty"
else
  echo "✗ Alacritty - not installed"
  echo ""
  echo "To install manually:"
  echo "  cargo install alacritty"
fi

echo ""
echo "Installation complete!"
