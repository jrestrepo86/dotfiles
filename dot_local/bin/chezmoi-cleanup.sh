#!/bin/bash
# Chezmoi Cleanup Utility
# Removes all software installed by chezmoi scripts
# This allows you to start fresh with a clean slate
#
# Usage:
#   chezmoi-cleanup.sh          # Interactive mode (asks for confirmation)
#   chezmoi-cleanup.sh --all    # Remove everything without prompts
#   chezmoi-cleanup.sh --help   # Show this help

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
BACKUP_DIR="$HOME/.chezmoi-cleanup-backup-$(date +%Y%m%d_%H%M%S)"
MINICONDA_DIR="$HOME/.local/share/miniconda"
CARGO_HOME="$HOME/.local/share/cargo"
RUSTUP_HOME="$HOME/.local/share/rustup"
GO_DIR="$HOME/.local/share/go"
GOPATH="$HOME/.local/go"
PNPM_HOME="$HOME/.local/share/pnpm"
GEM_HOME="$HOME/.local/share/gem"
NVM_DIR="$HOME/.local/share/nvm"
FONTS_DIR="$HOME/.local/share/fonts"
LOCAL_BIN="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor"

# Files to backup before cleanup
BASHRC="$HOME/.bashrc"
BASH_PROFILE="$HOME/.bash_profile"
BASH_ALIASES="$HOME/.bash_aliases"
GIT_COMPLETION="$HOME/.git-completion.bash"

# Desktop apps installed via apt
APT_PACKAGES=(
  "okular"
  "zathura"
  "gdebi"
  "gimp"
  "gparted"
  "gedit"
  "flatpak"
  "tilda"
  "google-chrome-stable"
  "brave-browser"
)

# Snap packages
SNAP_PACKAGES=(
  "chromium"
  "ghostty"
  "obsidian"
  "code"
)

##################################################
# Helper Functions
##################################################

print_header() {
  echo -e "\n${BLUE}================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}================================================${NC}\n"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

confirm() {
  local prompt="$1"
  local response

  while true; do
    read -rp "$prompt [y/N]: " response
    case "$response" in
      [yY][eE][sS] | [yY])
        return 0
        ;;
      [nN][oO] | [nN] | "")
        return 1
        ;;
      *)
        echo "Please answer yes or no."
        ;;
    esac
  done
}

remove_directory() {
  local dir="$1"
  local name="$2"

  if [ -d "$dir" ]; then
    if [ "$AUTO_YES" = true ]; then
      rm -rf "$dir"
      print_success "Removed $name: $dir"
    else
      if confirm "Remove $name at $dir?"; then
        rm -rf "$dir"
        print_success "Removed $name"
      else
        print_warning "Skipped $name"
      fi
    fi
  else
    print_info "$name not found (already clean)"
  fi
}

remove_file() {
  local file="$1"
  local name="$2"

  if [ -f "$file" ] || [ -L "$file" ]; then
    if [ "$AUTO_YES" = true ]; then
      rm -f "$file"
      print_success "Removed $name: $file"
    else
      if confirm "Remove $name at $file?"; then
        rm -f "$file"
        print_success "Removed $name"
      else
        print_warning "Skipped $name"
      fi
    fi
  else
    print_info "$name not found (already clean)"
  fi
}

backup_file() {
  local file="$1"
  if [ -f "$file" ] || [ -L "$file" ]; then
    if ! mkdir -p "$BACKUP_DIR" 2> /dev/null; then
      print_error "Failed to create backup directory: $BACKUP_DIR"
      return 1
    fi
    if cp "$file" "$BACKUP_DIR/" 2> /dev/null; then
      print_success "Backed up: $(basename "$file")"
    else
      print_warning "Could not backup: $(basename "$file")"
    fi
  fi
}

remove_apt_package() {
  local pkg="$1"

  if dpkg -l | grep -q "^ii  $pkg "; then
    if [ "$AUTO_YES" = true ]; then
      if sudo apt-get remove -y -qq "$pkg" 2>&1 | grep -v "^$"; then
        print_success "Removed apt package: $pkg"
      else
        print_error "Failed to remove: $pkg"
      fi
    else
      if confirm "Remove apt package $pkg?"; then
        if sudo apt-get remove -y "$pkg"; then
          print_success "Removed apt package: $pkg"
        else
          print_error "Failed to remove: $pkg"
        fi
      else
        print_warning "Skipped: $pkg"
      fi
    fi
  else
    print_info "Package $pkg not installed"
  fi
}

