local refactoring = require("refactoring")
local debug = require("refactoring.debug")
local map = vim.keymap.set

local expr = { expr = true }

local function opts(desc, extra)
    return vim.tbl_extend("force", expr, extra or {}, { desc = desc })
end

-- Every operation returns an operatorfunc string, so normal-mode maps need a
-- textobject appended: "_" is the current line, "iw" the word under the cursor.
map({ "n", "x" }, "<leader>re", refactoring.extract_func, opts("Extract Function"))
map("n", "<leader>ree", function()
    return refactoring.extract_func() .. "_"
end, opts("Extract Function (line)"))
map({ "n", "x" }, "<leader>rf", refactoring.extract_func_to_file, opts("Extract Function To File"))
map({ "n", "x" }, "<leader>rv", refactoring.extract_var, opts("Extract Variable"))
map("n", "<leader>rvv", function()
    return refactoring.extract_var() .. "_"
end, opts("Extract Variable (line)"))
map({ "n", "x" }, "<leader>ri", refactoring.inline_var, opts("Inline Variable"))
map({ "n", "x" }, "<leader>rI", refactoring.inline_func, opts("Inline Function"))

-- Select refactor from menu
map({ "n", "x" }, "<leader>rr", function()
    refactoring.select_refactor()
end, { desc = "Select Refactor" })

-- Debug helpers
map("n", "<leader>rp", function()
    return debug.print_loc({ output_location = "below" })
end, opts("Debug Print Location"))
map("n", "<leader>rd", function()
    return debug.print_var({ output_location = "below" }) .. "iw"
end, opts("Debug Print Variable"))
map("x", "<leader>rd", function()
    return debug.print_var({ output_location = "below" })
end, opts("Debug Print Variable"))
map({ "n", "x" }, "<leader>rc", function()
    return debug.cleanup({ restore_view = true })
end, opts("Debug Clean", { remap = true }))
