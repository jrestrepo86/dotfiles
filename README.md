# Dot Files Management

## Using GNU Stow

```bash
# Simulate linking without making changes
stow -nvt ~ folder

# Install package
stow -vt ~ folder

# Uninstall package
stow -Dvt ~ folder
```

[Reference](https://www.youtube.com/watch?v=CFzEuBGPPPg&t=1794s)

## Miniconda Installation

```bash
# Download installer
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# Make executable
chmod +x Miniconda3-latest-Linux-x86_64.sh

# Run installer (follow prompts)
./Miniconda3-latest-Linux-x86_64.sh -b -p ~/.local/share/miniconda
```

## Node.js Version Manager (nvm)

- [nvm](https://github.com/nvm-sh/nvm)

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# Reload shell after installation
exec bash
```

## Kitty Terminal Setup

- [Configuration reference](https://github.com/ttys3/my-kitty-config/tree/main)

### Set as default terminal emulator

```bash
sudo update-alternatives --install \
 /usr/bin/x-terminal-emulator x-terminal-emulator $(which kitty) 50
sudo update-alternatives --config x-terminal-emulator
```

## Bash Improvements

### Install modern tools

```bash
# Better `ls` alternative
sudo snap install lsd --devmode

# Better `cat` alternative
sudo apt install bat

# fzf
sudo apt install fzf
```

## Add Git completion

```bash
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
mv git-completion.bash ~/.git-completion.bash
```

## Django Development

- [django-browser-reload](https://github.com/adamchainz/django-browser-reload?tab=readme-ov-file)

```bash
pip install django-browser-reload
```

## LazyVim Setup

- Install cargo

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

- Install Tree-sitter CLI (required for LazyVim)

```bash
cargo install --locked tree-sitter-cli
```

- Install mermaid charts (mejor instalar por pnpm)

```bash
npm install -g pnpm@latest-10
pnpm install -g @mermaid-js/mermaid-cli
```

- Install imagemagick

```bash
sudo apt install imagemagick
```

- Install neovim nmp

```bash
npm install neovim
```

- Install pynvim

```bash
pip install pynvim
```

- Install neovim ruby gem

```bash
sudo gem install neovim
```

## Midnight Commander Configuration

- Open files with Neovim using Enter
- Press F9 → Utilities → Edit Extension File

Add these lines at the end:

```ini
Open=%var{EDITOR:nvim} %f
View=%var{EDITOR:nvim} %f
```

## Dotfyles

- [link](https://dotfyle.com/)

- cargo

```
bash
# Set custom installation directories
export CARGO_HOME="$HOME/.local/share/cargo"
export RUSTUP_HOME="$HOME/.local/share/rustup"

# Install Rust (Cargo included) to custom path
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Add Cargo to current PATH
export PATH="$CARGO_HOME/bin:$PATH"

# (Optional) Add to shell config for future sessions
echo 'export CARGO_HOME="$HOME/.local/share/cargo"' >> ~/.bashrc
echo 'export RUSTUP_HOME="$HOME/.local/share/rustup"' >> ~/.bashrc
echo 'export PATH="$HOME/.local/share/cargo/bin:$PATH"' >> ~/.bashrc
```

- pnpm

```
bash
# Set installation path
export PNPM_HOME="$HOME/.local/share/pnpm"
mkdir -p "$PNPM_HOME"

# Download and run the pnpm installer
curl -fsSL https://get.pnpm.io/install.sh | env PNPM_HOME="$PNPM_HOME" SHELL="$(which sh)" sh -

# Add PNPM to current PATH
export PATH="$PNPM_HOME:$PATH"

# (Optional) Add to shell config for future sessions
echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> ~/.bashrc
echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.bashrc
```

- nvm

```
bash
# Set target installation path
export NVM_DIR="$HOME/.local/share/nvm"
mkdir -p "$NVM_DIR"

# Install nvm to that location
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | NVM_DIR="$NVM_DIR" bash

# Add to shell config for future sessions
echo 'export NVM_DIR="$HOME/.local/share/nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

# For current shell session
export NVM_DIR="$HOME/.local/share/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```
