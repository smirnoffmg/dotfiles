local dap = require("dap")
local dapui = require("dapui")
local dapgo = require("dap-go")
local dappython = require("dap-python")
local map = vim.keymap.set

dapgo.setup()
-- debugpy runs from its own mason venv; the debuggee still runs under the
-- project interpreter, which dap-python resolves per launch
local mason_root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
dappython.setup(mason_root .. "/packages/debugpy/venv/bin/python")
dapui.setup()

for _, event in ipairs({ "attach", "launch" }) do
    dap.listeners.before[event].dapui = function()
        dapui.open()
    end
end
for _, event in ipairs({ "event_terminated", "event_exited" }) do
    dap.listeners.before[event].dapui = function()
        dapui.close()
    end
end

map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
map("n", "<leader>dc", dap.continue, { desc = "Continue / start" })
map("n", "<leader>dr", dap.repl.toggle, { desc = "Debug REPL" })
map("n", "<leader>dx", dap.terminate, { desc = "Terminate debug" })
map("n", "<leader>du", dapui.toggle, { desc = "Toggle debug UI" })
-- debugging tests goes through neotest (<leader>td/<leader>tD), which drives dap-go itself

map("n", "<F10>", dap.step_over, { desc = "Step over" })
map("n", "<F11>", dap.step_into, { desc = "Step into" })
map("n", "<F12>", dap.step_out, { desc = "Step out" })
