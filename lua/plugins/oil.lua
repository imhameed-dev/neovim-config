-- File management: oil.nvim shows a folder as an editable buffer.
-- Edit the text (rename a line, delete a line, add a line), then :w to apply.
vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

require("oil").setup({
  columns = {},                -- names only, no icons (no special font needed)
  view_options = { show_hidden = true },  -- show dotfiles like .gitignore
})

-- Space+e opens the folder of the current file; "-" goes up one folder
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer" })
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Parent folder" })
