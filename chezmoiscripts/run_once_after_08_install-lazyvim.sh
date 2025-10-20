#!/bin/bash
# LazyVim dependencies - depends on pnpm (05), cargo (03), miniconda (01)
set -e

MINICONDA_DIR="$HOME/.local/share/miniconda"
PNPM_HOME="$HOME/.local/share/pnpm"
CARGO_HOME="$HOME/.local/share/cargo"
NVIM_CONFIG="$HOME/.config/nvim"

echo "Installing LazyVim dependencies..."
echo ""

# Track what's missing
MISSING_DEPS=()

# Check dependencies
if [ ! -f "$PNPM_HOME/pnpm" ]; then
  echo "Warning: pnpm not found at $PNPM_HOME"
  MISSING_DEPS+=("pnpm")
fi

if [ ! -f "$CARGO_HOME/bin/cargo" ]; then
  echo "Warning: cargo not found at $CARGO_HOME"
  MISSING_DEPS+=("cargo")
fi

if [ ! -f "$MINICONDA_DIR/bin/pip" ]; then
  echo "Warning: pip not found at $MINICONDA_DIR"
  MISSING_DEPS+=("pip")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
  echo ""
  echo "Missing dependencies: ${MISSING_DEPS[*]}"
  echo "Some LazyVim features may not work properly"
  echo ""
fi

# Install mermaid-cli via pnpm
if [ -f "$PNPM_HOME/pnpm" ]; then
  echo "Installing @mermaid-js/mermaid-cli..."
  if "$PNPM_HOME/pnpm" install -g @mermaid-js/mermaid-cli; then
    echo "✓ mermaid-cli installed"
  else
    echo "✗ mermaid-cli installation failed"
  fi

  echo "Installing neovim package via pnpm..."
  if "$PNPM_HOME/pnpm" install -g neovim; then
    echo "✓ neovim package installed"
  else
    echo "✗ neovim package installation failed"
  fi
else
  echo "Skipping pnpm packages (pnpm not available)"
fi

# Install fd-find via cargo
if [ -f "$CARGO_HOME/bin/cargo" ]; then
  echo "Installing fd-find..."
  if "$CARGO_HOME/bin/cargo" install fd-find; then
    echo "✓ fd-find installed"
  else
    echo "✗ fd-find installation failed"
  fi

  echo "Installing tree-sitter-cli (this may take a while)..."
  if "$CARGO_HOME/bin/cargo" install --locked tree-sitter-cli; then
    echo "✓ tree-sitter-cli installed"
  else
    echo "✗ tree-sitter-cli installation failed"
  fi
else
  echo "Skipping cargo packages (cargo not available)"
fi

# Install pynvim via pip
if [ -f "$MINICONDA_DIR/bin/pip" ]; then
  echo "Installing pynvim..."
  if "$MINICONDA_DIR/bin/pip" install pynvim; then
    echo "✓ pynvim installed"
  else
    echo "✗ pynvim installation failed"
  fi
else
  echo "Skipping python packages (pip not available)"
fi

# Install neovim gem via gem
if [ -f "$MINICONDA_DIR/bin/gem" ]; then
  echo "Installing neovim gem..."
  if "$MINICONDA_DIR/bin/gem" install neovim; then
    echo "✓ neovim gem installed"
  else
    echo "✗ neovim gem installation failed"
  fi
else
  echo "Skipping ruby packages (gem not available)"
fi

# Backup existing nvim config if it exists and is not managed by chezmoi
if [ -d "$NVIM_CONFIG" ] && [ ! -L "$NVIM_CONFIG" ]; then
  BACKUP_DIR="$NVIM_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
  echo ""
  echo "Backing up existing nvim config to $BACKUP_DIR"
  mv "$NVIM_CONFIG" "$BACKUP_DIR"
fi

echo ""
echo "LazyVim dependencies installation complete!"
echo ""
echo "Installation summary:"
echo "-------------------"
[ -f "$PNPM_HOME/mmdc" ] && echo "✓ mermaid-cli" || echo "✗ mermaid-cli"
[ -f "$CARGO_HOME/bin/fd" ] && echo "✓ fd-find" || echo "✗ fd-find"
[ -f "$CARGO_HOME/bin/tree-sitter" ] && echo "✓ tree-sitter-cli" || echo "✗ tree-sitter-cli"
"$MINICONDA_DIR/bin/pip" show pynvim &>/dev/null && echo "✓ pynvim" || echo "✗ pynvim"
"$MINICONDA_DIR/bin/gem" list neovim &>/dev/null && echo "✓ neovim gem" || echo "✗ neovim gem"
echo ""
echo "Next steps:"
echo "1. Your nvim config is managed by chezmoi at ~/.local/share/chezmoi/dot_config/nvim/"
echo "2. Launch nvim - LazyVim will install plugins on first run"
echo "3. Run :checkhealth in nvim to verify everything works"
