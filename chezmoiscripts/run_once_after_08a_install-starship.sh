#!/bin/bash
# Starship installation via cargo - depends on rust (03)
# Installs latest version (conda-forge has outdated 1.6.3 from 2022)
set -e

CARGO_HOME="$HOME/.local/share/cargo"
CARGO_BIN="$CARGO_HOME/bin/cargo"
STARSHIP_BIN="$CARGO_HOME/bin/starship"

# Check if Rust/Cargo is installed
if [ ! -f "$CARGO_BIN" ]; then
  echo "Error: Cargo not found at $CARGO_HOME"
  echo "The Rust installation script should have run first"
  exit 1
fi

# Check if starship is already installed and up-to-date
if [ -f "$STARSHIP_BIN" ]; then
  CURRENT_VERSION=$("$STARSHIP_BIN" --version | awk '{print $2}')
  echo "Starship already installed: v$CURRENT_VERSION"

  # Check if it's the old conda version (1.6.3)
  if [[ "$CURRENT_VERSION" == "1.6.3" ]]; then
    echo "Detected old conda version - will upgrade via cargo"
  else
    echo "Starship is up to date"
    exit 0
  fi
fi

echo "Installing latest Starship via cargo..."
echo "This may take 2-3 minutes to compile..."

# Install starship (--locked ensures reproducible builds)
if "$CARGO_BIN" install starship --locked; then
  echo ""
  echo "✓ Starship installed successfully!"
  echo "Version: $("$STARSHIP_BIN" --version)"
else
  echo "Error: Starship installation via cargo failed"
  exit 1
fi

echo ""
echo "Starship installation complete!"
echo "Binary location: $STARSHIP_BIN"
echo ""
echo "Your .bash_profile already includes cargo/bin in PATH"
echo "Configuration will be handled by the next script"
