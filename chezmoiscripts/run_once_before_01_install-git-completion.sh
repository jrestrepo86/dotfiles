#!/bin/bash
# Download git completion script
# File: chezmoiscripts/run_once_before_01_install-git-completion.sh
set -e

GIT_COMPLETION_FILE="$HOME/.git-completion.bash"

# Check if already exists
if [ -f "$GIT_COMPLETION_FILE" ] && [ ! -L "$GIT_COMPLETION_FILE" ]; then
  echo "Git completion already installed at $GIT_COMPLETION_FILE"
  exit 0
fi

echo "Downloading git completion script..."

# Get latest version from git repository
GIT_COMPLETION_URL="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"

if ! wget -4 "$GIT_COMPLETION_URL" -O "$GIT_COMPLETION_FILE"; then
  echo "Error: Failed to download git completion"
  echo "Trying fallback URL..."

  # Fallback to a specific stable version
  GIT_COMPLETION_URL="https://raw.githubusercontent.com/git/git/v2.43.0/contrib/completion/git-completion.bash"

  if ! wget -4 "$GIT_COMPLETION_URL" -O "$GIT_COMPLETION_FILE"; then
    echo "Error: Failed to download git completion from fallback URL"
    exit 1
  fi
fi

# Verify the file was downloaded and is not empty
if [ ! -s "$GIT_COMPLETION_FILE" ]; then
  echo "Error: Downloaded git completion file is empty"
  rm -f "$GIT_COMPLETION_FILE"
  exit 1
fi

echo "✓ Git completion installed at $GIT_COMPLETION_FILE"
echo "File size: $(wc -c < "$GIT_COMPLETION_FILE") bytes"
echo ""
echo "To test:"
echo "  source ~/.bashrc"
echo "  git <tab><tab>"
