-- Keymaps configuration
local map = vim.keymap.set
local g = vim.g

-- Set leader key
g.mapleader = " "
g.maplocalleader = " "

-- Better escape
map("i", "jk", "<Esc>", {
    desc = "Exit insert mode"
})
map("i", "jj", "<Esc>", {
    desc = "Exit insert mode"
})

-- Better window navigation
map("n", "<C-h>", "<C-w>h", {
    desc = "Go to left window"
})
map("n", "<C-j>", "<C-w>j", {
    desc = "Go to lower window"
})
map("n", "<C-k>", "<C-w>k", {
    desc = "Go to upper window"
})
map("n", "<C-l>", "<C-w>l", {
    desc = "Go to right window"
})

-- Resize windows with arrows
map("n", "<C-Up>", "<cmd>resize +2<cr>", {
    desc = "Increase window height"
})
map("n", "<C-Down>", "<cmd>resize -2<cr>", {
    desc = "Decrease window height"
})
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", {
    desc = "Decrease window width"
})
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", {
    desc = "Increase window width"
})

-- Move lines up/down
map("n", "<A-j>", "<cmd>m .+1<cr>==", {
    desc = "Move line down"
})
map("n", "<A-k>", "<cmd>m .-2<cr>==", {
    desc = "Move line up"
})
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", {
    desc = "Move line down"
})
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", {
    desc = "Move line up"
})
map("v", "<A-j>", ":m '>+1<cr>gv=gv", {
    desc = "Move selection down"
})
map("v", "<A-k>", ":m '<-2<cr>gv=gv", {
    desc = "Move selection up"
})

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", {
    desc = "Indent left"
})
map("v", ">", ">gv", {
    desc = "Indent right"
})

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", {
    desc = "Clear search highlight"
})

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", {
    desc = "Previous buffer"
})
map("n", "<S-l>", "<cmd>bnext<cr>", {
    desc = "Next buffer"
})
map("n", "<leader>bd", "<cmd>bdelete<cr>", {
    desc = "Delete buffer"
})
map("n", "<leader>bD", "<cmd>%bdelete<cr>", {
    desc = "Delete all buffers"
})

-- Quick save
map("n", "<leader>w", "<cmd>w<cr>", {
    desc = "Save file"
})
map("n", "<leader>W", "<cmd>wa<cr>", {
    desc = "Save all files"
})

-- Quick quit
map("n", "<leader>q", "<cmd>q<cr>", {
    desc = "Quit"
})
map("n", "<leader>Q", "<cmd>qa!<cr>", {
    desc = "Force quit all"
})

-- Better paste (don't yank replaced text)
map("v", "p", '"_dP', {
    desc = "Paste without yanking"
})

-- Yank to end of line (consistent with D and C)
map("n", "Y", "y$", {
    desc = "Yank to end of line"
})

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", {
    desc = "Scroll down (centered)"
})
map("n", "<C-u>", "<C-u>zz", {
    desc = "Scroll up (centered)"
})
map("n", "n", "nzzzv", {
    desc = "Next search result (centered)"
})
map("n", "N", "Nzzzv", {
    desc = "Previous search result (centered)"
})

-- Join lines without moving cursor
map("n", "J", "mzJ`z", {
    desc = "Join lines (keep cursor)"
})

-- Quick access to config
map("n", "<leader>vc", "<cmd>e ~/.config/nvim/lua/config/<cr>", {
    desc = "Edit Neovim config"
})
map("n", "<leader>vp", "<cmd>e ~/.config/nvim/lua/plugins/<cr>", {
    desc = "Edit Neovim plugins"
})

-- Toggle options
map("n", "<leader>uw", "<cmd>set wrap!<cr>", {
    desc = "Toggle word wrap"
})
map("n", "<leader>us", "<cmd>set spell!<cr>", {
    desc = "Toggle spell check"
})
map("n", "<leader>un", "<cmd>set number!<cr>", {
    desc = "Toggle line numbers"
})
map("n", "<leader>ur", "<cmd>set relativenumber!<cr>", {
    desc = "Toggle relative numbers"
})

-- Diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, {
    desc = "Previous diagnostic"
})
map("n", "]d", vim.diagnostic.goto_next, {
    desc = "Next diagnostic"
})
map("n", "<leader>cd", vim.diagnostic.open_float, {
    desc = "Line diagnostics"
})