remove_snap_package() {
  local pkg="$1"

  if command -v snap &> /dev/null && snap list 2> /dev/null | grep -q "^$pkg "; then
    if [ "$AUTO_YES" = true ]; then
      if sudo snap remove "$pkg" 2>&1 | grep -v "^$"; then
        print_success "Removed snap: $pkg"
      else
        print_error "Failed to remove snap: $pkg"
      fi
    else
      if confirm "Remove snap package $pkg?"; then
        if sudo snap remove "$pkg"; then
          print_success "Removed snap: $pkg"
        else
          print_error "Failed to remove snap: $pkg"
        fi
      else
        print_warning "Skipped snap: $pkg"
      fi
    fi
  else
    print_info "Snap $pkg not installed"
  fi
}

##################################################
# Show Help
##################################################

show_help() {
  cat << EOF
Chezmoi Cleanup Utility
Removes all software installed by chezmoi installation scripts

USAGE:
  chezmoi-cleanup.sh [OPTIONS]

OPTIONS:
  --all, -a     Remove everything without confirmation prompts
  --help, -h    Show this help message
  --dry-run     Show what would be removed without actually removing

WHAT GETS REMOVED:
  • Miniconda (Python, conda packages, data science packages)
  • Rust (cargo, rustup, all installed crates)
  • Go (go runtime and GOPATH)
  • pnpm (Node.js package manager)
  • Ruby gems (user-installed gems)
  • NVM (if installed)
  • Nerd Fonts (all installed fonts)
  • Desktop applications (apt packages: okular, zathura, gimp, etc.)
  • Snap packages (ghostty, obsidian, chromium, VS Code)
  • Browsers (Google Chrome, Brave)
  • User binaries (nvim, lsd, bat, fd, etc.)
  • Neovim configuration (LazyVim)
  • Git completion script

WHAT GETS BACKED UP:
  Before removal, these files are backed up:
  • ~/.bashrc
  • ~/.bash_profile
  • ~/.bash_aliases
  • ~/.git-completion.bash

BACKUP LOCATION:
  $BACKUP_DIR

EXAMPLES:
  # Interactive cleanup (asks for each component)
  chezmoi-cleanup.sh

  # Remove everything automatically
  chezmoi-cleanup.sh --all

  # See what would be removed
  chezmoi-cleanup.sh --dry-run

AFTER CLEANUP:
  1. Delete chezmoi script state:
     chezmoi state delete-bucket --bucket=scriptState

  2. Re-apply chezmoi:
     chezmoi apply --verbose

  3. Reload shell:
     source ~/.bashrc

EOF
}

##################################################
# Parse Arguments
##################################################

AUTO_YES=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --all | -a)
      AUTO_YES=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help | -h)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

##################################################
# Dry Run Mode
##################################################

