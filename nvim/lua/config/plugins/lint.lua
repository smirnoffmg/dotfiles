local lint = require("lint")

lint.linters_by_ft = {
    go = { "golangcilint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
    pattern = "*.go",
    callback = function()
        lint.try_lint()
    end,
    desc = "Run golangci-lint",
})
