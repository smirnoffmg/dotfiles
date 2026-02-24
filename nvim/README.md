# Neovim Configuration

Custom Neovim configuration built from scratch, inspired by ThePrimeagen's approach.

## Structure

```
nvim/
├── init.lua                          # Main entry point
└── lua/
    ├── config/
    │   ├── options.lua               # Neovim settings
    │   ├── keymaps.lua               # Key mappings
    │   ├── autocmds.lua              # Autocommands
    │   ├── lazy.lua                  # Plugin manager bootstrap
    │   └── plugins/
    │       ├── bufferline.lua        # Bufferline config
    │       ├── cmp.lua               # Completion config
    │       ├── lsp.lua               # LSP servers & keymaps
    │       ├── lualine.lua           # Statusline config
    │       └── treesitter.lua        # Treesitter config
    └── plugins/
        └── init.lua                  # Plugin specifications
```

## Plugins

| Category       | Plugin                                                                          | Description                                            |
| -------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------ |
| Plugin Manager | [lazy.nvim](https://github.com/folke/lazy.nvim)                                 | Plugin manager (bootstrapped in `lazy.lua`)            |
| Colorscheme    | [catppuccin](https://github.com/catppuccin/nvim)                                | Catppuccin Macchiato theme                             |
| LSP            | [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)                      | LSP configuration (Neovim 0.11+ `vim.lsp.config` API)  |
| LSP            | [mason.nvim](https://github.com/mason-org/mason.nvim)                           | Portable package manager for LSP servers               |
| LSP            | [mason-lspconfig](https://github.com/mason-org/mason-lspconfig.nvim)            | Bridge between Mason and lspconfig                     |
| Completion     | [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)                                 | Completion engine (LSP, buffer, path, snippet sources) |
| Snippets       | [LuaSnip](https://github.com/L3MON4D3/LuaSnip)                                  | Snippet engine                                         |
| Snippets       | [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)            | VS Code-style snippet collection                       |
| Treesitter     | [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)           | Syntax highlighting, text objects, and more            |
| UI             | [bufferline.nvim](https://github.com/akinsho/bufferline.nvim)                   | Buffer tab bar                                         |
| UI             | [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)                    | Statusline                                             |
| UI             | [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)             | File type icons                                        |
| UI             | [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | Indentation guides with scope highlighting             |
| UI             | [nvim-notify](https://github.com/rcarriga/nvim-notify)                          | Notification manager                                   |
| Git            | [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)                     | Git decorations and hunk actions                       |
| Editing        | [Comment.nvim](https://github.com/numToStr/Comment.nvim)                        | Toggle comments (`gc` / `gcc`)                         |
| Editing        | [nvim-autopairs](https://github.com/windwp/nvim-autopairs)                      | Auto-close brackets/quotes (integrated with nvim-cmp)  |
| Utility        | [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)                        | Lua utility library                                    |

### LSP Servers

Installed automatically via Mason (deferred to avoid blocking startup):

- **lua_ls** — Lua
- **pylsp** — Python (hover, completions, diagnostics)
- **ruff** — Python (linting/formatting; hover disabled in favor of pylsp)
- **rust_analyzer** — Rust
- **gopls** — Go

## Installation

1. Clone this repository to `~/.config/nvim/`
2. Open Neovim — plugins install automatically via lazy.nvim
3. LSP servers install in the background via Mason
4. Run `:Lazy` to view plugin status, `:Mason` for server status

## Key Mappings

`<leader>` = Space

### General

| Key                       | Mode   | Action                              |
| ------------------------- | ------ | ----------------------------------- |
| `jk` / `jj`               | Insert | Exit insert mode                    |
| `<Esc>`                   | Normal | Clear search highlight              |
| `Y`                       | Normal | Yank to end of line                 |
| `J`                       | Normal | Join lines (keep cursor position)   |
| `p`                       | Visual | Paste without yanking replaced text |
| `<leader>w` / `<leader>W` | Normal | Save file / Save all                |
| `<leader>q` / `<leader>Q` | Normal | Quit / Force quit all               |

### Navigation

| Key               | Mode   | Action                                 |
| ----------------- | ------ | -------------------------------------- |
| `<C-h/j/k/l>`     | Normal | Navigate windows                       |
| `<C-d>` / `<C-u>` | Normal | Scroll down/up (centered)              |
| `n` / `N`         | Normal | Next/previous search result (centered) |
| `<S-h>` / `<S-l>` | Normal | Previous/next buffer                   |

### Windows & Buffers

| Key                         | Mode   | Action                             |
| --------------------------- | ------ | ---------------------------------- |
| `<leader>wc`                | Normal | Close window                       |
| `<C-Up/Down>`               | Normal | Resize window height               |
| `<C-Left/Right>`            | Normal | Resize window width                |
| `<leader>bd` / `<leader>bD` | Normal | Delete buffer / Delete all buffers |

### Editing

| Key               | Mode                   | Action                         |
| ----------------- | ---------------------- | ------------------------------ |
| `<A-j>` / `<A-k>` | Normal, Insert, Visual | Move line(s) down/up           |
| `<` / `>`         | Visual                 | Indent and stay in visual mode |

### LSP

| Key           | Mode   | Action                   |
| ------------- | ------ | ------------------------ |
| `gd`          | Normal | Go to definition         |
| `K`           | Normal | Hover documentation      |
| `<C-h>`       | Insert | Signature help           |
| `<leader>vca` | Normal | Code actions             |
| `<leader>vrr` | Normal | References               |
| `<leader>vrn` | Normal | Rename symbol            |
| `<leader>vws` | Normal | Workspace symbol search  |
| `[d` / `]d`   | Normal | Previous/next diagnostic |
| `<leader>cd`  | Normal | Line diagnostics (float) |

### Toggles

| Key          | Action                  |
| ------------ | ----------------------- |
| `<leader>uw` | Toggle word wrap        |
| `<leader>us` | Toggle spell check      |
| `<leader>un` | Toggle line numbers     |
| `<leader>ur` | Toggle relative numbers |

### Quick Access

| Key          | Action                        |
| ------------ | ----------------------------- |
| `<leader>vc` | Edit Neovim config directory  |
| `<leader>vp` | Edit Neovim plugins directory |
