-- LSP Configuration
local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")

-- Setup keymaps for LSP
local on_attach = function(client, bufnr)
    local opts = {
        buffer = bufnr,
        remap = false
    }

    vim.keymap.set("n", "gd", function()
        vim.lsp.buf.definition()
    end, opts)
    vim.keymap.set("n", "K", function()
        vim.lsp.buf.hover()
    end, opts)
    vim.keymap.set("n", "<leader>vws", function()
        vim.lsp.buf.workspace_symbol()
    end, opts)
    vim.keymap.set("n", "<leader>vd", function()
        vim.diagnostic.open_float()
    end, opts)
    vim.keymap.set("n", "[d", function()
        vim.diagnostic.goto_next()
    end, opts)
    vim.keymap.set("n", "]d", function()
        vim.diagnostic.goto_prev()
    end, opts)
    vim.keymap.set("n", "<leader>vca", function()
        vim.lsp.buf.code_action()
    end, opts)
    vim.keymap.set("n", "<leader>vrr", function()
        vim.lsp.buf.references()
    end, opts)
    vim.keymap.set("n", "<leader>vrn", function()
        vim.lsp.buf.rename()
    end, opts)
    vim.keymap.set("i", "<C-h>", function()
        vim.lsp.buf.signature_help()
    end, opts)
end

-- Setup LSP servers
mason_lspconfig.setup_handlers({function(server_name)
    lspconfig[server_name].setup({
        on_attach = on_attach
    })
end})

-- Lua LSP specific config
lspconfig.lua_ls.setup({
    on_attach = on_attach,
    settings = {
        Lua = {
            diagnostics = {
                globals = {"vim"}
            }
        }
    }
})
