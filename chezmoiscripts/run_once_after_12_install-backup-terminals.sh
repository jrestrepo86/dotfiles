#!/bin/bash
# Install backup terminals (Alacritty + Kitty) and create desktop launchers
# Depends on: rust (03), miniconda (01)
set -e

CARGO_HOME="$HOME/.local/share/cargo"
MINICONDA_DIR="$HOME/.local/share/miniconda"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor"

echo "========================================"
echo "Backup Terminals Installation"
echo "========================================"
echo ""

# Track installation status
ALACRITTY_INSTALLED=false
KITTY_INSTALLED=false

##################################################
# ALACRITTY INSTALLATION
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
    echo "  Install Rust first: chezmoiscripts/run_once_after_03_install-rust.sh"
  else
    echo "Installing Alacritty via cargo..."

    # Install build dependencies
    DEPS="cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3"

    if command -v sudo &>/dev/null; then
      echo "Installing build dependencies (requires sudo)..."
      if sudo apt-get update && sudo apt-get install -y $DEPS; then
        echo "✓ Dependencies installed"

        # Build Alacritty
        echo "Building Alacritty (this may take 5-10 minutes)..."
        if "$CARGO_HOME/bin/cargo" install alacritty; then
          echo "✓ Alacritty installed successfully!"
          "$CARGO_HOME/bin/alacritty" --version
          ALACRITTY_INSTALLED=true
        else
          echo "✗ Alacritty installation failed"
        fi
      else
        echo "✗ Could not install dependencies"
      fi
    else
      echo "⚠ Sudo not available - cannot install dependencies"
      echo "  Install manually: $DEPS"
    fi
  fi
fi

echo ""

##################################################
# KITTY INSTALLATION
##################################################
echo "2. Installing Kitty..."
echo "----------------------------"

# Check if already installed
if [ -f "$MINICONDA_DIR/bin/kitty" ]; then
  echo "✓ Kitty already installed"
  "$MINICONDA_DIR/bin/kitty" --version
  KITTY_INSTALLED=true
elif command -v kitty &>/dev/null; then
  echo "✓ Kitty already installed (system)"
  kitty --version
  KITTY_INSTALLED=true
else
  # Check conda
  if [ ! -f "$MINICONDA_DIR/bin/conda" ]; then
    echo "⚠ Conda not found - skipping Kitty"
    echo "  Install Miniconda first: chezmoiscripts/run_once_after_01_install-miniconda.sh"
  else
    echo "Installing Kitty via conda..."

    if "$MINICONDA_DIR/bin/conda" install -y -c conda-forge kitty; then
      echo "✓ Kitty installed successfully!"
      "$MINICONDA_DIR/bin/kitty" --version
      KITTY_INSTALLED=true
    else
      echo "✗ Kitty installation failed"
    fi
  fi
fi

echo ""

##################################################
# CREATE DESKTOP ENTRIES
##################################################
if [ "$ALACRITTY_INSTALLED" = true ] || [ "$KITTY_INSTALLED" = true ]; then
  echo "3. Creating desktop entries..."
  echo "----------------------------"

  # Create directories
  mkdir -p "$DESKTOP_DIR"
  mkdir -p "$ICON_DIR/scalable/apps"
  mkdir -p "$ICON_DIR/128x128/apps"

  ##################################################
  # ALACRITTY DESKTOP ENTRY
  ##################################################
  if [ "$ALACRITTY_INSTALLED" = true ]; then
    echo "Creating Alacritty desktop entry..."

    cat >"$DESKTOP_DIR/alacritty.desktop" <<'EOF'
[Desktop Entry]
Type=Application
TryExec=alacritty
Exec=alacritty
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
Exec=alacritty
EOF

    echo "✓ Alacritty desktop entry created"

    # Download Alacritty icons
    echo "Downloading Alacritty icons..."

    if wget -q "https://raw.githubusercontent.com/alacritty/alacritty/master/extra/logo/alacritty-term.svg" \
      -O "$ICON_DIR/scalable/apps/Alacritty.svg" 2>/dev/null; then
      echo "  ✓ SVG icon"
    else
      echo "  ⚠ Could not download SVG icon"
    fi

    if wget -q "https://raw.githubusercontent.com/alacritty/alacritty/master/extra/logo/compat/alacritty-term.png" \
      -O "$ICON_DIR/128x128/apps/Alacritty.png" 2>/dev/null; then
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
    if [ -f "$MINICONDA_DIR/bin/kitty" ]; then
      KITTY_BIN="$MINICONDA_DIR/bin/kitty"
    else
      KITTY_BIN="kitty"
    fi

    cat >"$DESKTOP_DIR/kitty.desktop" <<EOF
[Desktop Entry]
Type=Application
TryExec=$KITTY_BIN
Exec=$KITTY_BIN
Icon=kitty
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

    # Download Kitty icon
    echo "Downloading Kitty icon..."

    if wget -q "https://raw.githubusercontent.com/kovidgoyal/kitty/master/logo/kitty.svg" \
      -O "$ICON_DIR/scalable/apps/kitty.svg" 2>/dev/null; then
      echo "  ✓ SVG icon"
    else
      echo "  ⚠ Could not download SVG icon"
    fi

    if wget -q "https://raw.githubusercontent.com/kovidgoyal/kitty/master/logo/kitty-128.png" \
      -O "$ICON_DIR/128x128/apps/kitty.png" 2>/dev/null; then
      echo "  ✓ PNG icon"
    else
      echo "  ⚠ Could not download PNG icon"
    fi
  fi

  ##################################################
  # UPDATE DESKTOP DATABASE
  ##################################################
  echo ""
  echo "Updating desktop database..."

  if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
    echo "✓ Desktop database updated"
  fi

  if command -v gtk-update-icon-cache &>/dev/null; then
    gtk-update-icon-cache -f -t "$ICON_DIR" 2>/dev/null || true
    echo "✓ Icon cache updated"
  fi

  # Force menu update
  if command -v xdg-desktop-menu &>/dev/null; then
    xdg-desktop-menu forceupdate 2>/dev/null || true
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
  if [ -f "$MINICONDA_DIR/bin/kitty" ]; then
    echo "  Binary: $MINICONDA_DIR/bin/kitty"
  else
    echo "  Binary: $(which kitty)"
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
  echo "  Kitty: conda install -c conda-forge kitty"
fi

echo ""
echo "Installation complete!"
