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
map("n", "<leader>fd", function()
    builtin.diagnostics({ bufnr = 0 })
end, { desc = "Diagnostics (buffer)" })
map("n", "<leader>fD", builtin.diagnostics, { desc = "Diagnostics (workspace)" })

map("n", "<leader>e", function()
    -- %:p:h, not %:h — telescope spawns rg with this as cwd, and a relative one
    -- makes the spawn fail with ENOENT. Unnamed buffers expand to the cwd.
    local dir = vim.fn.expand("%:p:h")
    builtin.find_files({
        cwd = dir,
        prompt_title = "Files in " .. vim.fn.fnamemodify(dir, ":~:."),
    })
end, { desc = "Find Files (buffer dir)" })
