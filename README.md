# Dotfiles - Managed by Chezmoi

Personal dotfiles for a complete development environment, managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start (Fresh Machine)

```bash
# 1. Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# 2. Initialize from repo
chezmoi init https://github.com/jrestrepo86/dotfiles.git

# 3. Preview changes
chezmoi diff

# 4. Apply (this will run all installation scripts)
chezmoi apply --verbose
```

## Table of Contents

- [Prerequisites](#prerequisites)
- [What Gets Installed](#what-gets-installed)
- [Installation Steps](#installation-steps)
- [Post-Installation](#post-installation)
- [Encrypted Files](#encrypted-files)
- [Script Execution Order](#script-execution-order)
- [Updating](#updating)
- [Cleanup / Fresh Start](#cleanup--fresh-start)
- [Troubleshooting](#troubleshooting)
- [File Structure](#file-structure)

## Prerequisites

### Required

- `git` - for chezmoi and version control
- `curl` or `wget` - for downloading packages
- `bash` - shell (4.0+)

### Optional (for encrypted files)

- `age` - for decrypting sensitive files

```bash
# Install age (Debian/Ubuntu)
sudo apt-get install age -y

# Or macOS
brew install age
```

### Generate Age Keys (First Time Only)

If you use encrypted files, generate keys on your primary machine:

```bash
mkdir -p ~/.config/chezmoi/age
age-keygen -o ~/.config/chezmoi/age/key.txt
chmod 600 ~/.config/chezmoi/age/key.txt

# Show public key (save this!)
age-keygen -y ~/.config/chezmoi/age/key.txt
```

## What Gets Installed

### Languages & Runtimes

| Tool                   | Version | Location                   |
| ---------------------- | ------- | -------------------------- |
| **Python** (Miniconda) | Latest  | `~/.local/share/miniconda` |
| **Node.js** (NVM)      | LTS     | `~/.local/share/nvm`       |
| **Rust**               | Stable  | `~/.local/share/cargo`     |
| **Go**                 | Latest  | `~/.local/share/go`        |
| **Ruby** (rbenv)       | 3.2.6   | `~/.local/share/rbenv`     |

### Package Managers

| Tool      | Location                             |
| --------- | ------------------------------------ |
| **pnpm**  | `~/.local/share/pnpm`                |
| **conda** | `~/.local/share/miniconda/bin/conda` |
| **cargo** | `~/.local/share/cargo/bin/cargo`     |
| **gem**   | `~/.local/share/gem`                 |

### Development Tools

| Tool            | Purpose                      |
| --------------- | ---------------------------- |
| **Neovim**      | Text editor with LazyVim     |
| **lazygit**     | Terminal UI for git          |
| **fzf**         | Fuzzy finder                 |
| **fd**          | Fast file finder             |
| **ripgrep**     | Fast grep                    |
| **bat**         | Cat with syntax highlighting |
| **lsd**         | Modern ls replacement        |
| **tree-sitter** | Parser generator             |

### Terminals

| Tool          | Installation Method       |
| ------------- | ------------------------- |
| **Kitty**     | Official binary installer |
| **Alacritty** | Built via cargo           |

### Desktop Applications (optional)

- Chromium, Chrome, Brave (browsers)
- Okular, Zathura (PDF viewers)
- GIMP, GParted, Gedit
- Obsidian, VS Code (via snap)

## Installation Steps

### Step 1: Install chezmoi

```bash
# Install to ~/.local/bin
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# Add to PATH for current session
export PATH="$HOME/.local/bin:$PATH"

# Verify
chezmoi --version
```

### Step 2: Configure age keys (if using encryption)

```bash
# Create directory
mkdir -p ~/.config/chezmoi/age

# Copy your existing key (from another machine)
# Or generate new one with: age-keygen -o ~/.config/chezmoi/age/key.txt
chmod 600 ~/.config/chezmoi/age/key.txt

# Create chezmoi config
cat > ~/.config/chezmoi/chezmoi.yaml << 'EOF'
encryption: age
age:
  identities:
    - ~/.config/chezmoi/age/key.txt
  recipients:
    - age1xxxxxx...  # Your public key here
EOF
```

### Step 3: Initialize from repository

```bash
# HTTPS (recommended for first setup)
chezmoi init https://github.com/jrestrepo86/dotfiles.git

# Or SSH (if you have keys configured)
chezmoi init git@github.com:jrestrepo86/dotfiles.git
```

### Step 4: Preview changes

```bash
# See what will be changed
chezmoi diff

# See what scripts will run
ls -la $(chezmoi source-path)/chezmoiscripts/
```

### Step 5: Apply configuration

```bash
# Full installation (runs all scripts)
chezmoi apply --verbose

# This will take 15-30 minutes on first run
# Scripts install: Python, Node, Rust, Go, Ruby, Neovim, etc.
```

### Step 6: Reload shell

```bash
# Either restart terminal or:
source ~/.bashrc
```

## Post-Installation

### Verify installations

```bash
# Check all tools
nvim --version          # Neovim
python --version        # Python (via conda)
node --version          # Node.js (via nvm)
rustc --version         # Rust
go version              # Go
ruby --version          # Ruby (via rbenv)
kitty --version         # Kitty terminal
starship --version      # Starship prompt
```

### Run Neovim health check

```bash
nvim
# Then inside Neovim:
:checkhealth
```

### First Neovim launch

On first launch, LazyVim will automatically:

1. Install lazy.nvim plugin manager
2. Download and install all plugins
3. Install Mason packages (LSP servers, formatters)
4. Install Treesitter parsers

This may take 2-5 minutes. Be patient!

## Encrypted Files

Files with sensitive data are encrypted with age. Current encrypted files:

- `~/.config/gh/gitHubToken.txt` - GitHub token
- `~/.ssh/config` - SSH configuration

To add new encrypted file:

```bash
# Add with encryption
chezmoi add --encrypt ~/.config/sensitive/file.txt

# Verify
chezmoi cat ~/.config/sensitive/file.txt
```

## Script Execution Order

Scripts run in alphabetical order. The naming convention ensures proper dependency order:

### Before scripts (run before files are applied)

| Script                                      | Purpose             |
| ------------------------------------------- | ------------------- |
| `run_once_before_00_install-neovim.sh`      | Install Neovim      |
| `run_once_before_install-git-completion.sh` | Git bash completion |

### After scripts (run after files are applied)

| Script                           | Purpose              | Dependencies              |
| -------------------------------- | -------------------- | ------------------------- |
| `01_install-miniconda.sh`        | Install Miniconda    | None                      |
| `02_install-conda-packages.sh`   | Core conda packages  | 01                        |
| `02b_install-nvm-node.sh`        | Node.js via NVM      | None                      |
| `03_install-rust.sh`             | Rust toolchain       | None                      |
| `04_install-go.sh`               | Go runtime           | None                      |
| `05_install-pnpm.sh`             | pnpm package manager | None                      |
| `06_install-ruby.sh`             | Ruby via rbenv       | 01 (conda for build deps) |
| `07_install-lsd-bat.sh`          | lsd and bat          | None                      |
| `08_install-lazyvim.sh`          | LazyVim dependencies | 01, 02b, 03, 05           |
| `08a_install-starship.sh`        | Starship prompt      | 03 (cargo)                |
| `09_configure-starship.sh`       | Starship config      | 08a                       |
| `10_install-datascience.sh`      | Python data science  | 01                        |
| `11_install-nerd-fonts.sh`       | Nerd Fonts           | None                      |
| `12_install-backup-terminals.sh` | Kitty + Alacritty    | 03 (for Alacritty)        |
| `14_install-desktop-apps.sh`     | Desktop apps         | None (requires sudo)      |
| `15_install-snap-packages.sh`    | Snap packages        | None (requires sudo)      |

## Updating

### Pull latest changes

```bash
# Update from remote
chezmoi update

# Or manually
chezmoi git pull -- --autostash --rebase
chezmoi apply
```

### Push local changes

```bash
# Edit a file
chezmoi edit ~/.bashrc

# Review and apply
chezmoi diff
chezmoi apply

# Commit and push
chezmoi cd
git add -A
git commit -m "Update bashrc"
git push
```

## Cleanup / Fresh Start

To remove all installed software and start fresh:

```bash
# Run cleanup script (interactive)
~/.local/bin/chezmoi-cleanup.sh

# Or remove everything without prompts
~/.local/bin/chezmoi-cleanup.sh --all

# Preview what would be removed
~/.local/bin/chezmoi-cleanup.sh --dry-run
```

After cleanup, to reinstall:

```bash
# Clear script state
chezmoi state delete-bucket --bucket=scriptState

# Re-apply everything
chezmoi apply --verbose

# Reload shell
source ~/.bashrc
```

## Troubleshooting

### "Command not found" after installation

```bash
# Reload shell configuration
source ~/.bashrc

# Or start a new terminal
```

### Neovim plugins not loading

```bash
# Clear Neovim cache and reinstall
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Restart Neovim
nvim
```

### Script didn't run

```bash
# Check script state
chezmoi state dump

# Clear specific script state
chezmoi state delete-bucket --bucket=scriptState

# Re-run
chezmoi apply --verbose
```

### Encrypted file errors

```bash
# Verify key exists
cat ~/.config/chezmoi/age/key.txt

# Check chezmoi config
cat ~/.config/chezmoi/chezmoi.yaml

# Test decryption
chezmoi cat ~/.config/gh/gitHubToken.txt
```

### Permission denied

```bash
# Make scripts executable (if needed)
chmod +x ~/.local/bin/*
```

### Architecture-specific issues

Some packages have architecture-specific builds:

- **x86_64**: Full support for all packages
- **ARM64/aarch64**: Most packages work, some may need building from source

## File Structure

```
~/.local/share/chezmoi/
├── README.md                    # This file
├── chezmoiscripts/              # Installation scripts
│   ├── run_once_before_*.sh     # Pre-file scripts
│   └── run_once_after_*.sh      # Post-file scripts
├── dot_bashrc                   # → ~/.bashrc
├── dot_bash_profile             # → ~/.bash_profile
├── dot_bash_aliases             # → ~/.bash_aliases
├── dot_gitconfig                # → ~/.gitconfig
├── dot_config/                  # → ~/.config/
│   ├── nvim/                    # Neovim (LazyVim)
│   ├── mc/                      # Midnight Commander
│   ├── starship.toml            # Starship prompt
│   ├── kitty/                   # Kitty terminal
│   └── alacritty/               # Alacritty terminal
├── dot_local/
│   └── bin/
│       └── chezmoi-cleanup.sh   # Cleanup utility
└── private_dot_ssh/             # SSH config (encrypted)
```

## Key Bindings

### Neovim (LazyVim)

| Key         | Action              |
| ----------- | ------------------- |
| `Space`     | Leader key          |
| `Space f f` | Find files          |
| `Space f g` | Live grep           |
| `Space e`   | File explorer       |
| `Space l`   | LazyVim menu        |
| `K`         | Hover documentation |
| `gd`        | Go to definition    |
| `gr`        | Find references     |

### Bash Functions

| Command | Action                             |
| ------- | ---------------------------------- |
| `ff`    | Fuzzy find directory and cd        |
| `cenv`  | Fuzzy activate conda environment   |
| `c0`    | Deactivate all conda envs          |
| `cfg`   | Fuzzy cd to ~/.config subdirectory |

## License

Personal dotfiles - feel free to use as inspiration for your own setup.

## Credits

- [chezmoi](https://www.chezmoi.io/) - Dotfiles manager
- [LazyVim](https://www.lazyvim.org/) - Neovim distribution
- [Starship](https://starship.rs/) - Shell prompt
- [Catppuccin](https://github.com/catppuccin) - Color scheme
