local opt = vim.opt

opt.number = true          -- show line numbers
opt.scrolloff = 8          -- keep 8 lines visible above/below the cursor
opt.splitright = true      -- new vertical splits open on the right
opt.splitbelow = true      -- new horizontal splits open below

-- Indentation: 4 spaces, no tab characters
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

-- Search: ignore case unless you type a capital letter
opt.ignorecase = true
opt.smartcase = true

-- Keep undo history between sessions (small files on disk)
opt.undofile = true

-- Use the system clipboard: yank in Neovim, paste in Firefox (and back)
opt.clipboard = "unnamedplus"
