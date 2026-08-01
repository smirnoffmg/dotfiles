local neotest = require("neotest")
local map = vim.keymap.set

neotest.setup({
    -- running from a non-test buffer leaves no visible trace otherwise: diagnostics
    -- land in the test file, and the summary tree stays collapsed
    quickfix = { open = true },
    status = { virtual_text = true },
    adapters = {
        require("neotest-golang")({
            go_test_args = { "-v", "-race", "-count=1" },
            -- strips terminal escape codes gopls/go test emit into the output panel
            sanitize_output = true,
        }),
        require("neotest-python")({
            -- python is left unset on purpose: the adapter then resolves the
            -- project's .venv, which is how uv projects are laid out here
            dap = { justMyCode = false },
        }),
    },
})

-- neotest only knows positions inside test files; from a solution buffer there is
-- no nearest test, so fall back to the package/directory the file belongs to
local function in_test_file()
    local name = vim.fn.expand("%:t")
    return name:match("_test%.go$") ~= nil or name:match("^test_.*%.py$") ~= nil or name:match("_test%.py$") ~= nil
end

local function package_dir()
    return vim.fn.expand("%:p:h")
end

map("n", "<leader>tt", function()
    if in_test_file() then
        neotest.run.run()
    else
        neotest.run.run(package_dir())
    end
end, { desc = "Test nearest (package outside _test.go)" })
map("n", "<leader>tf", function()
    neotest.run.run(in_test_file() and vim.fn.expand("%:p") or package_dir())
end, { desc = "Test file (package outside _test.go)" })
map("n", "<leader>ta", function()
    neotest.run.run({ suite = true })
end, { desc = "Test suite" })
map("n", "<leader>tl", function()
    neotest.run.run_last()
end, { desc = "Test last" })
map("n", "<leader>tw", function()
    if in_test_file() then
        neotest.watch.toggle()
    else
        neotest.watch.toggle(package_dir())
    end
end, { desc = "Test watch (package outside _test.go)" })
map("n", "<leader>tW", function()
    neotest.watch.toggle(in_test_file() and vim.fn.expand("%:p") or package_dir())
end, { desc = "Test watch file (package outside _test.go)" })
map("n", "<leader>tx", function()
    neotest.run.stop()
end, { desc = "Test stop" })

map("n", "<leader>ts", function()
    neotest.summary.toggle()
end, { desc = "Test summary" })
map("n", "<leader>to", function()
    neotest.output.open({ enter = true })
end, { desc = "Test output" })
map("n", "<leader>tp", function()
    neotest.output_panel.toggle()
end, { desc = "Test output panel" })

map("n", "<leader>td", function()
    neotest.run.run({ strategy = "dap" })
end, { desc = "Debug nearest test" })
map("n", "<leader>tD", function()
    neotest.run.run_last({ strategy = "dap" })
end, { desc = "Debug last test" })
