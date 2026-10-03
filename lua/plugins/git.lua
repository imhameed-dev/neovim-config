-- Git: gitsigns shows changed lines in the left margin.
vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

require("gitsigns").setup({
  on_attach = function(buf)
    local gs = require("gitsigns")
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = buf, desc = desc })
    end
    map("]h", function() gs.nav_hunk("next") end, "Next change")
    map("[h", function() gs.nav_hunk("prev") end, "Previous change")
    map("<leader>hp", gs.preview_hunk, "Preview change")
    map("<leader>hs", gs.stage_hunk, "Stage change")
    map("<leader>hb", function() gs.blame_line({ full = true }) end, "Who changed this line")
  end,
})

-- Project-wide Git views, using the fzf-lua popup we already have
local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>gs", fzf.git_status, { desc = "Git status" })
vim.keymap.set("n", "<leader>gc", fzf.git_commits, { desc = "Git history" })
vim.keymap.set("n", "<leader>gb", fzf.git_branches, { desc = "Git branches" })