if [ "$DRY_RUN" = true ]; then
  print_header "DRY RUN MODE - Nothing will be removed"

  echo "Would remove the following:"
  echo ""
  echo "Package managers & Languages:"
  [ -d "$MINICONDA_DIR" ] && echo "  • Miniconda: $MINICONDA_DIR"
  [ -d "$CARGO_HOME" ] && echo "  • Cargo: $CARGO_HOME"
  [ -d "$RUSTUP_HOME" ] && echo "  • Rustup: $RUSTUP_HOME"
  [ -d "$GO_DIR" ] && echo "  • Go: $GO_DIR"
  [ -d "$GOPATH" ] && echo "  • GOPATH: $GOPATH"
  [ -d "$PNPM_HOME" ] && echo "  • pnpm: $PNPM_HOME"
  [ -d "$GEM_HOME" ] && echo "  • Ruby gems: $GEM_HOME"
  [ -d "$NVM_DIR" ] && echo "  • NVM: $NVM_DIR"

  echo ""
  echo "Desktop Applications (apt):"
  for pkg in "${APT_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $pkg "; then
      echo "  • $pkg"
    fi
  done

  echo ""
  echo "Snap Applications:"
  if command -v snap &> /dev/null; then
    for pkg in "${SNAP_PACKAGES[@]}"; do
      if snap list 2> /dev/null | grep -q "^$pkg "; then
        echo "  • $pkg"
      fi
    done
  fi

  echo ""
  echo "User binaries:"
  [ -f "$LOCAL_BIN/nvim" ] && echo "  • Neovim: $LOCAL_BIN/nvim"
  [ -f "$LOCAL_BIN/lsd" ] && echo "  • lsd: $LOCAL_BIN/lsd"
  [ -f "$LOCAL_BIN/bat" ] && echo "  • bat: $LOCAL_BIN/bat"
  [ -f "$LOCAL_BIN/fd" ] && echo "  • fd: $LOCAL_BIN/fd"
  [ -f "$LOCAL_BIN/alacritty" ] && echo "  • Alacritty: $LOCAL_BIN/alacritty"

  echo ""
  echo "Other:"
  [ -d "$FONTS_DIR" ] && [ -n "$(find "$FONTS_DIR" -name "*Nerd*" 2> /dev/null)" ] && echo "  • Nerd Fonts: $FONTS_DIR"
  [ -d "$HOME/.config/nvim" ] && echo "  • Neovim config: ~/.config/nvim"
  [ -f "$GIT_COMPLETION" ] && echo "  • Git completion: $GIT_COMPLETION"

  echo -e "\nWould backup:"
  [ -f "$BASHRC" ] && echo "  • ~/.bashrc"
  [ -f "$BASH_PROFILE" ] && echo "  • ~/.bash_profile"
  [ -f "$BASH_ALIASES" ] && echo "  • ~/.bash_aliases"
  [ -f "$GIT_COMPLETION" ] && echo "  • ~/.git-completion.bash"

  echo -e "\nTo actually remove, run without --dry-run"
  exit 0
fi

##################################################
# Main Cleanup
##################################################

print_header "Chezmoi Software Cleanup"

echo "This script will remove ALL software installed by chezmoi scripts."
echo "This includes:"
echo "  • Development tools (Python, Node.js, Rust, Go, Ruby)"
echo "  • Desktop applications (GIMP, Okular, Zathura, etc.)"
echo "  • Snap packages (Ghostty, Obsidian, VS Code, Chromium)"
echo "  • Browsers (Chrome, Brave)"
echo "  • Terminal tools (Neovim, bat, lsd, fd, fzf, lazygit)"
echo "  • Fonts and configurations"
echo ""
echo -e "${YELLOW}⚠ WARNING: This action cannot be undone!${NC}"
echo ""
echo "Your dotfiles (.bashrc, .bash_profile, etc.) will be backed up to:"
echo "  $BACKUP_DIR"
echo ""

if [ "$AUTO_YES" != true ]; then
  if ! confirm "Continue with cleanup?"; then
    echo "Cleanup cancelled."
    exit 0
  fi
fi

##################################################
# Backup Important Files
##################################################

print_header "Creating Backups"

backup_file "$BASHRC"
backup_file "$BASH_PROFILE"
backup_file "$BASH_ALIASES"
backup_file "$GIT_COMPLETION"

if [ -d "$BACKUP_DIR" ]; then
  print_success "Backups saved to: $BACKUP_DIR"
fi

##################################################
# Remove Desktop Applications (apt)
##################################################

print_header "Removing Desktop Applications (apt)"

# Check if we have sudo access
if ! command -v sudo &> /dev/null; then
  print_warning "sudo not available - skipping apt package removal"
