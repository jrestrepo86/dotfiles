#!/usr/bin/env bash

set -eou pipefail

read -p "sesion name: " session

#kitty @ ls | ./kitty-convert-dump.py > session.conf

kitty @ ls | $HOME/.config/kitty/kitty-convert-dump.py >$HOME/.config/kitty/sessions/${session}.conf

echo "kitty session saved"

echo
read -r -p "Press Enter to exit"
echo ""
