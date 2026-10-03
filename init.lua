-- Entry point: Neovim runs this file first.
-- The "leader" key is the prefix for our custom shortcuts. We use Space.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load lua/options.lua and lua/keymaps.lua
require("options")
require("keymaps")

-- Code intelligence (built into Neovim, no plugins)
require("lsp")
require("treesitter")

-- Local AI (on demand, no plugin)
require("ai")

-- Plugins (one file per plugin in lua/plugins/)
require("plugins.oil")
require("plugins.fzf")
require("plugins.git")