else
  for pkg in "${APT_PACKAGES[@]}"; do
    remove_apt_package "$pkg"
  done

  # Clean up Chrome repository
  if [ -f "/etc/apt/sources.list.d/google-chrome.list" ]; then
    if [ "$AUTO_YES" = true ] || confirm "Remove Google Chrome repository?"; then
      sudo rm -f /etc/apt/sources.list.d/google-chrome.list
      sudo rm -f /usr/share/keyrings/google-chrome-keyring.gpg
      print_success "Removed Chrome repository"
    fi
  fi

  # Clean up Brave repository
  if [ -f "/etc/apt/sources.list.d/brave-browser-release.list" ]; then
    if [ "$AUTO_YES" = true ] || confirm "Remove Brave repository?"; then
      sudo rm -f /etc/apt/sources.list.d/brave-browser-release.list
      sudo rm -f /usr/share/keyrings/brave-browser-archive-keyring.gpg
      print_success "Removed Brave repository"
    fi
  fi

  # Run apt autoremove to clean up dependencies
  if [ "$AUTO_YES" = true ] || confirm "Run 'apt autoremove' to clean up unused dependencies?"; then
    sudo apt-get autoremove -y -qq
    print_success "Cleaned up unused dependencies"
  fi
fi

##################################################
# Remove Snap Packages
##################################################

print_header "Removing Snap Packages"

if ! command -v snap &> /dev/null; then
  print_info "Snap not installed - skipping snap package removal"
else
  for pkg in "${SNAP_PACKAGES[@]}"; do
    remove_snap_package "$pkg"
  done
fi

##################################################
# Remove Miniconda
##################################################

print_header "Removing Miniconda (Python & Data Science)"

remove_directory "$MINICONDA_DIR" "Miniconda"

# Remove conda config files
if [ -f "$HOME/.condarc" ]; then
  remove_file "$HOME/.condarc" "Conda config"
fi

##################################################
# Remove Rust
##################################################

print_header "Removing Rust (Cargo + Rustup)"

remove_directory "$CARGO_HOME" "Cargo"
remove_directory "$RUSTUP_HOME" "Rustup"

##################################################
# Remove Go
##################################################

print_header "Removing Go"

remove_directory "$GO_DIR" "Go runtime"
remove_directory "$GOPATH" "GOPATH"

##################################################
# Remove pnpm
##################################################

print_header "Removing pnpm"

remove_directory "$PNPM_HOME" "pnpm"

# Remove pnpm config
if [ -f "$HOME/.pnpmrc" ]; then
  remove_file "$HOME/.pnpmrc" "pnpm config"
fi

##################################################
# Remove Ruby Gems
##################################################

print_header "Removing Ruby Gems"

remove_directory "$GEM_HOME" "Ruby gems"

if [ -f "$HOME/.gemrc" ]; then
  remove_file "$HOME/.gemrc" "Gem config"
fi

##################################################
# Remove NVM (if installed)
##################################################

print_header "Removing NVM (if present)"

remove_directory "$NVM_DIR" "NVM"

##################################################
# Remove User Binaries
##################################################

print_header "Removing User-Installed Binaries"

# List of binaries installed by chezmoi scripts
BINARIES=(
  "nvim"
  "lsd"
  "bat"
  "fd"
  "alacritty"
  "tree-sitter"
  "mmdc"
  "fzf"
  "lazygit"
)

for binary in "${BINARIES[@]}"; do
  remove_file "$LOCAL_BIN/$binary" "$binary"
done

##################################################
# Remove Nerd Fonts
##################################################

print_header "Removing Nerd Fonts"

# Only remove Nerd Fonts, not all fonts
if [ -d "$FONTS_DIR" ]; then
  if [ "$AUTO_YES" = true ]; then
    find "$FONTS_DIR" -name "*Nerd*" -delete 2> /dev/null || true
    print_success "Removed Nerd Fonts"

    # Update font cache
    if command -v fc-cache > /dev/null 2>&1; then
      fc-cache -f "$FONTS_DIR" 2> /dev/null || true
      print_success "Font cache updated"
    fi
  else
    if confirm "Remove all Nerd Fonts from $FONTS_DIR?"; then
      find "$FONTS_DIR" -name "*Nerd*" -delete 2> /dev/null || true
      print_success "Removed Nerd Fonts"

      # Update font cache
      if command -v fc-cache > /dev/null 2>&1; then
        fc-cache -f "$FONTS_DIR" 2> /dev/null || true
        print_success "Font cache updated"
      fi
    else
      print_warning "Skipped Nerd Fonts"
    fi
  fi
fi

