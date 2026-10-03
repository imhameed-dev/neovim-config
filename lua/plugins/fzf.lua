-- Search: fzf-lua is a popup finder that uses fzf, fd and ripgrep.
vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

-- "max-perf" = fastest profile, no icons, minimal extras
require("fzf-lua").setup({ "max-perf" })

local fzf = require("fzf-lua")
-- Space+f  find a file by name
vim.keymap.set("n", "<leader>f", fzf.files, { desc = "Find file" })
-- Space+/  search text inside all files in the project
vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Search text" })
-- Space+b  switch between files you already opened
vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Open buffers" })
