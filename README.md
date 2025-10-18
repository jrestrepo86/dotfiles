# Set Up CHEZMOI on a Second Machine

## 0. Prerequisites

- `git` installed
- If you use **encrypted files** with `age`: you need an age key pair

### First time setup: Generate age keys

If you don't have age keys yet, generate them on machine #1:

```bash
# Install age
# Debian/Ubuntu:
sudo apt-get install age -y
# macOS:
brew install age
# Or download from: https://github.com/FiloSottile/age/releases

# Generate key pair
mkdir -p ~/.config/chezmoi/age
age-keygen -o ~/.config/chezmoi/age/key.txt
chmod 600 ~/.config/chezmoi/age/key.txt

# View your public key (you'll need this for chezmoi.yaml)
age-keygen -y ~/.config/chezmoi/age/key.txt
```

The output will show:

- **Private key**: saved to `~/.config/chezmoi/age/key.txt` (keep this secret!)
- **Public key**: displayed as `age1...` (use this in `recipients`)

### Copy existing keys to machine #2

If you already have keys on machine #1:

```bash
# On machine #1 (source)
cat ~/.config/chezmoi/age/key.txt
```

```bash
# On machine #2 (target)
mkdir -p ~/.config/chezmoi/age
$EDITOR ~/.config/chezmoi/age/key.txt   # paste the contents, save
chmod 600 ~/.config/chezmoi/age/key.txt
```

## 1. Install chezmoi

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
hash -r
chezmoi --version
```

> **Note:** If `curl` isn't available, install it first:
> `sudo apt-get install curl -y` (Debian/Ubuntu) or your distro's equivalent.

## 2. Configure chezmoi to use your age key

Create/edit `~/.config/chezmoi/chezmoi.yaml`:

```yaml
encryption: age
age:
  identities:
    - ~/.config/chezmoi/age/key.txt
  recipients:
    - age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

> **Note:** Replace the `age1...` value with your actual age **public key** (the recipient). You can find it on machine #1 by running:
>
> ```bash
> # Extract public key from private key
> age-keygen -y ~/.config/chezmoi/age/key.txt
> ```
>
> The `identities` section points to your **private key** (for decryption), while `recipients` contains your **public key** (for encryption when adding new files).

## 3. Initialize from your GitHub repo

Use whichever remote URL you actually use:

```bash
# HTTPS
chezmoi init https://github.com/jrestrepo86/dotfiles.git

# or SSH
chezmoi init git@github.com:jrestrepo86/dotfiles.git
```

## 4. Preview and apply

```bash
# See what would be written/changed
chezmoi diff

# Apply (this will also run any run_once_*.tmpl scripts, e.g., your Miniconda installer)
chezmoi apply --verbose
```

### Sandbox test (optional)

Run scripts into a temporary "fake home" without touching your real `$HOME`:

```bash
DEST=/tmp/chezmoi-sandbox
rm -rf "$DEST" && mkdir -p "$DEST"
chezmoi apply --include=scripts --destination "$DEST" --verbose
```

## 5. Sanity checks

```bash
# Check for configuration issues
chezmoi doctor
```

Confirm an encrypted file deploys correctly (plaintext render from source):

```bash
chezmoi cat ~/.config/gh/gitHubToken.txt | head -c 10 && echo
```

Check private permissions (e.g., SSH):

```bash
stat -c "%a %n" ~/.ssh ~/.ssh/config
# Expected: 700 ~/.ssh, 600 ~/.ssh/config
```

## 6. Daily workflow on machine #2

```bash
# Edit via chezmoi so the source stays in sync
chezmoi edit ~/.bashrc
chezmoi edit ~/.config/nvim/init.lua

# Preview → apply → commit → push
chezmoi diff && chezmoi apply
chezmoi cd && git add -A && git commit -m "Update on machine #2" && git push
```

## 7. Quick troubleshooting

### Encrypted-file errors (age "missing identities/recipients")

Ensure `~/.config/chezmoi/age/key.txt` exists and is referenced in `chezmoi.yaml` (step 2).

### "...has changed since chezmoi last wrote it" when you edited a live file

Bring local edits back into the source:

```bash
chezmoi diff ~/.bashrc
chezmoi add ~/.bashrc
chezmoi apply
```

Or merge interactively:

```bash
CHEZMOI_MERGE_TOOL=vimdiff chezmoi merge ~/.bashrc
```

### `run_once_*` script didn't run

It may have already run. Re-run by editing the script (changes its hash) or reset the state:

```bash
chezmoi state delete-bucket scriptState
chezmoi apply --include=scripts --verbose
```

## 8. Optional tips

### Miniconda block in `.bashrc`

Add a safe conditional loader so you don't need `conda init` to modify your files:

```bash
# ~/.bashrc
CONDA_DIR="$HOME/.local/share/miniconda"
if [ -f "$CONDA_DIR/etc/profile.d/conda.sh" ]; then
    . "$CONDA_DIR/etc/profile.d/conda.sh"
    # conda activate base  # (optional)
elif [ -x "$CONDA_DIR/bin/conda" ]; then
    export PATH="$CONDA_DIR/bin:$PATH"
fi
```

### Exact/Private attributes

- Keep sensitive files private with the `private_*` prefix
- Use `exact_*` prefix for directories when you need exact mirrors (prunes unmanaged files)

### View plaintext without editing

Use `chezmoi cat` to view the plaintext a target would receive:

```bash
chezmoi cat ~/.config/gh/gitHubToken.txt
```

## 9. Pull updates from other machines

When you've made changes on another machine:

```bash
# Pull latest changes from remote
chezmoi update

# Or manually:
chezmoi git pull -- --autostash --rebase && chezmoi apply
```

---

## Quick Reference

| Command               | Description                     |
| --------------------- | ------------------------------- |
| `chezmoi init <repo>` | Clone dotfiles repo             |
| `chezmoi diff`        | Preview changes                 |
| `chezmoi apply`       | Apply changes to home directory |
| `chezmoi edit <file>` | Edit managed file               |
| `chezmoi add <file>`  | Add file to chezmoi             |
| `chezmoi update`      | Pull and apply changes          |
| `chezmoi cd`          | Navigate to source directory    |
| `chezmoi doctor`      | Diagnose configuration issues   |
| `chezmoi cat <file>`  | View target file content        |
