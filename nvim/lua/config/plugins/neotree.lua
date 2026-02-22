-- Neo-tree file explorer
require("neo-tree").setup({
    open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
    filesystem = {
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_default",
        filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
        },
    },
    window = {
        width = 35,
        mappings = {
            ["<space>"] = false, -- disable which-key
            ["o"] = { "open" },
            ["h"] = "close_node",
            ["l"] = "open",
        },
    },
    default_component_configs = {
        indent = { indent_size = 2 },
    },
})
