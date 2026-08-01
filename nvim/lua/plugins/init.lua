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
                    indent_blankline = true,
                    native_lsp = {
                        enabled = true,
                    },
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    }, -- Essential utilities
    {
        "nvim-lua/plenary.nvim",
        lazy = true,
    }, -- LSP Configuration (Neovim 0.11+ vim.lsp.config API)
    {
        "neovim/nvim-lspconfig",
        dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {}, -- Deferred to background below
                -- Defaults to true, which enables every server installed in mason
                -- regardless of the list below — that is how pyright and pylsp
                -- ended up attaching to the same buffer. vim.lsp.enable() in
                -- config.plugins.lsp is the only place that decides what runs.
                automatic_enable = false,
            })
            require("config.plugins.lsp")
            -- Defer server installs to background (avoids blocking LSP setup)
            vim.defer_fn(function()
                local registry = require("mason-registry")
                local lspconfig_to_package = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
                local servers = { "lua_ls", "pyright", "ruff", "rust_analyzer", "gopls" }
                local packages = {}
                for _, name in ipairs(servers) do
                    local pkg_name = lspconfig_to_package[name]
                    if pkg_name then
                        table.insert(packages, pkg_name)
                    end
                end
                -- Tools with no LSP behind them. prettier must stay in sync with
                -- the version pinned in .pre-commit-config.yaml.
                vim.list_extend(packages, { "prettier", "debugpy" })
                for _, pkg_name in ipairs(packages) do
                    local ok, pkg = pcall(registry.get_package, pkg_name)
                    if ok and not pkg:is_installed() and not pkg:is_installing() then
                        pkg:install()
                    end
                end
            end, 500)
        end,
    }, -- Completion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            require("config.plugins.cmp")
        end,
    },
    {
        "L3MON4D3/LuaSnip",
        lazy = true, -- loaded as a nvim-cmp dependency
        submodules = false, -- Avoid jsregexp submodule clone errors
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            require("luasnip").setup({})
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },
    {
        "rafamadriz/friendly-snippets",
        lazy = true,
    }, -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false, -- main branch does not support lazy-loading
        build = ":TSUpdate",
        config = function()
            require("config.plugins.treesitter")
        end,
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
        end,
    }, -- UI Enhancements
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("config.plugins.bufferline")
        end,
    },
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("config.plugins.lualine")
        end,
    }, -- Git integration
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("gitsigns").setup()
        end,
    }, -- Indentation guides
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            -- No options: v2's show_current_context/show_current_context_start are
            -- v3 defaults (scope.enabled, scope.show_start).
            require("ibl").setup()
        end,
    }, -- Auto pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local cmp = require("cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    }, -- Notifications
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        config = function()
            vim.notify = require("notify")
        end,
    },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = { "lewis6991/async.nvim" },
        lazy = false,
        config = function()
            require("config.plugins.refactoring")
        end,
    }, -- Test runner
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            {
                "fredrikaverpil/neotest-golang",
                version = "*",
                dependencies = { "uga-rosa/utf8.nvim" },
            },
            "nvim-neotest/neotest-python",
        },
        ft = { "go", "python" },
        config = function()
            require("config.plugins.neotest")
        end,
    }, -- Linting (golangci-lint; LSP diagnostics come from gopls)
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("config.plugins.lint")
        end,
    }, -- Debugging (delve via dap-go)
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
            "leoluz/nvim-dap-go",
            "mfussenegger/nvim-dap-python",
        },
        ft = { "go", "python" },
        config = function()
            require("config.plugins.dap")
        end,
    },
}
