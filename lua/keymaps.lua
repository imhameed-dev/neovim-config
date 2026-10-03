local map = vim.keymap.set

-- Space+w saves the file, Space+q quits
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })

-- Ctrl+h/j/k/l jumps between split windows (left/down/up/right)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Esc also clears the yellow search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
