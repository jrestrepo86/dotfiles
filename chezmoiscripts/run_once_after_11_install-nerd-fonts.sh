#!/bin/bash
# Nerd Fonts installation script
# Installs multiple Nerd Fonts to ~/.local/share/fonts
set -e

FONTS_DIR="$HOME/.local/share/fonts"
TMP_DIR="/tmp/nerdfonts-install-$$"

# List of fonts to install
# Edit this array to add/remove fonts you want
# Font names must match the release filenames on GitHub
# See: https://github.com/ryanoasis/nerd-fonts/releases
FONTS_TO_INSTALL=(
  "Iosevka"
  "IosevkaTerm"
  "JetBrainsMono"
  "FiraCode"
  "Hack"
  "Meslo"
  "UbuntuMono"
)

# Create directories
mkdir -p "$FONTS_DIR"
mkdir -p "$TMP_DIR"

echo "=========================================="
echo "Nerd Fonts Installer"
echo "=========================================="
echo ""
echo "Fonts to install:"
printf '  - %s\n' "${FONTS_TO_INSTALL[@]}"
echo ""

# Get latest release version
echo "Fetching latest Nerd Fonts release..."
NERD_VERSION=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

if [ -z "$NERD_VERSION" ]; then
  echo "Error: Could not fetch Nerd Fonts version"
  exit 1
fi

echo "Latest version: v${NERD_VERSION}"
echo ""

# Counters for summary
TOTAL_FONTS=${#FONTS_TO_INSTALL[@]}
INSTALLED_FONTS=0
SKIPPED_FONTS=0
FAILED_FONTS=()
TOTAL_FILES=0

# Install each font
for FONT_NAME in "${FONTS_TO_INSTALL[@]}"; do
  echo "=========================================="
  echo "Processing: ${FONT_NAME}"
  echo "=========================================="

  cd "$TMP_DIR"

  # Check if font is already installed
  if fc-list | grep -i "${FONT_NAME}.*Nerd" >/dev/null 2>&1; then
    echo "✓ ${FONT_NAME} Nerd Font already installed - skipping download"
    echo "Existing variants:"
    fc-list | grep -i "${FONT_NAME}.*Nerd" | cut -d: -f2 | sort -u | head -5
    echo ""
    INSTALLED_FONTS=$((INSTALLED_FONTS + 1))
    SKIPPED_FONTS=$((SKIPPED_FONTS + 1))
    continue
  fi

  # Download font
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_VERSION}/${FONT_NAME}.zip"

  echo "Downloading ${FONT_NAME}..."
  if ! wget -q --show-progress "$FONT_URL" -O "${FONT_NAME}.zip" 2>&1; then
    echo "✗ Failed to download ${FONT_NAME}"
    FAILED_FONTS+=("${FONT_NAME}")
    continue
  fi

  # Extract fonts
  echo "Extracting ${FONT_NAME}..."
  if ! unzip -q "${FONT_NAME}.zip" -d "${FONT_NAME}" 2>&1; then
    echo "✗ Failed to extract ${FONT_NAME}"
    FAILED_FONTS+=("${FONT_NAME}")
    rm -f "${FONT_NAME}.zip"
    continue
  fi

  # Install fonts (only .ttf and .otf files, excluding Windows-specific fonts)
  echo "Installing ${FONT_NAME} to ${FONTS_DIR}..."
  FONT_COUNT=$(find "${FONT_NAME}" \( -name "*.ttf" -o -name "*.otf" \) ! -name "*Windows*" | wc -l)

  if [ "$FONT_COUNT" -eq 0 ]; then
    echo "⚠ No font files found in ${FONT_NAME}"
    FAILED_FONTS+=("${FONT_NAME}")
  else
    find "${FONT_NAME}" \( -name "*.ttf" -o -name "*.otf" \) ! -name "*Windows*" -exec cp {} "$FONTS_DIR/" \;
    echo "✓ Installed ${FONT_COUNT} font files from ${FONT_NAME}"
    TOTAL_FILES=$((TOTAL_FILES + FONT_COUNT))
    INSTALLED_FONTS=$((INSTALLED_FONTS + 1))
  fi

  # Clean up this font's files
  rm -f "${FONT_NAME}.zip"
  rm -rf "${FONT_NAME}"
  echo ""
done

# Update font cache only if new fonts were installed
if [ $SKIPPED_FONTS -lt $TOTAL_FONTS ]; then
  echo "=========================================="
  echo "Updating font cache..."
  echo "=========================================="
  if command -v fc-cache >/dev/null 2>&1; then
    # Create cache directory if it doesn't exist
    mkdir -p "$HOME/.cache/fontconfig"

    # Try to update cache, but don't fail if it errors
    if fc-cache -f "$FONTS_DIR" 2>&1; then
      echo "✓ Font cache updated"
    else
      echo "⚠ Font cache update had issues, but fonts are installed"
      echo "  Fonts will still work after restarting applications"
    fi
  else
    echo "⚠ fc-cache not found. You may need to restart applications"
  fi
else
  echo "=========================================="
  echo "All fonts already installed - skipping cache update"
  echo "=========================================="
fi

# Clean up temp directory
rm -rf "$TMP_DIR"

# Print summary
echo ""
echo "=========================================="
echo "Installation Summary"
echo "=========================================="
echo "Total fonts requested: ${TOTAL_FONTS}"
echo "Already installed (skipped): ${SKIPPED_FONTS}"
echo "Newly installed: $((INSTALLED_FONTS - SKIPPED_FONTS))"
echo "Total installed: ${INSTALLED_FONTS}"

if [ $TOTAL_FILES -gt 0 ]; then
  echo "New font files added: ${TOTAL_FILES}"
fi

if [ ${#FAILED_FONTS[@]} -gt 0 ]; then
  echo ""
  echo "Failed installations:"
  printf '  ✗ %s\n' "${FAILED_FONTS[@]}"
fi

echo ""
echo "Installed Nerd Font families:"
fc-list : family | grep -i "Nerd Font" | sort -u | head -20
echo ""
echo "Usage examples:"
echo "  - Ghostty: font-family = Iosevka Term Nerd Font"
echo "  - Terminal: Set font to 'JetBrains Mono Nerd Font'"
echo "  - Nvim: Set font to 'Hack Nerd Font Mono'"
echo ""
echo "To see all installed fonts: fc-list | grep 'Nerd Font'"

if [ $SKIPPED_FONTS -lt $TOTAL_FONTS ]; then
  echo ""
  echo "⚠ Note: Restart applications for new fonts to take effect"
fi

exit 0
