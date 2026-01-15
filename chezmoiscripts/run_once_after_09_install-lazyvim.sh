#!/bin/bash
# LazyVim dependencies - depends on pnpm (05), cargo (03), miniconda (01), nvm (02b)
set -e

MINICONDA_DIR="$HOME/.local/share/miniconda"
PNPM_HOME="$HOME/.local/share/pnpm"
CARGO_HOME="$HOME/.local/share/cargo"
NVM_DIR="$HOME/.local/share/nvm"
RBENV_ROOT="$HOME/.local/share/rbenv"
NVIM_BIN="$HOME/.local/bin/nvim"

echo "========================================"
echo "LazyVim Dependencies Installation"
echo "========================================"
echo ""

# Check if neovim is installed
if [ ! -f "$NVIM_BIN" ]; then
  echo "Warning: Neovim not found at $NVIM_BIN"
  echo "Make sure neovim installation script ran successfully"
fi

# Track what's missing
MISSING_DEPS=()
INSTALLED_DEPS=()

##################################################
# CHECK AVAILABLE PACKAGE MANAGERS
##################################################
echo "Checking available package managers..."
echo ""

# Check pnpm
PNPM_BIN=""
if [ -f "$PNPM_HOME/pnpm" ]; then
  PNPM_BIN="$PNPM_HOME/pnpm"
  echo "✓ pnpm found at $PNPM_BIN"
else
  echo "✗ pnpm not found"
  MISSING_DEPS+=("pnpm")
fi

# Check cargo
CARGO_BIN=""
if [ -f "$CARGO_HOME/bin/cargo" ]; then
  CARGO_BIN="$CARGO_HOME/bin/cargo"
  echo "✓ cargo found at $CARGO_BIN"
else
  echo "✗ cargo not found"
  MISSING_DEPS+=("cargo")
fi

# Check pip (from conda)
PIP_BIN=""
if [ -f "$MINICONDA_DIR/bin/pip" ]; then
  PIP_BIN="$MINICONDA_DIR/bin/pip"
  echo "✓ pip found at $PIP_BIN"
else
  echo "✗ pip not found"
  MISSING_DEPS+=("pip")
fi

# Check node/npm (from nvm)
NODE_BIN=""
NPM_BIN=""
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # Load nvm
  export NVM_DIR="$NVM_DIR"
  # shellcheck disable=SC1091
  \. "$NVM_DIR/nvm.sh"

  if command -v node &>/dev/null; then
    NODE_BIN=$(command -v node)
    echo "✓ node found at $NODE_BIN ($(node --version))"
  else
    echo "✗ node not found (nvm loaded but no node installed)"
    MISSING_DEPS+=("node")
  fi

  if command -v npm &>/dev/null; then
    NPM_BIN=$(command -v npm)
    echo "✓ npm found at $NPM_BIN"
  else
    echo "✗ npm not found"
    MISSING_DEPS+=("npm")
  fi
else
  echo "✗ nvm not found at $NVM_DIR"
  MISSING_DEPS+=("nvm")
fi

# Check gem (from rbenv)
GEM_BIN=""
if [ -f "$RBENV_ROOT/shims/gem" ]; then
  GEM_BIN="$RBENV_ROOT/shims/gem"
  echo "✓ gem found at $GEM_BIN"
elif [ -f "$RBENV_ROOT/versions/3.2.6/bin/gem" ]; then
  GEM_BIN="$RBENV_ROOT/versions/3.2.6/bin/gem"
  echo "✓ gem found at $GEM_BIN"
else
  echo "⚠ gem not found (ruby may not be installed)"
fi

echo ""

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
  echo "⚠ Missing package managers: ${MISSING_DEPS[*]}"
  echo "Some LazyVim features may not work properly"
  echo ""
fi

##################################################
# INSTALL PNPM PACKAGES
##################################################
echo "Installing pnpm packages..."
echo "----------------------------"

if [ -n "$PNPM_BIN" ]; then
  # neovim node package
  echo "→ neovim (node provider)"
  if "$PNPM_BIN" install -g neovim 2>/dev/null; then
    echo "  ✓ installed"
    INSTALLED_DEPS+=("neovim-node")
  else
    echo "  ✗ failed"
  fi
elif [ -n "$NPM_BIN" ]; then
  echo "Using npm as fallback..."

  echo "→ neovim (node provider)"
  if "$NPM_BIN" install -g neovim 2>/dev/null; then
    echo "  ✓ installed via npm"
    INSTALLED_DEPS+=("neovim-node")
  else
    echo "  ✗ failed"
  fi
else
  echo "⚠ Skipping pnpm/npm packages (no package manager available)"
fi

echo ""

##################################################
# INSTALL CARGO PACKAGES
##################################################
echo "Installing cargo packages..."
echo "----------------------------"

