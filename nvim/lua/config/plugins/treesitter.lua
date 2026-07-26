-- Treesitter Configuration (nvim-treesitter `main` branch ships parsers and queries only;
-- highlighting, folding and indent are driven by Neovim itself)
local ts = require("nvim-treesitter")

ts.setup()

ts.install({
    "bash",
    "go",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "rust",
    "typescript",
    "vim",
    "yaml",
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
    callback = function(args)
        -- Fails for filetypes without an installed parser; those keep regex syntax
        if not pcall(vim.treesitter.start, args.buf) then
            return
        end
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})
