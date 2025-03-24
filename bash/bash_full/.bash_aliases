# ALIAS
# Force grep to always use the color option and show line numbers
# alias sq='squeue --format="%.5i %.9P %.12j %.9u %.5t %.10M %R"'
# alias ns='nvidia-smi'
alias cat='batcat --paging=never'
alias grep='grep --color=auto'
alias gmv="git mv"
alias grm="git rm"
alias mkdir='mkdir -p'
alias h='history'
alias hg='history | grep'
alias nv='nvim'
alias cd..='cd ..'
alias update='sudo apt update'
alias upgrade='sudo apt dist-upgrade'
alias ls='lsd -a --group-dirs=first'
alias ll='lsd -lh --group-dirs=first'
# c: Clear terminal display
alias c='clear'
# Kitty
alias icat="kitten icat"
alias s="kitten ssh"
alias d="kitten diff"
alias sn="kitten ssh neptuno"
alias sN="kitten ssh Neptuno"
alias sj="kitten ssh jupiter"
alias sjr="kitten ssh rootJupiter"

alias wezterm="wezterm start --always-new-process"
alias venvactivate='source $(find . -name "activate" -type f)'
# alias venvactivate='source $(find . -name "activate" -type f -o -path "*/.." -name "activate" -type f)'
# alias sN="wezterm cli spawn --domain-name SSH:Neptuno"
# alias sj="wezterm cli spawn --domain-name SSH:jupiter"
# alias sjr="wezterm cli spawn --domain-name SSH:rootJupiter"
