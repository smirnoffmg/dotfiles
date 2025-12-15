-- Load configuration in order
require("config.options") -- Settings first
require("config.keymaps") -- Keymaps second
require("config.autocmds") -- Autocmds third
require("config.lazy") -- Plugin manager last
