# Dotfiles

Personal configuration files for macOS/Linux development environment.

## Overview

This repository contains configurations for:

| Tool          | Description                            | Theme                |
| ------------- | -------------------------------------- | -------------------- |
| **Alacritty** | GPU-accelerated terminal emulator      | Catppuccin Macchiato |
| **Neovim**    | Modern Vim-based text editor (LazyVim) | Catppuccin Macchiato |
| **tmux**      | Terminal multiplexer                   | Catppuccin Macchiato |

## Installation

### Initial Setup

This repository uses git submodules for tmux plugins. When cloning, use:

```bash
git clone --recurse-submodules <repository-url> ~/.config
```

If you've already cloned without submodules:

```bash
git submodule update --init --recursive
```

### Tmux Plugins

Quick update command:
```bash
./tmux/update-plugins.sh
```


