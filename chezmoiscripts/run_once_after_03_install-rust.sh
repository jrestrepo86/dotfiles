#!/bin/bash
# Save this as: .chezmoiscripts/run_once_install-rust.sh

set -e

export CARGO_HOME="$HOME/.local/share/cargo"
export RUSTUP_HOME="$HOME/.local/share/rustup"

# Check if rustup is already installed
if [ -f "$CARGO_HOME/bin/rustup" ]; then
  echo "Rust already installed at $RUSTUP_HOME"
  exit 0
fi

echo "Installing Rust with custom directories..."
echo "CARGO_HOME: $CARGO_HOME"
echo "RUSTUP_HOME: $RUSTUP_HOME"

# Create directories
mkdir -p "$CARGO_HOME"
mkdir -p "$RUSTUP_HOME"

# Download and run rustup installer
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

echo "Rust installed successfully!"
echo ""
echo "Add these lines to your .bashrc:"
echo '  export CARGO_HOME="$HOME/.local/share/cargo"'
echo '  export RUSTUP_HOME="$HOME/.local/share/rustup"'
echo '  export PATH="$CARGO_HOME/bin:$PATH"'
