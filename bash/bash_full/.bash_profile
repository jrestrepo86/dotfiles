# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
##-----------------------------------------------------
## Path settings
##-----------------------------------------------------
## bin
PATH="$HOME/.local/bin:$PATH"
## cargo
PATH="$HOME/.cargo/bin:$PATH"
source "$HOME/.cargo/env"
## go
PATH="$HOME/.local/go/bin:$PATH"
export GOPATH="$HOME/.local/go"
## miniconda
CONDA_PATH="$HOME/.local/share/miniconda/bin"
PATH="$CONDA_PATH:$PATH"

## pnpm
export PNPM_HOME="/home/jrestrepo/.local/share/pnpm"
PATH="$PNPM_HOME:$PATH"
export PATH
##-----------------------------------------------------
## Editor
##-----------------------------------------------------
export EDITOR=nvim
export VISUAL="$EDITOR"
##-----------------------------------------------------
## Git
##-----------------------------------------------------
# Load git completion, handling symlinks properly
GIT_COMPLETION="$HOME/.git-completion.bash"

if [[ -e "$GIT_COMPLETION" ]]; then
  if [[ -L "$GIT_COMPLETION" ]]; then
    # Resolve symlink to its actual path
    GIT_COMPLETION=$(readlink -f "$GIT_COMPLETION")
  fi

  if [[ -f "$GIT_COMPLETION" && -r "$GIT_COMPLETION" ]]; then
    # shellcheck disable=SC1090  # Can't verify dynamic source
    if source "$GIT_COMPLETION"; then
      : # Successfully loaded
    else
      echo "Note: Git completion loaded but returned error" >&2
    fi
  else
    echo "Warning: Git completion file exists but is not readable" >&2
  fi
else
  # Fallback to system installation if available
  SYSTEM_GIT_COMPLETION="/usr/share/bash-completion/completions/git"
  if [[ -f "$SYSTEM_GIT_COMPLETION" && -r "$SYSTEM_GIT_COMPLETION" ]]; then
    # shellcheck disable=SC1090
    source "$SYSTEM_GIT_COMPLETION"
  fi
fi
# Token file locations (using proper path expansion)
GITHUB_TOKEN_FILE="$HOME/Dropbox/scripts/tokens/gitHubToken.txt"
BITBUCKET_TOKEN_FILE="$HOME/Dropbox/scripts/tokens/bitBucketToken.txt"
# Secure token handling functions
gtoken() {
  if [[ -r "$GITHUB_TOKEN_FILE" ]]; then
    cat "$GITHUB_TOKEN_FILE"
    if command -v xclip &>/dev/null; then
      xclip -sel clip <"$GITHUB_TOKEN_FILE"
    else
      echo "xclip not found - token not copied to clipboard" >&2
    fi
  else
    echo "GitHub token file not found or not readable" >&2
    return 1
  fi
}

btoken() {
  if [[ -r "$BITBUCKET_TOKEN_FILE" ]]; then
    cat "$BITBUCKET_TOKEN_FILE"
    if command -v xclip &>/dev/null; then
      xclip -sel clip <"$BITBUCKET_TOKEN_FILE"
    else
      echo "xclip not found - token not copied to clipboard" >&2
    fi
  else
    echo "Bitbucket token file not found or not readable" >&2
    return 1
  fi
}
# Export only if needed by other scripts
# export GITHUB_TOKEN_FILE BITBUCKET_TOKEN_FILE
##-----------------------------------------------------
## Functions
##-----------------------------------------------------
## cdf() - cd into the directory of the selected file
cdf() {
  local file
  local dir
  file=$(fzf -e -q "$*") && dir=$(dirname "$file") && cd "$dir" || return
}
## cdh() - cd from home
cdh() {
  local file
  local dir
  file=$(locate ~ | fzf -e -q "$*") && dir=$(dirname "$file") && cd "$dir" || return
}
## find file
ff() {
  local dir
  dir=$(find "${1:-.}" -path '*/\.*' -prune \
    -o -type d -print 2>/dev/null | fzf +m) &&
    cd "$dir" || return
}

## matlab
function matlab() {
  export GTK_PATH='/usr/lib/x86_64-linux-gnu/gtk-2.0'
  command matlab "$@"
}
##-----------------------------------------------------
## Alias
##-----------------------------------------------------
## Own alias
# Load .bash_aliases if it exists (even if it's a symlink)
if [ -f ~/.bash_aliases ] || [ -L ~/.bash_aliases ]; then
  # shellcheck disable=SC1090
  . ~/.bash_aliases
fi

##-----------------------------------------------------
## Bash completition
##-----------------------------------------------------
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    # shellcheck disable=SC1091
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    # shellcheck disable=SC1091
    . /etc/bash_completion
  fi
fi
##-----------------------------------------------------
# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# !! Contents within this block are managed by juliaup !!
case ":$PATH:" in
*:/home/jrestrepo/.juliaup/bin:*) ;;

*)
  export PATH=/home/jrestrepo/.juliaup/bin${PATH:+:${PATH}}
  ;;
esac

# llama autocomplete
_complete_ollama() {
  local cur prev words cword
  _init_completion -n : || return

  if [[ $cword -eq 1 ]]; then
    # Safe fixed list of commands - doesn't need mapfile
    local -a commands=(
      serve create show run push pull list ps cp rm help
    )
    # Use printf to avoid word splitting
    mapfile -t COMPREPLY < <(compgen -W "${commands[*]}" -- "$cur")
  elif [[ $cword -eq 2 ]]; then
    case "$prev" in
    run | show | cp | rm | push | list)
      local -a models
      # Use mapfile to safely read command output into array
      mapfile -t models < <(ollama list 2>/dev/null | tail -n +2 | cut -d $'\t' -f 1)
      # Safely generate completions
      mapfile -t COMPREPLY < <(compgen -W "${models[*]}" -- "$cur")
      __ltrim_colon_completions "$cur"
      ;;
    esac
  fi
}
complete -F _complete_ollama ollama

# conda activate base
activate_base() {
  # Activate conda base environment with proper error handling
  local activate_script="$CONDA_PATH/activate"

  if [[ -f "$activate_script" ]]; then
    source "$activate_script" base || {
      echo "Error: Failed to activate conda base environment" >&2
      return 1
    }
  else
    echo "Error: Conda activate script not found at $activate_script" >&2
    echo "Check your miniconda installation or update the path" >&2
    return 1
  fi
}
# if ! activate_base; then
#   # Handle activation failure
#   echo "Conda activation failed, proceeding without it"
# fi

# # Auto-Warpify
# # printf ''
# if [ -n "${PS1:-}" ]; then
#   printf '^[P$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "bash", "uname": "Linux" }}<9c>'
# fi

export ML_LOGGER_ROOT="http://localhost:8081"
export ML_LOGGER_USER=$USER
