#!/bin/bash
# Install backup terminals (Alacritty + Kitty) and create desktop launchers
# Depends on: rust (03) for Alacritty
# Kitty: Uses official binary installer (no sudo required)
set -e

CARGO_HOME="$HOME/.local/share/cargo"
KITTY_DIR="$HOME/.local/share/kitty"
LOCAL_BIN="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor"

echo "========================================"
echo "Backup Terminals Installation"
echo "========================================"
echo ""

# Create directories
mkdir -p "$LOCAL_BIN"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR/scalable/apps"
mkdir -p "$ICON_DIR/128x128/apps"

# Track installation status
ALACRITTY_INSTALLED=false
KITTY_INSTALLED=false

##################################################
# ALACRITTY INSTALLATION (via cargo)
##################################################
echo "1. Installing Alacritty..."
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
# KITTY INSTALLATION (official binary installer)
##################################################
echo "2. Installing Kitty..."
echo "----------------------------"

# Check if already installed
if [ -f "$LOCAL_BIN/kitty" ] || [ -f "$KITTY_DIR/bin/kitty" ]; then
  echo "✓ Kitty already installed"
  if [ -f "$KITTY_DIR/bin/kitty" ]; then
    "$KITTY_DIR/bin/kitty" --version
  else
    "$LOCAL_BIN/kitty" --version
  fi
  KITTY_INSTALLED=true
elif command -v kitty &> /dev/null; then
  echo "✓ Kitty already installed (system)"
  kitty --version
  KITTY_INSTALLED=true
else
  echo "Installing Kitty using official installer..."

  # Create installation directory
  mkdir -p "$KITTY_DIR"

  # Download and run the official installer
  # The installer supports custom destination via environment variable
  if curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
    dest="$KITTY_DIR" launch=n; then

    # Create symlinks to local bin
    if [ -f "$KITTY_DIR/bin/kitty" ]; then
      ln -sf "$KITTY_DIR/bin/kitty" "$LOCAL_BIN/kitty"
      ln -sf "$KITTY_DIR/bin/kitten" "$LOCAL_BIN/kitten"

      echo "✓ Kitty installed successfully!"
      "$KITTY_DIR/bin/kitty" --version
      KITTY_INSTALLED=true

      # Copy terminfo for SSH compatibility
      mkdir -p "$HOME/.terminfo/x"
      if [ -f "$KITTY_DIR/share/terminfo/x/xterm-kitty" ]; then
        cp "$KITTY_DIR/share/terminfo/x/xterm-kitty" "$HOME/.terminfo/x/"
        echo "✓ Kitty terminfo installed for SSH compatibility"
      fi
    else
      echo "✗ Kitty binary not found after installation"
    fi
  else
    echo "✗ Kitty installation failed"
    echo ""
    echo "Alternative manual installation:"
    echo "  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin dest=$KITTY_DIR"
  fi
fi

echo ""

##################################################
# CREATE DESKTOP ENTRIES
##################################################
if [ "$ALACRITTY_INSTALLED" = true ] || [ "$KITTY_INSTALLED" = true ]; then
  echo "3. Creating desktop entries..."
  echo "----------------------------"

  ##################################################
  # ALACRITTY DESKTOP ENTRY
  ##################################################
  if [ "$ALACRITTY_INSTALLED" = true ]; then
    echo "Creating Alacritty desktop entry..."

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

    if wget -q "https://raw.githubusercontent.com/alacritty/alacritty/master/extra/logo/alacritty-term.svg" \
      -O "$ICON_DIR/scalable/apps/Alacritty.svg" 2> /dev/null; then
      echo "  ✓ SVG icon"
    else
      echo "  ⚠ Could not download SVG icon"
    fi

    if wget -q "https://raw.githubusercontent.com/alacritty/alacritty/master/extra/logo/compat/alacritty-term.png" \
      -O "$ICON_DIR/128x128/apps/Alacritty.png" 2> /dev/null; then
      echo "  ✓ PNG icon"
    else
      echo "  ⚠ Could not download PNG icon"
    fi
  fi

  ##################################################
  # KITTY DESKTOP ENTRY
  ##################################################
  if [ "$KITTY_INSTALLED" = true ]; then
    echo "Creating Kitty desktop entry..."

    # Find kitty binary location
    if [ -f "$KITTY_DIR/bin/kitty" ]; then
      KITTY_BIN="$KITTY_DIR/bin/kitty"
      KITTY_ICON="$KITTY_DIR/share/icons/hicolor/256x256/apps/kitty.png"
    elif [ -f "$LOCAL_BIN/kitty" ]; then
      KITTY_BIN="$LOCAL_BIN/kitty"
      KITTY_ICON="kitty"
    else
      KITTY_BIN="kitty"
      KITTY_ICON="kitty"
    fi

    cat > "$DESKTOP_DIR/kitty.desktop" << EOF
[Desktop Entry]
Type=Application
TryExec=$KITTY_BIN
Exec=$KITTY_BIN
Icon=$KITTY_ICON
Terminal=false
Categories=System;TerminalEmulator;

Name=Kitty
GenericName=Terminal
Comment=The fast, feature-rich, GPU based terminal emulator
StartupWMClass=kitty
Actions=New;

[Desktop Action New]
Name=New Terminal
Exec=$KITTY_BIN
EOF

    echo "✓ Kitty desktop entry created"

    # Copy kitty icons to standard location if installed locally
    if [ -d "$KITTY_DIR/share/icons" ]; then
      echo "Copying Kitty icons..."
      cp -r "$KITTY_DIR/share/icons/hicolor/"* "$ICON_DIR/" 2> /dev/null || true
      echo "  ✓ Icons copied"
    fi
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
fi

echo ""

if [ "$KITTY_INSTALLED" = true ]; then
  echo "✓ Kitty"
  if [ -f "$KITTY_DIR/bin/kitty" ]; then
    echo "  Binary: $KITTY_DIR/bin/kitty"
    echo "  Symlink: $LOCAL_BIN/kitty"
  else
    echo "  Binary: $(which kitty 2> /dev/null || echo 'unknown')"
  fi
  echo "  Config: ~/.config/kitty/kitty.conf"
  echo "  Run: kitty"
else
  echo "✗ Kitty - not installed"
fi

echo ""

if [ "$ALACRITTY_INSTALLED" = true ] || [ "$KITTY_INSTALLED" = true ]; then
  echo "Desktop launchers created at:"
  echo "  $DESKTOP_DIR/"
  echo ""
  echo "Both terminals should now appear in your application menu."
  echo "If they don't show up immediately:"
  echo "  - Log out and back in"
  echo "  - Or restart your desktop environment"
else
  echo "No terminals were installed."
  echo ""
  echo "To install manually:"
  echo "  Alacritty: cargo install alacritty"
  echo "  Kitty: curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin dest=~/.local/share/kitty"
fi

echo ""
echo "Installation complete!"
