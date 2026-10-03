-- ai.lua: on-demand local Qwen through llama-server.
-- Nothing runs until you ask. The server starts on first use and stops by
-- itself after 10 idle minutes, on :QwenStop, or when you quit Neovim.

local MODEL = vim.fn.expand("~/models/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf")
local URL = "http://127.0.0.1:8080"
local MIN_FREE_MB = 1500            -- refuse to load the model if less RAM is free
local IDLE_MS = 10 * 60 * 1000       -- stop the server after 10 idle minutes
local MAX_CHARS = 3000               -- longer text is too slow on this CPU

local server = nil                   -- the llama-server process (only if WE started it)
local answer_buf = nil               -- NEW: the current answer window's buffer
local idle = vim.uv.new_timer()

local function stop_server()
  idle:stop()
  if server then
    server:kill(15)                  -- polite "please quit" signal
    server = nil
  end
end

local function touch_idle()          -- restart the idle countdown
  idle:stop()
  idle:start(IDLE_MS, 0, vim.schedule_wrap(stop_server))
end

local function server_up()           -- is the server answering?
  return vim.system({ "curl", "-sf", URL .. "/health" }):wait().code == 0
end

local function mem_available_mb()    -- free RAM the system can hand out
  for line in io.lines("/proc/meminfo") do
    local kb = line:match("^MemAvailable:%s+(%d+)")
    if kb then return tonumber(kb) / 1024 end
  end
end

-- Start the server if needed, then call on_ready(). Call on_error(msg) on trouble.
local function start_server(on_ready, on_error)
  if server_up() then return on_ready() end
  local free = mem_available_mb()
  if free and free < MIN_FREE_MB then
    return on_error(string.format("Only %d MB of RAM is free (need %d). Close Firefox and try again.",
      math.floor(free), MIN_FREE_MB))
  end
  server = vim.system({ "llama-server", "-m", MODEL, "-t", "2", "-c", "2048", "-np", "1",
    "--host", "127.0.0.1", "--port", "8080" },
    { stdout = function() end, stderr = function() end })
  local tries = 0
  local timer = vim.uv.new_timer()
  -- check once per second (up to 90 s) until the model has loaded
  timer:start(1000, 1000, vim.schedule_wrap(function()
    tries = tries + 1
    if server_up() then
      timer:stop(); timer:close(); on_ready()
    elseif tries >= 90 then
      timer:stop(); timer:close(); stop_server()
      on_error("The Qwen server did not start within 90 seconds.")
    end
  end))
end

local function show_answer(buf, text)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n"))
  end
end

-- Send a prompt to Qwen and show the answer in a small window at the bottom.
local function ask(prompt)
  if #prompt > MAX_CHARS then
    vim.notify("Too much text for Qwen on this laptop (" .. #prompt .. " characters, max "
      .. MAX_CHARS .. "). Select fewer lines.", vim.log.levels.WARN)
    return
  end
  -- NEW: close the previous answer window so they don't pile up
  if answer_buf and vim.api.nvim_buf_is_valid(answer_buf) then
    vim.api.nvim_buf_delete(answer_buf, { force = true })
  end
  vim.cmd("botright 12new")
  local buf = vim.api.nvim_get_current_buf()
  answer_buf = buf                                               -- NEW
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  vim.wo.wrap = true
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })   -- q closes the answer
  show_answer(buf, "Qwen is working... (first use loads the model and can take 30+ seconds)")

  start_server(function()
    local body = vim.json.encode({
      messages = {
        { role = "system", content = "You are a concise coding assistant. Keep answers short." },
        { role = "user", content = prompt },
      },
      max_tokens = 300,
      temperature = 0.2,
    })
    vim.system({ "curl", "-s", "-m", "300", URL .. "/v1/chat/completions",
      "-H", "Content-Type: application/json", "--data-binary", "@-" },
      { stdin = body, text = true },
      vim.schedule_wrap(function(res)
        local ok, data = pcall(vim.json.decode, res.stdout or "")
        local text
        if ok and type(data) == "table" and data.choices then
          text = data.choices[1].message.content
        else
          text = "Error from server:\n" .. (res.stdout or "") .. (res.stderr or "")
        end
        show_answer(buf, text)
        touch_idle()
      end))
  end, function(msg) show_answer(buf, msg) end)
end

-- The lines you selected (or nil if nothing was selected)
local function selected_text(opts)
  if opts.range == 0 then return nil end
  return table.concat(vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false), "\n")
end

-- :Qwen your question      (add selected lines as context if you selected some)
vim.api.nvim_create_user_command("Qwen", function(opts)
  local prompt = opts.args
  local code = selected_text(opts)
  if code then prompt = prompt .. "\n\nCode:\n" .. code end
  ask(prompt)
end, { nargs = "+", range = true })

-- :QwenExplain             (explains the selected lines)
vim.api.nvim_create_user_command("QwenExplain", function(opts)
  local code = selected_text(opts)
  if not code then
    vim.notify("Select lines first: press V, move with j/k, then Space a e", vim.log.levels.INFO)
    return
  end
  ask("Explain this code step by step, for a beginner:\n\n" .. code)
end, { range = true })

-- :QwenStop                (free the RAM right now)
vim.api.nvim_create_user_command("QwenStop", function()
  stop_server()
  vim.notify("Qwen server stopped")
end, {})

-- Make sure the server never outlives Neovim
vim.api.nvim_create_autocmd("VimLeavePre", { callback = stop_server })

-- Keys: Space a a = ask (opens ":Qwen " for you to type the question)
--       Space a e = explain the lines you selected with V
vim.keymap.set("n", "<leader>aa", ":Qwen ", { desc = "Ask Qwen" })
vim.keymap.set("x", "<leader>aa", ":Qwen ", { desc = "Ask Qwen about selection" })
vim.keymap.set("x", "<leader>ae", ":QwenExplain<cr>", { desc = "Explain selection" })
