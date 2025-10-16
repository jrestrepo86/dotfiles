#!/bin/bash
# Save this as: .chezmoiscripts/run_once_after_install-lazyvim.sh

set -e

MINICONDA_DIR="$HOME/.local/share/miniconda"
PNPM_HOME="$HOME/.local/share/pnpm"
CARGO_HOME="$HOME/.local/share/cargo"
NVIM_CONFIG="$HOME/.config/nvim"

echo "Installing LazyVim dependencies..."

# 1. Install mermaid-cli via pnpm
if [ -f "$PNPM_HOME/pnpm" ]; then
  echo "Installing @mermaid-js/mermaid-cli..."
  "$PNPM_HOME/pnpm" install -g @mermaid-js/mermaid-cli
else
  echo "Warning: pnpm not found, skipping mermaid-cli installation"
fi

# 2. Install neovim package via pnpm
if [ -f "$PNPM_HOME/pnpm" ]; then
  echo "Installing neovim package via pnpm..."
  "$PNPM_HOME/pnpm" install -g neovim
else
  echo "Warning: pnpm not found, skipping neovim package installation"
fi

# 3. Install pynvim via pip
if [ -f "$MINICONDA_DIR/bin/pip" ]; then
  echo "Installing pynvim..."
  "$MINICONDA_DIR/bin/pip" install pynvim
else
  echo "Warning: pip not found, skipping pynvim installation"
fi

# 4 & 6. Install neovim gem via gem (combined, no sudo needed)
if [ -f "$MINICONDA_DIR/bin/gem" ]; then
  echo "Installing neovim gem..."
  "$MINICONDA_DIR/bin/gem" install neovim
else
  echo "Warning: gem not found, skipping neovim gem installation"
fi

# 5. Install tree-sitter-cli via cargo
if [ -f "$CARGO_HOME/bin/cargo" ]; then
  echo "Installing tree-sitter-cli (this may take a while)..."
  "$CARGO_HOME/bin/cargo" install --locked tree-sitter-cli
else
  echo "Warning: cargo not found, skipping tree-sitter-cli installation"
fi

# 7. Install LazyVim
# Note: Your nvim config should be managed by chezmoi in dot_config/nvim/
# This will be handled by chezmoi apply, which will copy your config

# 8. Backup existing nvim config if it exists and is not managed by chezmoi
if [ -d "$NVIM_CONFIG" ] && [ ! -L "$NVIM_CONFIG" ]; then
  echo "Backing up existing nvim config..."
  mv "$NVIM_CONFIG" "$NVIM_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
fi

echo "LazyVim dependencies installed successfully!"
echo ""
echo "Next steps:"
echo "1. Make sure your nvim config is in chezmoi: ~/.local/share/chezmoi/dot_config/nvim/"
echo "2. Run 'chezmoi apply' to deploy your nvim config"
echo "3. Launch nvim - LazyVim will install plugins on first run"
