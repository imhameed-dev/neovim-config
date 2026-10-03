-- Treesitter: more accurate coloring, but only where the parser AND its
-- "highlights" rules both exist. Otherwise Neovim's built-in coloring stays on.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "sh", "bash", "javascript", "markdown" },
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match) or args.match
    if vim.treesitter.query.get(lang, "highlights") then
      pcall(vim.treesitter.start, args.buf, lang)
    end
  end,
})
