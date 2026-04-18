# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). Files here are templates/sources that chezmoi applies to the home directory. The `dot_` prefix maps to `.` in the home directory (e.g., `dot_bashrc` → `~/.bashrc`).

## Rules

- Write in plain, clear language
- Ask clarifying questions before making assumptions
- When you are unsure, say so

## Key chezmoi Commands

```bash
# Preview what would change
chezmoi diff

# Apply changes to home directory
chezmoi apply

# Apply with verbose output
chezmoi apply --verbose

# Edit a managed file (opens source, then you apply)
chezmoi edit ~/.bashrc

# Pull updates from remote and apply
chezmoi update

# Force re-run all scripts (clear script state first)
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply --verbose
```

## File Naming Conventions

| Prefix/Suffix          | Meaning                                                  |
| ---------------------- | -------------------------------------------------------- |
| `dot_`                 | Maps to `.` in home directory                            |
| `private_dot_`         | Same as `dot_` but file permissions are restricted       |
| `run_once_before_*.sh` | Runs once before files are applied                       |
| `run_once_after_*.sh`  | Runs once after files are applied, in alphabetical order |

Scripts in `chezmoiscripts/` are numbered to enforce dependency order (e.g., `00_`, `01_`, etc.).

## Architecture

For architecture see @.claude/docs/chezmoi_architecture.md
Modify this file if architecture changes

## Encryption

Sensitive files (SSH config, tokens) are encrypted with `age`. Requires `~/.config/chezmoi/chezmoi.yaml` with the age key path configured. Without the key, encrypted files will fail to decrypt on `chezmoi apply`.

## Installation Script Order

Scripts in `chezmoiscripts/` run alphabetically. The numbered prefix (`00_` through `16_`) ensures dependencies are met:

- `00` Miniconda → `01` conda packages → `10` starship (needs cargo from `03` Rust) → `09` LazyVim (needs Node from `02`, cargo from `03`, pnpm from `05`)

## Shell Config Design

`dot_bashrc` uses lazy-loading for slow tools to keep shell startup fast:

- **NVM**: wrapped functions (`nvm`, `node`, `npm`, `npx`) that initialize NVM on first use (~500ms saved)
- **rbenv**: lazy-loaded similarly (~200-500ms saved)
- **conda**: fully initialized (required for `python` to work immediately)

Custom bash functions defined in `dot_bashrc` or `dot_bash_aliases`:

- `ff` — fuzzy find directory and cd into it
- `cenv` — fuzzy select and activate a conda environment
- `c0` — deactivate all conda environments
- `cfg` — fuzzy cd to a `~/.config` subdirectory
- `gtoken` / `btoken` — print GitHub/Bitbucket token (also copies to clipboard via xclip)

## Neovim Config

Based on [LazyVim](https://www.lazyvim.org/). Plugin customizations live in `dot_config/nvim/lua/plugins/`. Key plugins added beyond LazyVim defaults: avante (AI), conform (formatting), nvim-lint, mason, supermaven/tabnine (completion), noice (UI), neo-tree, multicursor.

## References

- [chezmoi documentation](https://www.chezmoi.io/)
