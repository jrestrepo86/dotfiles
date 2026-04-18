## Chezmoi Architecture

```
chezmoi/
├── dot_bashrc              → ~/.bashrc (lazy-loading shell config)
├── dot_bash_aliases        → ~/.bash_aliases
├── dot_bash_profile        → ~/.bash_profile
├── dot_gitconfig           → ~/.gitconfig
├── chezmoiscripts/         → installation scripts (run once)
├── dot_config/
│   ├── nvim/               → Neovim config (LazyVim-based)
│   │   ├── init.lua
│   │   └── lua/
│   │       ├── config/     → options, keymaps, autocmds, lazy bootstrap
│   │       └── plugins/    → LazyVim plugin overrides
│   ├── alacritty/          → Alacritty terminal config
│   ├── ghostty/            → Ghostty terminal config
│   ├── kitty/              → Kitty terminal config
│   ├── lazygit/            → lazygit config
│   └── starship.toml       → Starship prompt config
├── dot_local/bin/
│   └── chezmoi-cleanup.sh  → removes all installed tools
└── private_dot_ssh/        → SSH config (age-encrypted)
```
