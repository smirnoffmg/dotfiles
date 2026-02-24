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
- **LSP**: nvim-lspconfig with Mason (lua_ls, pylsp, ruff, rust_analyzer, gopls)
- **Completion**: nvim-cmp with LuaSnip
- **Treesitter**: Syntax highlighting and more
- **UI**: Bufferline, Lualine, indent guides, notifications

## Installation

1. Clone this repository to `~/.config/nvim/`
2. Open Neovim - plugins will install automatically
3. Run `:Lazy` to view plugin status

## Key Mappings

- `<leader>` = Space
- `gd` - Go to definition (LSP)
- `K` - Hover (LSP)
- `<leader>vca` - Code actions (LSP)
- `<leader>vrr` - References (LSP)
- `<leader>vrn` - Rename (LSP)
- `<S-h>` / `<S-l>` - Previous/next buffer
- `<leader>bd` - Delete buffer
- `<leader>w` - Save file
- `<leader>q` - Quit
