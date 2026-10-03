-- LSP: Neovim's built-in client talks to "language server" programs.
-- A server is started only when you open a matching file.

-- jedi: Python navigation (go to definition, hover, completion)
vim.lsp.config("jedi", {
  cmd = { "jedi-language-server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", ".git" },
})

-- ruff: Python formatting and error checking (installed via pacman: ruff)
vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".git" },
})

vim.lsp.enable({ "jedi", "ruff" })

-- Completion popup: show a menu, preselect nothing, show docs beside it
vim.opt.completeopt = { "menu", "menuone", "noinsert", "popup" }

-- Runs each time a server attaches to a file
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- Let jedi answer hover (K); ruff only formats and checks
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
    -- Completion pops up after trigger characters like "."
    vim.lsp.completion.enable(true, args.data.client_id, args.buf, { autotrigger = true })
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = args.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("<leader>d", vim.diagnostic.open_float, "Show error under cursor")
    map("<leader>cf", function() vim.lsp.buf.format({ async = false }) end, "Format file")
  end,
})

-- Ctrl+Space in insert mode: ask for completions manually
vim.keymap.set("i", "<C-Space>", function() vim.lsp.completion.get() end, { desc = "Complete" })

-- Show errors as text at the end of the line, worst first
vim.diagnostic.config({ virtual_text = true, severity_sort = true })
