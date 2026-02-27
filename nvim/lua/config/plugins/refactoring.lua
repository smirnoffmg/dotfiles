local refactoring = require("refactoring")
local map = vim.keymap.set

refactoring.setup({})

local expr = { expr = true }

-- Refactoring operations (Lua API with expr = true, as required by the README)
map({ "n", "x" }, "<leader>re", function() return refactoring.refactor("Extract Function") end,
    vim.tbl_extend("force", expr, { desc = "Extract Function" }))
map({ "n", "x" }, "<leader>rf", function() return refactoring.refactor("Extract Function To File") end,
    vim.tbl_extend("force", expr, { desc = "Extract Function To File" }))
map({ "n", "x" }, "<leader>rv", function() return refactoring.refactor("Extract Variable") end,
    vim.tbl_extend("force", expr, { desc = "Extract Variable" }))
map({ "n", "x" }, "<leader>ri", function() return refactoring.refactor("Inline Variable") end,
    vim.tbl_extend("force", expr, { desc = "Inline Variable" }))
map("n", "<leader>rI", function() return refactoring.refactor("Inline Function") end,
    vim.tbl_extend("force", expr, { desc = "Inline Function" }))
map({ "n", "x" }, "<leader>rb", function() return refactoring.refactor("Extract Block") end,
    vim.tbl_extend("force", expr, { desc = "Extract Block" }))
map({ "n", "x" }, "<leader>rbf", function() return refactoring.refactor("Extract Block To File") end,
    vim.tbl_extend("force", expr, { desc = "Extract Block To File" }))

-- Select refactor from menu
map({ "n", "x" }, "<leader>rr", function() refactoring.select_refactor() end,
    { desc = "Select Refactor" })

-- Debug helpers
map("n", "<leader>rp", function() refactoring.debug.printf({ below = false }) end,
    { desc = "Debug Printf" })
map({ "x", "n" }, "<leader>rd", function() refactoring.debug.print_var() end,
    { desc = "Debug Print Variable" })
map("n", "<leader>rc", function() refactoring.debug.cleanup({}) end,
    { desc = "Debug Clean" })
