-- Autocmds configuration
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text
autocmd("TextYankPost", {
    group = augroup("highlight_yank", {
        clear = true,
    }),
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 200,
        })
    end,
    desc = "Highlight yanked text",
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
    group = augroup("trim_whitespace", {
        clear = true,
    }),
    pattern = "*",
    callback = function(event)
        -- writing a non-modifiable buffer (`:w` from checkhealth, help, …) would
        -- otherwise abort with E21
        if not vim.bo[event.buf].modifiable then
            return
        end
        local view = vim.fn.winsaveview()
        -- keeppatterns keeps \s\+$ out of the search register and off hlsearch
        vim.cmd([[keeppatterns %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
    desc = "Remove trailing whitespace",
})

-- Return to last edit position when opening files
autocmd("BufReadPost", {
    group = augroup("restore_cursor", {
        clear = true,
    }),
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
    desc = "Return to last cursor position",
})

-- Auto-resize splits when terminal window is resized
autocmd("VimResized", {
    group = augroup("resize_splits", {
        clear = true,
    }),
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
    desc = "Resize splits on window resize",
})

-- Close certain filetypes with 'q'
autocmd("FileType", {
    group = augroup("close_with_q", {
        clear = true,
    }),
    pattern = {
        "help",
        "lspinfo",
        "man",
        "notify",
        "qf",
        "checkhealth",
        "startuptime",
        "neotest-output-panel",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", {
            buffer = event.buf,
            silent = true,
        })
    end,
    desc = "Close certain windows with q",
})

-- Quickfix: Enter jumps to item and closes the window (e.g. after gd/references)
autocmd("FileType", {
    group = augroup("qf_enter_close", {
        clear = true,
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
            silent = true,
        })
    end,
    desc = "Enter in qf: jump and close",
})

-- Set filetype-specific options
autocmd("FileType", {
    group = augroup("filetype_settings", {
        clear = true,
    }),
    pattern = { "lua", "json", "yaml", "javascript", "typescript", "typescriptreact" },
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
    desc = "Set indent to 2 spaces for certain filetypes",
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
        clear = true,
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
    desc = "Set indent to 4 spaces for Python",
})

autocmd("FileType", {
    group = augroup("filetype_go", {
        clear = true,
    }),
    pattern = "go",
    callback = function(event)
        vim.opt_local.expandtab = false
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4

        vim.keymap.set("n", "<leader>R", function()
            vim.cmd("w")
            local dir = vim.fn.expand("%:p:h")
            local is_main = vim.tbl_contains(vim.api.nvim_buf_get_lines(event.buf, 0, 20, false), "package main")
            vim.cmd("lcd " .. vim.fn.fnameescape(dir))
            -- a leetcode package has no entry point; its tests are the way to run it
            vim.cmd("!" .. (is_main and "go run ." or "go test ./"))
            vim.cmd("lcd -")
        end, {
            buffer = event.buf,
            desc = "Run current Go file (go run / go test)",
        })
    end,
    desc = "Use tabs for Go",
})

--- Run a "source.*" code action to completion before a write.
--- @param bufnr integer
--- @param client_name string only this server's actions are applied
--- @param kind string LSP code action kind
local function apply_source_action(bufnr, client_name, kind)
    local params = {
        textDocument = vim.lsp.util.make_text_document_params(bufnr),
        -- source.* actions apply to the whole file, so the range is ignored
        range = { start = { line = 0, character = 0 }, ["end"] = { line = 0, character = 0 } },
        context = { only = { kind }, diagnostics = {} },
    }
    -- The action has to be requested synchronously, otherwise the write races
    -- the buffer edit.
    local responses = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
    for client_id, response in pairs(responses or {}) do
        local client = vim.lsp.get_client_by_id(client_id)
        if client and client.name == client_name then
            for _, action in pairs(response.result or {}) do
                -- Nvim advertises resolveSupport, so servers may send the action
                -- without its edit and expect a resolve round-trip
                if not action.edit and action.data then
                    local resolved = client:request_sync("codeAction/resolve", action, 1000, bufnr)
                    action = resolved and resolved.result or action
                end
                if action.edit then
                    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                end
            end
        end
    end
