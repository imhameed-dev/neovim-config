local map = vim.keymap.set

-- Space+w saves the file, Space+q quits
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })

-- Ctrl+h/j/k/l jumps between split windows (left/down/up/right)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- NEW: split the window. Space s v = side by side, Space s h = stacked
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split side by side" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split stacked" })

-- NEW: Space x closes the current file (buffer)
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close file" })

-- NEW: Space t opens a terminal in a small window at the bottom
map("n", "<leader>t", function()
  vim.cmd("botright 12split | terminal")
  vim.cmd("startinsert")
end, { desc = "Terminal" })

-- NEW: Esc Esc leaves terminal typing mode, so Ctrl+k and :q work again
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

-- Esc also clears the yellow search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Space ? opens the setup guide
map("n", "<leader>?", "<cmd>edit ~/.config/nvim/README.md<cr>", { desc = "Open guide" })
