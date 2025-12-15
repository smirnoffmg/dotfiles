-- Lualine Configuration
local colorscheme = vim.g.colors_name or "default"
require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = colorscheme == "catppuccin" and "catppuccin" or "auto",
        component_separators = {
            left = "|",
            right = "|"
        },
        section_separators = {
            left = "",
            right = ""
        }
    },
    sections = {
        lualine_a = {"mode"},
        lualine_b = {"branch", "diff", "diagnostics"},
        lualine_c = {"filename"},
        lualine_x = {"encoding", "fileformat", "filetype"},
        lualine_y = {"progress"},
        lualine_z = {"location"}
    }
})
