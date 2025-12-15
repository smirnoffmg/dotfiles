# Neovim Configuration

Custom Neovim configuration built from scratch, inspired by ThePrimeagen's approach.

## Structure

```
nvim/
├── init.lua                 # Main entry point
└── lua/
    ├── config/
    │   ├── options.lua     # Neovim settings
    │   ├── keymaps.lua     # Key mappings
    │   ├── autocmds.lua    # Autocmds
    │   ├── lazy.lua        # Plugin manager setup
    │   └── plugins/        # Plugin configurations
    └── plugins/
        └── init.lua        # Plugin specifications
```

## Features

- **Plugin Manager**: lazy.nvim
- **Colorscheme**: Catppuccin (Macchiato)
- **LSP**: nvim-lspconfig with Mason
- **Completion**: nvim-cmp with LuaSnip
- **Treesitter**: Syntax highlighting and more
- **Telescope**: File navigation and search
- **UI**: Bufferline, Lualine, and more

## Installation

1. Clone this repository to `~/.config/nvim/`
2. Open Neovim - plugins will install automatically
3. Run `:Lazy` to view plugin status

## Key Mappings

- `<leader>` = Space
- `<leader>ff` - Find files (Telescope)
- `<leader>fg` - Live grep (Telescope)
- `gd` - Go to definition (LSP)
- `K` - Hover (LSP)
- `<leader>vca` - Code actions (LSP)
