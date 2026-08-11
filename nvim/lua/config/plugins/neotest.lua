local neotest = require("neotest")
local map = vim.keymap.set

-- every built-in consumer reports where the tests live: virtual text and diagnostics
-- land in the test file, and quickfix only opens for failures that carry an error
-- location (a panic or a build error carries none). A run started from a solution
-- buffer therefore finishes with nothing on screen, so report the outcome here.
local function report(client)
    client.listeners.results = function(adapter_id, results, partial)
        if partial then
            return
        end
        local tree = client:get_position(nil, { adapter = adapter_id })
        if not tree then
            return
        end

        local counts = { passed = 0, failed = 0, skipped = 0 }
        local failed_outside_tests = false
        for pos_id, result in pairs(results) do
            local node = tree:get_key(pos_id)
            if node and node:data().type == "test" and counts[result.status] then
                counts[result.status] = counts[result.status] + 1
            elseif result.status == "failed" then
                failed_outside_tests = true
            end
        end

        local total = counts.passed + counts.failed + counts.skipped
        if total == 0 and not failed_outside_tests then
            return
        end
        local failed = counts.failed > 0 or total == 0

        local summary = total > 0
                and string.format("%d passed, %d failed, %d skipped", counts.passed, counts.failed, counts.skipped)
            or "run failed before any test reported"

        vim.schedule(function()
            vim.notify(
                failed and summary .. "  (<leader>tp for output)" or summary,
                failed and vim.log.levels.ERROR or vim.log.levels.INFO,
                { title = "neotest" }
            )
        end)
    end
end

neotest.setup({
    consumers = { report = report },
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
