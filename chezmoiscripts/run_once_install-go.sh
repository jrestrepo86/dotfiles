#!/bin/bash
# Save this as: .chezmoiscripts/run_once_install-go.sh

set -e

GO_DIR="$HOME/.local/share/go"
ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

# Check if Go is already installed
if [ -d "$GO_DIR" ]; then
  echo "Go already installed at $GO_DIR"
  exit 0
fi

# Fetch latest Go version
echo "Fetching latest Go version..."
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n1 | sed 's/go//')

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
  echo "Unsupported architecture: $ARCH"
  exit 1
  ;;
esac

GO_ARCHIVE="go${GO_VERSION}.${OS}-${ARCH}.tar.gz"
GO_URL="https://go.dev/dl/${GO_ARCHIVE}"

echo "Installing Go ${GO_VERSION}..."

# Download Go
wget "$GO_URL"

# Create installation directory
mkdir -p "$GO_DIR"

# Extract to installation directory
tar -C "$GO_DIR" -xzf "$GO_ARCHIVE" --strip-components=1

# Clean up archive
rm "$GO_ARCHIVE"

echo "Go installed successfully at $GO_DIR"
echo "Add to your shell config:"
echo "  export GOROOT=\"$GO_DIR\""
echo "  export PATH=\"\$GOROOT/bin:\$PATH\""
echo "  export GOPATH=\"\$HOME/go\""
echo "  export PATH=\"\$GOPATH/bin:\$PATH\""
