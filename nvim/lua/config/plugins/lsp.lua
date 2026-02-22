-- LSP Configuration (Neovim 0.11+ vim.lsp.config API)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Disable Ruff hover so pylsp handles it (pylsp + Ruff run together on Python)
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_ruff_disable_hover", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end
    end,
    desc = "Disable Ruff hover in favor of pylsp",
})

-- Global LSP defaults (capabilities + on_attach for all servers)
local on_attach = function(_, bufnr)
    local opts = { buffer = bufnr, remap = false }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end

vim.lsp.config("*", {
    capabilities = capabilities,
    on_attach = on_attach,
})

-- Lua LSP: vim global
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
        },
    },
})

-- Enable all servers (mason-lspconfig installs them, we enable for filetypes)
vim.lsp.enable({ "lua_ls", "pylsp", "ruff", "rust_analyzer", "gopls" })
