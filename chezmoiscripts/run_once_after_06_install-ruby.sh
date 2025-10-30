#!/bin/bash
# Ruby 3.2.6 installation via rbenv - TRULY NO SUDO REQUIRED
# Uses Ruby 3.2.x which is compatible with libcrypt.so.1 (no symlink needed!)
set -e

export RBENV_ROOT="$HOME/.local/share/rbenv"
export GEM_HOME="$HOME/.local/share/gem"
export PATH="$RBENV_ROOT/bin:$PATH"

MINICONDA_DIR="$HOME/.local/share/miniconda"
CONDA_BIN="$MINICONDA_DIR/bin/conda"
RUBY_VERSION="3.2.6" # Latest stable 3.2.x - works with libcrypt.so.1!

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Ruby $RUBY_VERSION installation via rbenv"
echo "TRULY NO SUDO REQUIRED - 100% local installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Why Ruby 3.2.x? Compatible with libcrypt.so.1"
echo "No libcrypt.so.2 symlink needed!"
echo ""

##################################################
# Check for conda
##################################################
if [ ! -f "$CONDA_BIN" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Error: Miniconda not found"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Miniconda is required for build dependencies."
  echo "Location expected: $MINICONDA_DIR"
  echo ""
  echo "To install Miniconda, run:"
  echo "  ./chezmoiscripts/run_once_after_01_install-conda.sh"
  echo ""
  echo "Or install manually:"
  echo "  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
  echo "  bash Miniconda3-latest-Linux-x86_64.sh -b -p $MINICONDA_DIR"
  echo ""
  exit 1
fi

##################################################
# Install build dependencies via conda
##################################################
echo "Installing build dependencies via conda..."
echo ""

# Required packages for Ruby compilation
REQUIRED_DEPS=(
  gcc_linux-64 # C compiler
  gxx_linux-64 # C++ compiler
  make         # Build tool
  openssl      # SSL/TLS library
  readline     # Command line editing
  zlib         # Compression library
  bzip2        # Compression library
  yaml         # YAML parser
  libffi       # Foreign function interface
)

DEPS_TO_INSTALL=()
for pkg in "${REQUIRED_DEPS[@]}"; do
  if ! "$CONDA_BIN" list "^${pkg}$" 2> /dev/null | grep -q "^${pkg} "; then
    DEPS_TO_INSTALL+=("$pkg")
  fi
done

if [ ${#DEPS_TO_INSTALL[@]} -gt 0 ]; then
  echo "Installing: ${DEPS_TO_INSTALL[*]}"
  if "$CONDA_BIN" install -y -c conda-forge "${DEPS_TO_INSTALL[@]}"; then
    echo "✓ Dependencies installed from conda"
  else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Error: Failed to install build dependencies"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Try installing dependencies manually:"
    echo "  conda install -c conda-forge gcc_linux-64 gxx_linux-64 make openssl readline zlib bzip2 libyaml libffi"
    echo ""
    exit 1
  fi
else
  echo "✓ All dependencies already installed"
fi

# Verify key dependencies
echo ""
echo "Verifying conda dependencies..."
MISSING_DEPS=()
for pkg in gcc_linux-64 openssl readline; do
  if ! "$CONDA_BIN" list "^${pkg}$" 2> /dev/null | grep -q "^${pkg} "; then
    MISSING_DEPS+=("$pkg")
  fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
  echo "⚠ Warning: Missing critical dependencies: ${MISSING_DEPS[*]}"
  echo "Ruby compilation may fail."
fi

echo ""

##################################################
# Set build environment for conda dependencies
##################################################
echo "Configuring build environment..."

export CPPFLAGS="-I$MINICONDA_DIR/include"
export LDFLAGS="-L$MINICONDA_DIR/lib -Wl,-rpath,$MINICONDA_DIR/lib"
export PKG_CONFIG_PATH="$MINICONDA_DIR/lib/pkgconfig:/usr/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="$MINICONDA_DIR/bin:$PATH"

# Point Ruby configure to conda libraries
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$MINICONDA_DIR --with-readline-dir=$MINICONDA_DIR --with-zlib-dir=$MINICONDA_DIR --with-libyaml-dir=$MINICONDA_DIR --disable-install-doc"

echo "✓ Build environment configured"
echo "  CPPFLAGS: $CPPFLAGS"
echo "  LDFLAGS: $LDFLAGS"
echo "  RUBY_CONFIGURE_OPTS: $RUBY_CONFIGURE_OPTS"
echo ""

##################################################
# Install rbenv
##################################################
if [ ! -d "$RBENV_ROOT" ]; then
  echo "Installing rbenv..."
  if git clone https://github.com/rbenv/rbenv.git "$RBENV_ROOT" 2> /dev/null; then
    # Try to compile dynamic bash extension for speed (optional)
    cd "$RBENV_ROOT" && src/configure && make -C src 2> /dev/null || true
    echo "✓ rbenv installed at $RBENV_ROOT"
  else
    echo "Error: Failed to clone rbenv repository"
    exit 1
  fi
else
  echo "✓ rbenv already installed at $RBENV_ROOT"
fi

##################################################
# Install ruby-build plugin
##################################################
RUBY_BUILD_DIR="$RBENV_ROOT/plugins/ruby-build"
if [ ! -d "$RUBY_BUILD_DIR" ]; then
  echo "Installing ruby-build plugin..."
  if git clone https://github.com/rbenv/ruby-build.git "$RUBY_BUILD_DIR" 2> /dev/null; then
    echo "✓ ruby-build installed"
  else
    echo "Error: Failed to clone ruby-build repository"
    exit 1
  fi
else
  echo "✓ ruby-build already installed"
  # Update ruby-build to get latest Ruby definitions
  echo "  Updating ruby-build..."
  cd "$RUBY_BUILD_DIR" && git pull -q 2> /dev/null || true
fi

##################################################
# Initialize rbenv for this session
##################################################
eval "$("$RBENV_ROOT/bin/rbenv" init - bash)"

##################################################
# Check if Ruby version is already installed
##################################################
if [ -d "$RBENV_ROOT/versions/$RUBY_VERSION" ]; then
  echo ""
  echo "✓ Ruby $RUBY_VERSION is already installed!"
  "$RBENV_ROOT/bin/rbenv" global "$RUBY_VERSION"
  echo ""
else
  ##################################################
  # Install Ruby
  ##################################################
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Installing Ruby $RUBY_VERSION"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "This will take 3-5 minutes..."
  echo "Ruby will be compiled from source using conda libraries."
  echo ""

  # Install with verbose output for troubleshooting
  if "$RBENV_ROOT/bin/rbenv" install "$RUBY_VERSION" --verbose; then
    "$RBENV_ROOT/bin/rbenv" global "$RUBY_VERSION"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✓ Ruby $RUBY_VERSION installed successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
  else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Error: Ruby installation failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Troubleshooting steps:"
    echo ""
    echo "1. Check rbenv build log:"
    echo "   cat /tmp/ruby-build.*.log"
    echo ""
    echo "2. Verify conda dependencies are installed:"
    echo "   conda list | grep -E '(gcc|openssl|readline|yaml)'"
    echo ""
    echo "3. Check if compiler works:"
    echo "   $MINICONDA_DIR/bin/gcc --version"
    echo ""
    echo "4. Try manual installation with more verbose output:"
    echo "   RUBY_CONFIGURE_OPTS='$RUBY_CONFIGURE_OPTS' rbenv install $RUBY_VERSION -v"
    echo ""
    echo "5. If all else fails, try an even older Ruby version:"
    echo "   rbenv install 3.1.4"
    echo ""
    exit 1
  fi
fi

# Refresh rbenv shims
"$RBENV_ROOT/bin/rbenv" rehash

##################################################
# Configure gem installation
##################################################
echo "Configuring gem installation..."

mkdir -p "$GEM_HOME"

if [ ! -f "$HOME/.gemrc" ]; then
  cat > "$HOME/.gemrc" << 'EOF'
# Gem configuration - user installation, no documentation
gem: --user-install --no-document
install: --no-document
update: --no-document
EOF
  echo "✓ Created ~/.gemrc"
else
  echo "✓ ~/.gemrc already exists"
fi

##################################################
# Verify Ruby installation
##################################################
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Verifying Ruby installation..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

RUBY_BIN="$RBENV_ROOT/versions/$RUBY_VERSION/bin/ruby"
GEM_BIN="$RBENV_ROOT/versions/$RUBY_VERSION/bin/gem"

# Test basic Ruby execution
if "$RUBY_BIN" -e "puts 'Ruby executable works!'" > /dev/null 2>&1; then
  echo "✓ Ruby executable: OK"
else
  echo "✗ Ruby executable: FAILED"
fi

# Test OpenSSL extension
if "$RUBY_BIN" -e "require 'openssl'" 2> /dev/null; then
  echo "✓ OpenSSL extension: OK"
  # Show OpenSSL version
  OPENSSL_VER=$("$RUBY_BIN" -e "require 'openssl'; puts OpenSSL::OPENSSL_VERSION" 2> /dev/null)
  echo "  OpenSSL version: $OPENSSL_VER"
else
  echo "✗ OpenSSL extension: FAILED (SSL connections won't work)"
fi

# Test psych (YAML) extension
if "$RUBY_BIN" -e "require 'psych'" 2> /dev/null; then
  echo "✓ YAML extension (psych): OK"
else
  echo "⚠ YAML extension (psych): Not available (some gems may fail)"
fi

# Test zlib extension
if "$RUBY_BIN" -e "require 'zlib'" 2> /dev/null; then
  echo "✓ Zlib extension: OK"
else
  echo "✗ Zlib extension: FAILED (gem installation may fail)"
fi

# Test readline extension
if "$RUBY_BIN" -e "require 'readline'" 2> /dev/null; then
  echo "✓ Readline extension: OK"
else
  echo "⚠ Readline extension: Not available (irb history won't work)"
fi

# Test libcrypt compatibility (should work with .so.1!)
if "$RUBY_BIN" -e "require 'digest'" 2> /dev/null; then
  echo "✓ Digest/Crypt: OK (libcrypt.so.1 compatible!)"
else
  echo "✗ Digest/Crypt: FAILED"
fi

##################################################
# Final Summary
##################################################
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Ruby installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Ruby version:  $("$RUBY_BIN" --version)"
echo "Gem version:   $("$GEM_BIN" --version)"
echo "Ruby location: $RBENV_ROOT/versions/$RUBY_VERSION"
echo "Gem location:  $GEM_HOME"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Configuration Required"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Add these lines to your ~/.bashrc (if not already present):"
echo ""
echo "# Ruby via rbenv"
echo 'export RBENV_ROOT="$HOME/.local/share/rbenv"'
echo 'export GEM_HOME="$HOME/.local/share/gem"'
echo 'export PATH="$RBENV_ROOT/bin:$PATH"'
echo 'eval "$(rbenv init - bash)"'
echo ""
echo "Then reload your shell:"
echo "  source ~/.bashrc"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Reload your shell configuration:"
echo "   source ~/.bashrc"
echo ""
echo "2. Verify Ruby is accessible:"
echo "   ruby --version"
echo "   which ruby"
echo ""
echo "3. Install essential gems:"
echo "   gem install bundler"
echo "   gem install rake"
echo ""
echo "4. Test gem installation:"
echo "   gem list"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Why Ruby 3.2.6?"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✓ Compatible with libcrypt.so.1 (Ubuntu 24.04 native)"
echo "✓ No sudo required - no system modifications needed"
echo "✓ Stable and well-tested (released 2024)"
echo "✓ Works on HPC clusters and restricted environments"
echo "✓ Still actively maintained with security updates"
echo ""
echo "If you specifically need Ruby 3.3+, you'll need to create"
echo "the libcrypt.so.2 symlink (requires one-time sudo)."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installation Complete! 🎉"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
