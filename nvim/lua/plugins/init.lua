-- Custom plugins configuration
-- Add your plugins here
return { -- Catppuccin colorscheme for consistent theming
{
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "macchiato",
        integrations = {
            cmp = true,
            gitsigns = true,
            treesitter = true,
            notify = true,
            mini = true,
            native_lsp = {
                enabled = true
            }
        }
    }
}, -- Configure LazyVim to use catppuccin
{
    "LazyVim/LazyVim",
    opts = {
        colorscheme = "catppuccin"
    }
}}

