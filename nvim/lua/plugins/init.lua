-- Plugin configuration
-- Organized by category similar to ThePrimeagen's approach
return { -- Colorscheme
{
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false, -- Load immediately
    config = function()
        require("catppuccin").setup({
            flavour = "macchiato",
            integrations = {
                cmp = true,
                gitsigns = true,
                treesitter = true,
                notify = true,
                native_lsp = {
                    enabled = true
                }
            }
        })
        vim.cmd.colorscheme("catppuccin")
    end
}, -- Essential utilities
{
    "nvim-lua/plenary.nvim",
    lazy = true
}, -- LSP Configuration
{
    "neovim/nvim-lspconfig",
    dependencies = {"williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim"},
    config = function()
        require("config.plugins.lsp")
    end
}, {
    "williamboman/mason.nvim",
    config = function()
        require("mason").setup()
    end
}, {
    "williamboman/mason-lspconfig.nvim",
    config = function()
        require("mason-lspconfig").setup({
            ensure_installed = {"lua_ls", "pyright", "rust_analyzer", "gopls"}
        })
    end
}, -- Completion
{
    "hrsh7th/nvim-cmp",
    dependencies = {"hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "L3MON4D3/LuaSnip",
                    "saadparwaiz1/cmp_luasnip"},
    config = function()
        require("config.plugins.cmp")
    end
}, {
    "L3MON4D3/LuaSnip",
    dependencies = {"rafamadriz/friendly-snippets"},
    config = function()
        require("luasnip").setup({})
        require("luasnip.loaders.from_vscode").lazy_load()
    end
}, {
    "rafamadriz/friendly-snippets",
    lazy = true
}, -- Treesitter
{
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("config.plugins.treesitter")
    end
}, -- UI Enhancements
{
    "akinsho/bufferline.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()
        require("config.plugins.bufferline")
    end
}, {
    "nvim-tree/nvim-web-devicons",
    lazy = true
}, {
    "nvim-lualine/lualine.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()
        require("config.plugins.lualine")
    end
}, -- File navigation
{
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {"nvim-lua/plenary.nvim"},
    config = function()
        require("config.plugins.telescope")
    end
}, -- Git integration
{
    "lewis6991/gitsigns.nvim",
    config = function()
        require("gitsigns").setup()
    end
}, -- Comments
{
    "numToStr/Comment.nvim",
    config = function()
        require("Comment").setup()
    end
}, -- Indentation guides
{
    "lukas-reineke/indent-blankline.nvim",
    config = function()
        require("indent_blankline").setup({
            show_current_context = true,
            show_current_context_start = true
        })
    end
}, -- Auto pairs
{
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup({})
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
}, -- Notifications
{
    "rcarriga/nvim-notify",
    config = function()
        vim.notify = require("notify")
    end
}}
