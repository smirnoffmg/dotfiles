-- Bufferline Configuration
local map = vim.keymap.set

require("bufferline").setup({
    options = {
        mode = "buffers",
        numbers = "ordinal",
        separator_style = "thin",
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        color_icons = true,
    },
})

-- :bnext walks buffer numbers, which drift out of sync with the displayed order
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })

for i = 1, 9 do
    map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", { desc = "Buffer " .. i })
end
map("n", "<leader>$", "<cmd>BufferLineGoToBuffer -1<cr>", { desc = "Last buffer" })
map("n", "<leader>bp", "<cmd>BufferLinePick<cr>", { desc = "Pick buffer" })
