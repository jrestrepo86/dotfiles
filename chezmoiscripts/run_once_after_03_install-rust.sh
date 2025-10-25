#!/bin/bash
# Rust installation - independent of other tools
set -e

export CARGO_HOME="$HOME/.local/share/cargo"
export RUSTUP_HOME="$HOME/.local/share/rustup"

# Check if rustup is already installed
if [ -f "$CARGO_HOME/bin/rustup" ]; then
  echo "Rust already installed at $RUSTUP_HOME"
  echo "Current version: $("$CARGO_HOME/bin/rustc" --version)"
  exit 0
fi

echo "Installing Rust with custom directories..."
echo "CARGO_HOME: $CARGO_HOME"
echo "RUSTUP_HOME: $RUSTUP_HOME"

# Create directories
mkdir -p "$CARGO_HOME"
mkdir -p "$RUSTUP_HOME"

# Download and run rustup installer
echo "Downloading rustup installer..."
if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path; then
  echo "Error: Rust installation failed"
  exit 1
fi

# Verify installation
if [ -f "$CARGO_HOME/bin/cargo" ]; then
  echo "Rust installed successfully!"
  echo ""
  echo "Rust version: $("$CARGO_HOME/bin/rustc" --version)"
  echo "Cargo version: $("$CARGO_HOME/bin/cargo" --version)"
  echo ""
  echo "Your .bash_profile should already have the correct PATH configuration:"
  echo '  export CARGO_HOME="$HOME/.local/share/cargo"'
  echo '  export RUSTUP_HOME="$HOME/.local/share/rustup"'
  echo '  export PATH="$CARGO_HOME/bin:$PATH"'
else
  echo "Error: Rust installation completed but cargo binary not found"
  exit 1
fi
