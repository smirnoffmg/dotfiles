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
}, -- LSP Configuration (Neovim 0.11+ vim.lsp.config API)
{
    "neovim/nvim-lspconfig",
    dependencies = {"mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim"},
    event = {"BufReadPre", "BufNewFile"},
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {} -- Deferred to background below
        })
        require("config.plugins.lsp")
        -- Defer server installs to background (avoids blocking LSP setup)
        vim.defer_fn(function()
            local registry = require("mason-registry")
            local lspconfig_to_package = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
            local servers = {"lua_ls", "pylsp", "ruff", "rust_analyzer", "gopls"}
            for _, name in ipairs(servers) do
                local pkg_name = lspconfig_to_package[name]
                if pkg_name then
                    local ok, pkg = pcall(registry.get_package, pkg_name)
                    if ok and not pkg:is_installed() and not pkg:is_installing() then
                        pkg:install()
                    end
                end
            end
        end, 500)
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
    submodules = false, -- Avoid jsregexp submodule clone errors
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
}, -- Telescope (fuzzy finder)
{
    "nvim-telescope/telescope.nvim",
    lazy = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
        require("config.plugins.telescope")
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
}, {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {"nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter"},
    lazy = false,
    config = function()
        require("config.plugins.refactoring")
    end
}}
