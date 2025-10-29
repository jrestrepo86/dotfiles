#!/bin/bash
# Ruby 3.3.6 installation via rbenv
# Latest stable and proven version
set -e

export RBENV_ROOT="$HOME/.local/share/rbenv"
export GEM_HOME="$HOME/.local/share/gem"
export PATH="$RBENV_ROOT/bin:$PATH"

MINICONDA_DIR="$HOME/.local/share/miniconda"
CONDA_BIN="$MINICONDA_DIR/bin/conda"
RUBY_VERSION="3.3.6"

echo "Ruby $RUBY_VERSION installation via rbenv"
echo ""

##################################################
# Check for conda
##################################################
if [ ! -f "$CONDA_BIN" ]; then
  echo "Error: Miniconda not found at $MINICONDA_DIR"
  echo "Please run the miniconda installation script first (01)."
  exit 1
fi

##################################################
# Install build dependencies
##################################################
echo "Installing build dependencies via conda..."

DEPS_TO_INSTALL=()
for pkg in gcc_linux-64 gxx_linux-64 make openssl readline zlib bzip2 yaml; do
  if ! "$CONDA_BIN" list "^${pkg}$" 2> /dev/null | grep -q "^${pkg} "; then
    DEPS_TO_INSTALL+=("$pkg")
  fi
done

if [ ${#DEPS_TO_INSTALL[@]} -gt 0 ]; then
  if "$CONDA_BIN" install -y -c conda-forge "${DEPS_TO_INSTALL[@]}" 2> /dev/null; then
    echo "✓ Dependencies installed from conda"
  else
    echo "⚠ Some conda packages failed, trying without yaml..."
    # Retry without yaml package
    DEPS_WITHOUT_YAML=()
    for pkg in "${DEPS_TO_INSTALL[@]}"; do
      if [ "$pkg" != "yaml" ]; then
        DEPS_WITHOUT_YAML+=("$pkg")
      fi
    done

    if [ ${#DEPS_WITHOUT_YAML[@]} -gt 0 ]; then
      "$CONDA_BIN" install -y -c conda-forge "${DEPS_WITHOUT_YAML[@]}"
    fi

    # Install libyaml from system instead
    echo ""
    echo "Installing libyaml-dev from system..."
    if command -v sudo &> /dev/null && command -v apt-get &> /dev/null; then
      sudo apt-get update -qq
      sudo apt-get install -y libyaml-dev
      echo "✓ libyaml-dev installed from system"
    else
      echo "⚠ Warning: Could not install libyaml"
      echo "  Install manually: sudo apt install libyaml-dev"
    fi
  fi
else
  echo "✓ Dependencies already installed"
fi

echo ""

##################################################
# Set build environment
##################################################
export CPPFLAGS="-I$MINICONDA_DIR/include"
export LDFLAGS="-L$MINICONDA_DIR/lib -Wl,-rpath,$MINICONDA_DIR/lib"
export PKG_CONFIG_PATH="$MINICONDA_DIR/lib/pkgconfig:/usr/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="$MINICONDA_DIR/bin:$PATH"

##################################################
# Install rbenv
##################################################
if [ ! -d "$RBENV_ROOT" ]; then
  echo "Installing rbenv..."
  git clone https://github.com/rbenv/rbenv.git "$RBENV_ROOT"
  cd "$RBENV_ROOT" && src/configure && make -C src 2> /dev/null || true
  echo "✓ rbenv installed"
else
  echo "✓ rbenv already installed"
fi

##################################################
# Install ruby-build
##################################################
RUBY_BUILD_DIR="$RBENV_ROOT/plugins/ruby-build"
if [ ! -d "$RUBY_BUILD_DIR" ]; then
  echo "Installing ruby-build..."
  git clone https://github.com/rbenv/ruby-build.git "$RUBY_BUILD_DIR"
  echo "✓ ruby-build installed"
else
  echo "✓ ruby-build already installed"
  cd "$RUBY_BUILD_DIR" && git pull -q
fi

##################################################
# Initialize rbenv
##################################################
eval "$("$RBENV_ROOT/bin/rbenv" init - bash)"

##################################################
# Install Ruby
##################################################
if [ -d "$RBENV_ROOT/versions/$RUBY_VERSION" ]; then
  echo "✓ Ruby $RUBY_VERSION already installed"
  "$RBENV_ROOT/bin/rbenv" global "$RUBY_VERSION"
else
  echo ""
  echo "Installing Ruby $RUBY_VERSION (takes 3-5 minutes)..."
  echo ""

  if "$RBENV_ROOT/bin/rbenv" install "$RUBY_VERSION"; then
    "$RBENV_ROOT/bin/rbenv" global "$RUBY_VERSION"
    echo ""
    echo "✓ Ruby $RUBY_VERSION installed successfully"
  else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Error: Ruby installation failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "If psych extension failed, install libyaml-dev:"
    echo "  sudo apt install libyaml-dev"
    echo ""
    echo "Then retry: rbenv install $RUBY_VERSION"
    echo ""
    exit 1
  fi
fi

"$RBENV_ROOT/bin/rbenv" rehash

##################################################
# Configure gems
##################################################
mkdir -p "$GEM_HOME"

if [ ! -f "$HOME/.gemrc" ]; then
  echo "gem: --user-install --no-document" > "$HOME/.gemrc"
fi

##################################################
# Verify psych extension
##################################################
if "$RBENV_ROOT/versions/$RUBY_VERSION/bin/ruby" -e "require 'psych'" 2> /dev/null; then
  echo "✓ psych extension (YAML support) is working"
else
  echo "⚠ Warning: psych extension may not be available"
fi

##################################################
# Summary
##################################################
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Ruby installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Ruby: $("$RBENV_ROOT/versions/$RUBY_VERSION/bin/ruby" --version)"
echo ""
echo "ADD TO ~/.bashrc:"
echo ""
echo "export RBENV_ROOT=\"\$HOME/.local/share/rbenv\""
echo "export GEM_HOME=\"\$HOME/.local/share/gem\""
echo "export PATH=\"\$RBENV_ROOT/bin:\$PATH\""
echo "eval \"\$(rbenv init - bash)\""
echo ""
echo "Then: source ~/.bashrc"
echo ""