end

-- Fix, organize imports and format Python files with Ruff on save
autocmd("BufWritePre", {
    group = augroup("format_on_save_ruff", {
        clear = true,
    }),
    pattern = "*.py",
    callback = function(event)
        local clients = vim.lsp.get_clients({ bufnr = event.buf, name = "ruff" })
        if #clients == 0 then
            return
        end

        -- `ruff format` neither fixes lint violations nor sorts imports (I001);
        -- both happen only through these source actions.
        apply_source_action(event.buf, "ruff", "source.fixAll.ruff")
        apply_source_action(event.buf, "ruff", "source.organizeImports.ruff")

        if clients[1]:supports_method("textDocument/formatting") then
            vim.lsp.buf.format({
                async = false,
                bufnr = event.buf,
                filter = function(c)
                    return c.name == "ruff"
                end,
            })
        end
    end,
    desc = "Fix, organize imports and format Python with Ruff on save",
})

-- Organize imports and format Go files with gopls on save
autocmd("BufWritePre", {
    group = augroup("format_on_save_gopls", {
        clear = true,
    }),
    pattern = "*.go",
    callback = function(event)
        local clients = vim.lsp.get_clients({ bufnr = event.buf, name = "gopls" })
        if #clients == 0 or not clients[1]:supports_method("textDocument/formatting") then
            return
        end

        -- goimports = organizeImports + gofmt
        apply_source_action(event.buf, "gopls", "source.organizeImports")

        vim.lsp.buf.format({
            async = false,
            bufnr = event.buf,
            filter = function(c)
                return c.name == "gopls"
            end,
        })
    end,
    desc = "Organize imports and format Go on save",
})

-- Auto-create parent directories when saving a file
autocmd("BufWritePre", {
    group = augroup("auto_mkdir", {
        clear = true,
    }),
    callback = function(event)
        if event.match:match("^%w%w+://") then
            return
        end
        local file = vim.loop.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
    desc = "Auto-create parent directories",
})

-- Format Markdown, YAML and JSON with Prettier on save (same set the prettier
-- pre-commit hook covers, so the editor and the hook agree)
autocmd("BufWritePre", {
    group = augroup("format_on_save_prettier", {
        clear = true,
    }),
    pattern = { "*.md", "*.yaml", "*.yml", "*.json" },
    callback = function(event)
        -- mason prepends its bin to nvim's PATH
        local prettier = vim.fn.exepath("prettier")
        if prettier == "" then
            return
        end

        local lines = vim.api.nvim_buf_get_lines(event.buf, 0, -1, false)
        -- --stdin-filepath both picks the parser and anchors .prettierrc lookup
        local result = vim.system({ prettier, "--stdin-filepath", vim.api.nvim_buf_get_name(event.buf) }, {
            stdin = table.concat(lines, "\n") .. "\n",
            text = true,
        }):wait()

        if result.code ~= 0 then
            vim.notify("prettier: " .. vim.trim(result.stderr or ""), vim.log.levels.WARN)
            return
        end

        local formatted = vim.split((result.stdout or ""):gsub("\n$", ""), "\n")
        if not vim.deep_equal(lines, formatted) then
            local view = vim.fn.winsaveview()
            vim.api.nvim_buf_set_lines(event.buf, 0, -1, false, formatted)
            vim.fn.winrestview(view)
        end
    end,
    desc = "Format Markdown, YAML and JSON with Prettier on save",
})

-- Terminal buffers: no gutter, start in insert mode
autocmd("TermOpen", {
    group = augroup("term_open", {
        clear = true,
    }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.cmd.startinsert()
    end,
    desc = "Terminal buffer settings",
})

-- Disable auto-comment on new line
autocmd({ "BufNewFile", "BufRead" }, {
    group = augroup("no_auto_comment", {
        clear = true,
    }),
    callback = function()
        vim.opt.formatoptions:remove({ "c", "r", "o" })
    end,
    desc = "Disable auto-comment on new line",
})

-- Check if file changed outside of Neovim
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime", {
        clear = true,
    }),
    command = "checktime",
    desc = "Check if file changed externally",
})
