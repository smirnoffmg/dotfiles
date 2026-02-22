-- Telescope Configuration (keymaps defined in plugin spec for lazy loading)
require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<C-u>"] = false,
                ["<C-d>"] = false
            }
        }
    }
})
