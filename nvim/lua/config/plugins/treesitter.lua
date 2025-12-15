-- Treesitter Configuration
require("nvim-treesitter.configs").setup({
    ensure_installed = {"lua", "python", "rust", "go", "javascript", "typescript", "json", "yaml", "markdown", "bash",
                        "vim"},
    highlight = {
        enable = true
    },
    indent = {
        enable = true
    },
    folding = {
        enable = true
    }
})
