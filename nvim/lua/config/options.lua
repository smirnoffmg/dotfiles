-- Neovim options and settings
local opt = vim.opt

-- Set colorscheme after plugins load (fallback)
vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    callback = function()
        if vim.g.colors_name ~= "catppuccin" then
            local ok, _ = pcall(vim.cmd.colorscheme, "catppuccin")
            if not ok then
                vim.cmd.colorscheme("default")
            end
        end
    end
})

-- UI
opt.number = true -- Show line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true -- Highlight current line
opt.signcolumn = "yes" -- Always show sign column
opt.list = true -- Show invisible characters
opt.listchars = "tab:▸ ,trail:·,nbsp:␣,eol:¬" -- tab, trailing space, nbsp, end-of-line
opt.termguicolors = true -- True color support
opt.showmode = false -- Don't show mode (shown in statusline)
opt.pumblend = 10 -- Popup menu transparency
opt.pumheight = 10 -- Maximum popup menu height

-- Indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Shift 2 spaces when tab
opt.tabstop = 2 -- 1 tab == 2 spaces
opt.softtabstop = 2 -- 1 tab == 2 spaces
opt.smartindent = true -- Auto indent new lines

-- Search
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Override ignorecase if search has uppercase
opt.hlsearch = true -- Highlight search results
opt.incsearch = true -- Incremental search

-- Editor behavior
opt.wrap = false -- Disable line wrap
opt.scrolloff = 8 -- Lines of context above/below cursor
opt.sidescrolloff = 8 -- Columns of context left/right of cursor
opt.mouse = "a" -- Enable mouse in all modes
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.undofile = true -- Persistent undo
opt.undolevels = 10000 -- Maximum undo levels
opt.updatetime = 200 -- Faster completion (default 4000ms)
opt.timeoutlen = 500 -- Time for leader/multi-key sequences (ms)

-- Splits
opt.splitbelow = true -- Horizontal splits below current
opt.splitright = true -- Vertical splits to the right

-- Completion
opt.completeopt = "menu,menuone,noselect" -- Completion options
opt.wildmode = "longest:full,full" -- Command-line completion mode

-- File handling
opt.autoread = true -- Auto read file when changed externally
opt.backup = false -- Disable backup files
opt.swapfile = false -- Disable swap files
opt.fileencoding = "utf-8" -- File encoding

-- Formatting
opt.formatoptions = "jcroqlnt" -- Format options
opt.grepformat = "%f:%l:%c:%m" -- Grep format
opt.grepprg = "rg --vimgrep" -- Use ripgrep for grep

-- Folding (using treesitter)
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99 -- Start with all folds open
opt.foldenable = true
