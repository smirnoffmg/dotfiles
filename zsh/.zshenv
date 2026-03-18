# Bootstrap: tell zsh where to find all config files
export ZDOTDIR="$HOME/.config/zsh"

# Cargo — here so non-interactive scripts can find rust tools
. "$HOME/.cargo/env"
