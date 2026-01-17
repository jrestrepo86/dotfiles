#!/bin/bash
# Go installation - independent of other tools
set -e

GO_DIR="$HOME/.local/share/go"
ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

# Check if Go is already installed
if [ -d "$GO_DIR" ] && [ -f "$GO_DIR/bin/go" ]; then
  echo "Go already installed at $GO_DIR"
  echo "Current version: $("$GO_DIR/bin/go" version)"
  exit 0
fi

# Fetch latest Go version
echo "Fetching latest Go version..."
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n1 | sed 's/go//')

if [ -z "$GO_VERSION" ]; then
  echo "Error: Failed to fetch Go version"
  exit 1
fi

# Map architecture names
case $ARCH in
x86_64)
  ARCH="amd64"
  ;;
aarch64 | arm64)
  ARCH="arm64"
  ;;
armv6l)
  ARCH="armv6l"
  ;;
*)
  echo "Error: Unsupported architecture: $ARCH"
  echo "Go supports: amd64, arm64, armv6l"
  exit 1
  ;;
esac

GO_ARCHIVE="go${GO_VERSION}.${OS}-${ARCH}.tar.gz"
GO_URL="https://go.dev/dl/${GO_ARCHIVE}"

echo "Installing Go ${GO_VERSION} for ${OS}-${ARCH}..."
echo "$url: ${GO_URL}"

# Download Go
if ! wget -4 "$GO_URL"; then
  echo "Error: Failed to download Go from $GO_URL"
  exit 1
fi

# Create installation directory
mkdir -p "$GO_DIR"

# Extract to installation directory
if ! tar -C "$GO_DIR" -xzf "$GO_ARCHIVE" --strip-components=1; then
  echo "Error: Failed to extract Go archive"
  rm -f "$GO_ARCHIVE"
  exit 1
fi

# Clean up archive
rm "$GO_ARCHIVE"

# Verify installation
if [ -f "$GO_DIR/bin/go" ]; then
  echo "Go installed successfully at $GO_DIR"
  echo "Go version: $("$GO_DIR/bin/go" version)"
  echo ""
  echo "Your .bash_profile should already have the correct PATH configuration:"
  echo '  export GOROOT="$HOME/.local/share/go"'
  echo '  export PATH="$GOROOT/bin:$PATH"'
  echo '  export GOPATH="$HOME/.local/go"'
  echo '  export PATH="$GOPATH/bin:$PATH"'
else
  echo "Error: Go installation completed but go binary not found"
  exit 1
fi
