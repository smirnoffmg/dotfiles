-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text
autocmd("TextYankPost", {
    group = augroup("highlight_yank", {
        clear = true
    }),
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 200
        })
    end,
    desc = "Highlight yanked text"
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
    group = augroup("trim_whitespace", {
        clear = true
    }),
    pattern = "*",
    command = [[%s/\s\+$//e]],
    desc = "Remove trailing whitespace"
})

-- Return to last edit position when opening files
autocmd("BufReadPost", {
    group = augroup("restore_cursor", {
        clear = true
    }),
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
    desc = "Return to last cursor position"
})

-- Auto-resize splits when terminal window is resized
autocmd("VimResized", {
    group = augroup("resize_splits", {
        clear = true
    }),
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
    desc = "Resize splits on window resize"
})

-- Close certain filetypes with 'q'
autocmd("FileType", {
    group = augroup("close_with_q", {
        clear = true
    }),
    pattern = {"help", "lspinfo", "man", "notify", "qf", "checkhealth", "startuptime"},
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", {
            buffer = event.buf,
            silent = true
        })
    end,
    desc = "Close certain windows with q"
})

-- Set filetype-specific options
autocmd("FileType", {
    group = augroup("filetype_settings", {
        clear = true
    }),
    pattern = {"lua", "json", "yaml", "javascript", "typescript", "typescriptreact"},
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
    desc = "Set indent to 2 spaces for certain filetypes"
})

autocmd("FileType", {
    group = augroup("filetype_python", {
        clear = true
    }),
    pattern = "python",
    callback = function()
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
    end,
    desc = "Set indent to 4 spaces for Python"
})

autocmd("FileType", {
    group = augroup("filetype_go", {
        clear = true
    }),
    pattern = "go",
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
    end,
    desc = "Use tabs for Go"
})

-- Auto-create parent directories when saving a file
autocmd("BufWritePre", {
    group = augroup("auto_mkdir", {
        clear = true
    }),
    callback = function(event)
        if event.match:match("^%w%w+://") then
            return
        end
        local file = vim.loop.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
    desc = "Auto-create parent directories"
})

-- Disable auto-comment on new line
autocmd("BufEnter", {
    group = augroup("no_auto_comment", {
        clear = true
    }),
    callback = function()
        vim.opt.formatoptions:remove({"c", "r", "o"})
    end,
    desc = "Disable auto-comment on new line"
})

-- Check if file changed outside of Neovim
autocmd({"FocusGained", "TermClose", "TermLeave"}, {
    group = augroup("checktime", {
        clear = true
    }),
    command = "checktime",
    desc = "Check if file changed externally"
})
