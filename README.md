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
./Miniconda3-latest-Linux-x86_64.sh
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

- Install mermaid charts

```bash
npm install -g @mermaid-js/mermaid-cli
```

- Install imagemagick

```bash
sudo apt install imagemagick
```

- Install neovim nmp

```bash
npm install neovimp
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
