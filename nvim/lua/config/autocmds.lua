-- Autocmds configuration
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

-- Quickfix: Enter jumps to item and closes the window (e.g. after gd/references)
autocmd("FileType", {
    group = augroup("qf_enter_close", {
        clear = true
    }),
    pattern = "qf",
    callback = function(event)
        vim.keymap.set("n", "<CR>", function()
            local line = vim.fn.line(".")
            pcall(vim.cmd, "cc " .. line)
            pcall(vim.cmd, "lclose")
            pcall(vim.cmd, "cclose")
        end, {
            buffer = event.buf,
            silent = true
        })
    end,
    desc = "Enter in qf: jump and close",
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

---@return string Path to Python interpreter (uv .venv or PATH)
local function get_python_interpreter()
    -- 1. Active virtualenv (VIRTUAL_ENV set when venv activated)
    local venv = os.getenv("VIRTUAL_ENV")
    if venv and venv ~= "" then
        local python = venv .. "/bin/python"
        if vim.fn.filereadable(python) == 1 then
            return vim.fn.shellescape(python)
        end
    end

    -- 2. Project .venv (uv default) - search upward from buffer
    local buf_path = vim.api.nvim_buf_get_name(0)
    if buf_path and buf_path ~= "" then
        local root = vim.fs.dirname(buf_path)
        while root and root ~= vim.fs.dirname(root) do
            local candidate = root .. "/.venv/bin/python"
            if vim.fn.filereadable(candidate) == 1 then
                return vim.fn.shellescape(candidate)
            end
            root = vim.fs.dirname(root)
        end
    end

    -- 3. Fallback: python3 from PATH
    local python3 = vim.fn.exepath("python3")
    if python3 and python3 ~= "" then
        return vim.fn.shellescape(python3)
    end
    local python = vim.fn.exepath("python")
    if python and python ~= "" then
        return vim.fn.shellescape(python)
    end
    return "python3" -- last resort
end

autocmd("FileType", {
    group = augroup("filetype_python", {
        clear = true
    }),
    pattern = "python",
    callback = function(event)
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
        vim.keymap.set("n", "<leader>R", function()
            vim.cmd("w")
            local python = get_python_interpreter()
            local file = vim.fn.expand("%:p")
            local dir = vim.fn.fnamemodify(file, ":h")
            vim.cmd("lcd " .. vim.fn.fnameescape(dir))
            vim.cmd("!" .. python .. " " .. vim.fn.shellescape(file))
            vim.cmd("lcd -")
        end, {
            buffer = event.buf,
            desc = "Run current Python file",
        })
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

-- Format Python files with Ruff on save
autocmd("BufWritePre", {
    group = augroup("format_on_save_ruff", {
        clear = true
    }),
    pattern = "*.py",
    callback = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, client in ipairs(clients) do
            if client.name == "ruff" and client.supports_method("textDocument/formatting") then
                vim.lsp.buf.format({
                    async = false,
                    filter = function(c)
                        return c.name == "ruff"
                    end,
                })
                break
            end
        end
    end,
    desc = "Format Python with Ruff on save",
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
autocmd({ "BufNewFile", "BufRead" }, {
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
