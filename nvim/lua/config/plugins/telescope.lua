local telescope = require("telescope")
local builtin = require("telescope.builtin")
local map = vim.keymap.set

telescope.setup({
    defaults = {
        sorting_strategy = "ascending",
        layout_config = {
            horizontal = { prompt_position = "top" },
        },
    },
    extensions = {
        fzf = {},
    },
})

telescope.load_extension("fzf")

-- Symbol search
map("n", "<leader>ds", builtin.lsp_document_symbols, { desc = "Document Symbols" })
map("n", "<leader>dS", builtin.lsp_dynamic_workspace_symbols, { desc = "Workspace Symbols" })

-- File/text pickers
map("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
map("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
map("n", "<leader>fo", builtin.oldfiles, { desc = "Recent Files" })
