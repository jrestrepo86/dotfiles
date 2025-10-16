# Set up **chezmoi** on a second machine

## 0. Prerequisites

- `git` installed
- If you use **encrypted files** with `age`: copy your **age private key** from machine #1

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

If curl isn't available: sudo apt-get install curl -y (Debian/Ubuntu) or your distro's equivalent.

## 2. Configure chezmoi to use your age key

Create/edit ~/.config/chezmoi/chezmoi.yaml:

```yaml
encryption: age
age:
identities: - ~/.config/chezmoi/age/key.txt
```

If you also configure recipients in YAML on machine #1, include them here too.

## 3. Initialize from your GitHub repo

Use whichever remote you actually use.

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

# Apply (this will also run any run*once*\*.tmpl scripts, e.g., your Miniconda installer)

chezmoi apply --verbose
```

Sandbox test (optional): run scripts into a temporary "fake home" without touching your real $HOME:

```bash
DEST=/tmp/chezmoi-sandbox
rm -rf "$DEST" && mkdir -p "$DEST"
chezmoi apply --include=scripts --destination "$DEST" --verbose
```

## 5. Sanity checks

```bash
chezmoi doctor
```

Confirm an encrypted file deploys correctly (plaintext render from source):

```bash
chezmoi cat ~/.config/gh/gitHubToken.txt | head -c 10 && echo
```

Check private permissions (e.g., SSH):

```bash
stat -c "%a %n" ~/.ssh ~/.ssh/config # expect: 700 ~/.ssh, 600 ~/.ssh/config
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

Encrypted-file errors (age "missing identities/recipients")
Ensure ~/.config/chezmoi/age/key.txt exists and is referenced in chezmoi.yaml (step 2).

"...has changed since chezmoi last wrote it" when you edited a live file
Bring local edits back into the source:

```bash
chezmoi diff ~/.bashrc
chezmoi add ~/.bashrc
chezmoi apply
```

Or merge interactively:

```bash
CHEZMOI*MERGE_TOOL=vimdiff chezmoi merge ~/.bashrc
```

run_once\*... script didn't run
It may have already run. Re-run by editing the script (changes its hash) or reset the state:

```bash
chezmoi state delete-bucket scriptState
chezmoi apply --include=scripts --verbose
```

## 8. Optional tips

Miniconda block in .bashrc: add a safe conditional loader so you don't need conda init to modify your files.

```bash

# ~/.bashrc

CONDA_DIR="$HOME/.local/share/miniconda"
if [ -f "$CONDA_DIR/etc/profile.d/conda.sh" ]; then
. "$CONDA_DIR/etc/profile.d/conda.sh"

# conda activate base # (optional)

elif [ -x "$CONDA_DIR/bin/conda" ]; then
export PATH="$CONDA_DIR/bin:$PATH"
fi
```

Exact/Private attributes: keep sensitive files private (private* prefix) and prune-only when you truly need exact mirrors (exact* prefix for directories).

Use chezmoi cat to view the plaintext a target would receive without opening your editor:

```bash
chezmoi cat ~/.config/gh/gitHubToken.txt
```