##################################################
# Remove Desktop Launchers
##################################################

print_header "Removing Desktop Launchers"

remove_file "$DESKTOP_DIR/alacritty.desktop" "Alacritty launcher"
remove_file "$DESKTOP_DIR/kitty.desktop" "Kitty launcher"

# Remove icons (only if we removed launchers)
if [ ! -f "$DESKTOP_DIR/alacritty.desktop" ] && [ ! -f "$DESKTOP_DIR/kitty.desktop" ]; then
  if [ -d "$ICON_DIR" ]; then
    find "$ICON_DIR" -name "Alacritty.*" -delete 2> /dev/null || true
    find "$ICON_DIR" -name "kitty.*" -delete 2> /dev/null || true
    print_success "Removed application icons"
  fi

  # Update desktop database
  if command -v update-desktop-database > /dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" 2> /dev/null || true
  fi
fi

##################################################
# Remove Git Completion
##################################################

print_header "Removing Git Completion"

remove_file "$GIT_COMPLETION" "Git completion script"

##################################################
# Remove LazyVim/Neovim Configuration
##################################################

print_header "Removing Neovim Configuration"

# Only proceed if any Neovim directories exist
if [ -d "$HOME/.config/nvim" ] || [ -d "$HOME/.local/share/nvim" ] \
  || [ -d "$HOME/.local/state/nvim" ] || [ -d "$HOME/.cache/nvim" ]; then

  if [ "$AUTO_YES" = true ]; then
    rm -rf "$HOME/.config/nvim" 2> /dev/null || true
    rm -rf "$HOME/.local/share/nvim" 2> /dev/null || true
    rm -rf "$HOME/.local/state/nvim" 2> /dev/null || true
    rm -rf "$HOME/.cache/nvim" 2> /dev/null || true
    print_success "Removed Neovim configuration and data"
  else
    if confirm "Remove Neovim configuration and data?"; then
      rm -rf "$HOME/.config/nvim" 2> /dev/null || true
      rm -rf "$HOME/.local/share/nvim" 2> /dev/null || true
      rm -rf "$HOME/.local/state/nvim" 2> /dev/null || true
      rm -rf "$HOME/.cache/nvim" 2> /dev/null || true
      print_success "Removed Neovim configuration and data"
    else
      print_warning "Skipped Neovim configuration"
    fi
  fi
else
  print_info "Neovim configuration not found (already clean)"
fi

##################################################
# Summary
##################################################

print_header "Cleanup Complete!"

echo "The following categories have been processed:"
echo "  ✓ Miniconda (Python + Data Science packages)"
echo "  ✓ Rust (Cargo + Rustup)"
echo "  ✓ Go runtime and packages"
echo "  ✓ pnpm (Node.js package manager)"
echo "  ✓ Ruby gems"
echo "  ✓ Desktop applications (apt packages)"
echo "  ✓ Snap packages (Ghostty, Obsidian, VS Code, etc.)"
echo "  ✓ Browsers (Chrome, Brave)"
echo "  ✓ User binaries (nvim, lsd, bat, fzf, lazygit, etc.)"
echo "  ✓ Nerd Fonts"
echo "  ✓ Desktop launchers"
echo "  ✓ Neovim configuration"
echo "  ✓ Git completion"
echo ""

if [ -d "$BACKUP_DIR" ]; then
  echo -e "${GREEN}Backups saved to:${NC}"
  echo "  $BACKUP_DIR"
  echo ""
fi

print_header "Next Steps"

cat << EOF
1. Delete chezmoi script state (allows run_once_* to run again):
   ${GREEN}chezmoi state delete-bucket --bucket=scriptState${NC}

2. Re-apply chezmoi to reinstall everything:
   ${GREEN}chezmoi apply --verbose${NC}

3. Reload your shell:
   ${GREEN}source ~/.bashrc${NC}

4. Verify installations:
   ${GREEN}which nvim python cargo go ghostty${NC}
   ${GREEN}snap list${NC}

Note: Your dotfiles (.bashrc, .bash_profile) may need manual cleanup
      of PATH exports. Check the backup if you need the originals.

EOF

print_success "Cleanup complete! System is ready for fresh chezmoi apply."