if [ -n "$CARGO_BIN" ]; then
  # fd-find for telescope
  echo "→ fd-find"
  if [ -f "$CARGO_HOME/bin/fd" ]; then
    echo "  ✓ already installed"
    INSTALLED_DEPS+=("fd-find")
  elif "$CARGO_BIN" install fd-find 2>/dev/null; then
    echo "  ✓ installed"
    INSTALLED_DEPS+=("fd-find")
  else
    echo "  ✗ failed"
  fi

  # tree-sitter-cli for parser management
  echo "→ tree-sitter-cli (this may take a while)..."
  if [ -f "$CARGO_HOME/bin/tree-sitter" ]; then
    echo "  ✓ already installed"
    INSTALLED_DEPS+=("tree-sitter-cli")
  elif "$CARGO_BIN" install --locked tree-sitter-cli 2>/dev/null; then
    echo "  ✓ installed"
    INSTALLED_DEPS+=("tree-sitter-cli")
  else
    echo "  ✗ failed"
  fi

  # ripgrep for telescope live_grep
  echo "→ ripgrep"
  if [ -f "$CARGO_HOME/bin/rg" ]; then
    echo "  ✓ already installed"
    INSTALLED_DEPS+=("ripgrep")
  elif "$CARGO_BIN" install ripgrep 2>/dev/null; then
    echo "  ✓ installed"
    INSTALLED_DEPS+=("ripgrep")
  else
    echo "  ✗ failed"
  fi
else
  echo "⚠ Skipping cargo packages (cargo not available)"
fi

echo ""

##################################################
# INSTALL PYTHON PACKAGES
##################################################
echo "Installing Python packages..."
echo "----------------------------"

if [ -n "$PIP_BIN" ]; then
  # pynvim for Python provider
  echo "→ pynvim"
  if "$PIP_BIN" show pynvim &>/dev/null; then
    echo "  ✓ already installed"
    INSTALLED_DEPS+=("pynvim")
  elif "$PIP_BIN" install pynvim 2>/dev/null; then
    echo "  ✓ installed"
    INSTALLED_DEPS+=("pynvim")
  else
    echo "  ✗ failed"
  fi
else
  echo "⚠ Skipping Python packages (pip not available)"
fi

echo ""

##################################################
# INSTALL RUBY PACKAGES
##################################################
echo "Installing Ruby packages..."
echo "----------------------------"

if [ -n "$GEM_BIN" ]; then
  # neovim gem for Ruby provider
  echo "→ neovim (ruby provider)"
  if "$GEM_BIN" list neovim 2>/dev/null | grep -q "^neovim "; then
    echo "  ✓ already installed"
    INSTALLED_DEPS+=("neovim-ruby")
  elif "$GEM_BIN" install neovim 2>/dev/null; then
    echo "  ✓ installed"
    INSTALLED_DEPS+=("neovim-ruby")
  else
    echo "  ✗ failed"
  fi
else
  echo "⚠ Skipping Ruby packages (gem not available)"
fi

echo ""

##################################################
# BACKUP EXISTING CONFIG (if not managed by chezmoi)
##################################################
NVIM_CONFIG="$HOME/.config/nvim"
if [ -d "$NVIM_CONFIG" ] && [ ! -L "$NVIM_CONFIG" ]; then
  # Check if it's a git repo (LazyVim setup) or just files
  if [ -d "$NVIM_CONFIG/.git" ]; then
    echo "⚠ Existing nvim config appears to be a git repo"
    echo "   Skipping backup - chezmoi will manage this"
  else
    BACKUP_DIR="$NVIM_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backing up existing nvim config to $BACKUP_DIR"
    mv "$NVIM_CONFIG" "$BACKUP_DIR"
  fi
fi

##################################################
# SUMMARY
##################################################
echo ""
echo "========================================"
echo "Installation Summary"
echo "========================================"
echo ""

echo "Installed dependencies:"
if [ ${#INSTALLED_DEPS[@]} -gt 0 ]; then
  for dep in "${INSTALLED_DEPS[@]}"; do
    echo "  ✓ $dep"
  done
else
  echo "  (none)"
fi

echo ""
echo "Verification:"
echo "----------------------------"

# Check individual tools
[ -f "$CARGO_HOME/bin/fd" ] && echo "✓ fd-find" || echo "✗ fd-find"
[ -f "$CARGO_HOME/bin/tree-sitter" ] && echo "✓ tree-sitter-cli" || echo "✗ tree-sitter-cli"
[ -f "$CARGO_HOME/bin/rg" ] && echo "✓ ripgrep" || echo "✗ ripgrep"
[ -n "$PIP_BIN" ] && "$PIP_BIN" show pynvim &>/dev/null && echo "✓ pynvim" || echo "✗ pynvim"
[ -n "$GEM_BIN" ] && "$GEM_BIN" list neovim 2>/dev/null | grep -q "^neovim " && echo "✓ neovim gem" || echo "⚠ neovim gem"
[ -n "$NODE_BIN" ] && echo "✓ node: $(node --version 2>/dev/null || echo 'error')" || echo "✗ node"
[ -n "$NPM_BIN" ] && echo "✓ npm: $(npm --version 2>/dev/null || echo 'error')" || echo "✗ npm"

echo ""
echo "Next steps:"
echo "----------------------------"
echo "1. Your nvim config is managed by chezmoi"
echo "2. Launch nvim - LazyVim will install plugins on first run"
echo "3. Run :checkhealth in nvim to verify everything works"
echo ""
echo "Installation complete!"
