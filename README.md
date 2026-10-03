# Lightweight Neovim + Local Qwen: Setup Guide

Built step by step on 3 Oct 2026 · Neovim 0.12.5 · llama.cpp 0.4.1 · Lenovo V145-15AST (AMD A6-9225, 4 GB RAM, HDD, Arch Linux, DWM)

## Start here: the 2-minute version

This is all you need day to day. Everything below is reference.

1. Open a project: `cd ~/projects/myapp`, then `nvim .`. A file list opens.
2. Find a file with Space f. Search text in all files with Space /.
3. Press `i` to type, `Esc` to stop typing, Space w to save, Space q to quit.
4. Understand code: `gd` jumps to a definition (Ctrl-o goes back), `K` shows its docs, Space d shows an error.
5. Tidy Python code with Space c f.
6. Run your code: Space t opens a terminal, type the command, press Esc twice to leave it.
7. Ask the local AI: select lines with `V`, then Space a e (explain) or Space a a (ask). Close Firefox first. The first answer takes about 30 seconds.
8. Save your work: `git add -A`, then `git commit -m 'message'`, then `git push`.

## 1. Final architecture

```
Neovim 0.12 (built in: LSP client, Treesitter, completion, statusline, plugin manager vim.pack)
├── oil.nvim ............. file management
├── fzf-lua .............. search (uses fzf, ripgrep, fd)
├── gitsigns.nvim ........ changed-line margin
├── jedi-language-server . Python navigation (starts only for .py files)
├── ruff server .......... Python format + error checks (starts only for .py files)
├── Treesitter parsers ... bash, javascript, python, markdown (from pacman)
└── lua/ai.lua ........... on-demand Qwen (no plugin)
      └── llama-server (llama.cpp, CPU only) + Qwen2.5-Coder-1.5B-Instruct Q4_K_M
```

Plugins: 3. Background daemons: none. The language servers and the Qwen server exist only while you use them.

## 2. Final tool list and why

| Need | Choice | Why |
| --- | --- | --- |
| Editor | Neovim 0.12.5 (pacman) | Already installed. 0.12 has a built-in plugin manager, completion and LSP client. |
| Plugin manager | built-in vim.pack | No extra software. With 3 plugins, lazy.nvim's features are not needed. |
| Files | oil.nvim | A folder is an editable text buffer: rename, move, delete are normal edits, applied with :w. No dependencies. |
| Search | fzf-lua + fzf + ripgrep + fd | One tool for files, text, buffers, git. No indexing, no daemon. |
| LSP | built-in client, 2 servers | jedi (59 MiB) for navigation, ruff (48 MiB) for formatting. No Mason, no lspconfig. |
| Completion | native Neovim 0.12 | Zero plugins. blink.cmp is the better plugin if ever needed; nvim-cmp is rejected. |
| Treesitter | pacman parsers | Neovim finds them itself. Only used where highlight rules exist. |
| Git | git CLI + gitsigns + fzf-lua pickers | Staging and commits stay in real git commands. |
| Formatting | ruff (LSP) | Python only for now. |
| Terminal | native :terminal | DWM tags plus :terminal replace tmux. |
| Clipboard | xclip (30 KB) | Copy between Neovim and Firefox. |
| AI runtime | llama.cpp CPU build | Starts on demand, no daemon, 33 MB installed. |
| Model | Qwen2.5-Coder-1.5B-Instruct Q4\_K\_M | Code-tuned, 1.04 GiB file, fits in RAM with Firefox closed. |
| AI in Neovim | about 150 lines of your own Lua | Readable, RAM-safe, nothing runs until you ask. |

## 3. Rejected or postponed

- Telescope (heavier than fzf-lua for the same job), nvim-tree and Neo-tree (sidebar trees; oil is smaller), nvim-cmp (needs one plugin per source), Mason and nvim-lspconfig (extra layers), none-ls (not needed), lazy.nvim (not needed at this size).
- tmux and toggleterm: DWM tags and :terminal already cover this. lualine, bufferline, icons: cost RAM and startup for looks.
- Ollama: runs a background server. llama.cpp starts only when asked.
- CodeCompanion and Avante: large agent frameworks. Too heavy for 4 GB and not requested.
- Vulkan GPU backend: the integrated GPU shares system RAM, so no real gain.
- Postponed until a project needs them: Node/npm, prettier, TypeScript server, clang and clangd, Rust and rust-analyzer (very heavy on 4 GB), lazygit, conform.nvim.

## 4. What was installed

```
sudo pacman -S --needed ripgrep fd fzf
sudo pacman -S --needed jedi-language-server tree-sitter-python tree-sitter-bash tree-sitter-javascript tree-sitter-markdown
sudo pacman -S --needed xclip ruff llama-cpp
```

Plugins (cloned by vim.pack into \~/.local/share/nvim/site/pack/core/opt/): oil.nvim, fzf-lua, gitsigns.nvim. Model file: \~/models/qwen2.5-coder-1.5b-instruct-q4\_k\_m.gguf (1.04 GiB), downloaded from the official Qwen repo on Hugging Face.

## 5. Config file map (\~/.config/nvim/)

| File | Role |
| --- | --- |
| init.lua | Entry point: leader key (Space), loads everything below |
| lua/options.lua | Line numbers, 4-space indent, search case rules, undo file, system clipboard |
| lua/keymaps.lua | Save, quit, window moves, splits, terminal, close buffer |
| lua/lsp.lua | Registers jedi and ruff, completion, gd, Space d, Space c f |
| lua/treesitter.lua | Starts Treesitter only when the parser and its highlight rules exist |
| lua/ai.lua | :Qwen, :QwenExplain, :QwenStop, RAM check, idle shutdown |
| lua/plugins/oil.lua | File manager |
| lua/plugins/fzf.lua | Search keys |
| lua/plugins/git.lua | gitsigns and Git pickers |

The complete files are already on your disk. Back them up with git (see Maintenance).

## 6. Keybinding cheat sheet (leader = Space)

| Keys | Action |
| --- | --- |
| Space w / Space q | Save / quit |
| Ctrl-h j k l | Move between windows |
| Space s v / Space s h | Split side by side / stacked |
| Space x | Close this file |
| Space t | Terminal at the bottom; Esc Esc leaves it |
| Space e or - | File explorer / parent folder |
| Space f | Find file by name |
| Space / | Search text in all files |
| Space b | Switch between opened files |
| gd | Go to definition (Ctrl-o goes back) |
| K | Hover documentation |
| grr | Find references |
| grn | Rename symbol (Neovim default) |
| Space d | Show the error under the cursor |
| Space c f | Format file |
| \]h and \[h | Next / previous changed hunk |
| Space h p / s / b | Preview / stage / blame the change |
| Space g s / c / b | Git status / history / branches |
| Space a a | Ask Qwen (type your question, Enter; selected lines are included) |
| V, then Space a e | Explain selected lines |
| q (in answer window) | Close the answer |
| :QwenStop | Free the Qwen RAM now |

In oil: Enter opens, - goes up, o adds a line (type a name; end with / for a folder), dd marks a delete, then :w to apply and y to confirm. g? shows help.

## 7. Project workflow

```
cd ~/projects/myapp          # in a terminal on a DWM tag
nvim .                       # opens the file list (oil)
```

1. Space f, type part of a name, Enter to open a file.
2. i to type, Esc to stop, Space w to save.
3. gd to jump to a definition, K for docs, Space d for an error message.
4. Space t, then run it: python src/main.py. Esc Esc to leave the terminal, Ctrl-k to return to the code.
5. Stuck? Select lines with V and press Space a e, or Space a a and type a question. Close Firefox first.
6. Space c f to format. Space h p to see what you changed.
7. Commit from the terminal:

```
git status
git add -A
git commit -m 'what I changed'
```

## 8. Seven-day learning path

1. Day 1, movement and editing: run :Tutor inside Neovim. Learn h j k l, i, Esc, x, dd, u, Ctrl-r, w, b, 0, $, gg, G, /word.
2. Day 2, files, buffers, windows: :ls, Space b, Space s v, Ctrl-h/j/k/l, Space x.
3. Day 3, file tree and search: oil (Space e, rename a file, :w), Space f, Space /.
4. Day 4, LSP and completion: gd, K, grr, grn, Space d, Ctrl-Space in insert mode.
5. Day 5, Git: change a line, \]h, Space h p, Space g s, then git add and git commit in the terminal.
6. Day 6, terminal and workflow: Space t, run a script, fix an error, format with Space c f.
7. Day 7, local Qwen: explain a function, explain an error message, ask a Linux question. Notice the wait, and keep selections short.

Do not rush: one new idea per day is enough.

## 9. Local Qwen

- Start: nothing to do. The first question starts llama-server (about 30 seconds including loading from the HDD). It stops by itself after 10 idle minutes, on :QwenStop, or when you quit Neovim.
- RAM guard: if less than 1500 MB is free, it refuses to start and tells you to close Firefox.
- Limits: selections up to 3000 characters; answers up to 300 tokens. Speed measured here: about 3.9 tokens per second writing, 7.6 reading. Explaining 10 lines takes about a minute.
- It never edits your files. It shows suggestions in a window; you copy what you want (V, y, then p).
- Good at: explaining code, explaining errors, short snippets, Linux and config questions. Weaker at: subtle bugs in long code. Treat fixes as first drafts and check with git diff.
- Manual server for experiments:

```
llama-server -m ~/models/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf -t 2 -c 2048 -np 1 --host 127.0.0.1 --port 8080
```

## 10. Measured results on this laptop

| Item | Result |
| --- | --- |
| Neovim, no config | about 16 ms |
| Neovim, full config (warm) | about 68 to 83 ms (first run after heavy disk use: 1.4 s) |
| Neovim + jedi + ruff | about 33 + 59 + 48 MiB |
| Qwen server | about 1.8 GB RSS while running |
| Available RAM with Firefox open, nothing else | about 2.0 GiB |
| Qwen speed | 3.9 tokens/s writing, 7.6 tokens/s reading |

## 11. Benchmark commands

```
free -h                                          # RAM and swap
ps aux --sort=-%mem | head                       # biggest memory users
top                                              # live CPU and RAM (q to quit)
for i in 1 2 3; do nvim --startuptime /tmp/s$i.log +q; grep 'NVIM STARTED' /tmp/s$i.log | tail -1; done
sort -k2 -nr /tmp/s3.log | head                  # slowest startup steps
ps -eo rss,args | grep -E '[n]vim|[j]edi|[r]uff|[l]lama' | cut -c1-70   # RSS in KB
llama-bench -m ~/models/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf -t 2 -p 64 -n 32 -r 2   # Qwen speed (close Firefox)
```

## 12. Keeping RAM and startup low

- Close Firefox before using Qwen. It is the biggest memory user on this machine.
- Add a language server only when you start a project in that language, and check its RAM first.
- Optional: opt.swapfile = false in options.lua avoids stale swap-file warnings, at the cost of crash recovery.
- If startup passes 100 ms on warm runs, run the sort command above and comment out the slowest plugin's require line in init.lua.
- The first run after Qwen has loaded is slow because the HDD cache was replaced. Run again before judging.

## 13. Troubleshooting

**LSP not starting.** Check: `which jedi-language-server ruff`, and in Neovim on a .py file `:lua print(#vim.lsp.get_clients())`. Expected: two paths, and 2. Common cause: not a .py file, or init.lua lacks require('lsp'). Fix: `sudo pacman -S --needed jedi-language-server ruff` and `grep -n require ~/.config/nvim/init.lua`.

**Completion not appearing.** Check: LSP count above. In insert mode press Ctrl-Space. Expected: a menu. Cause: no server attached (completion is Python only for now). Fix: as for LSP.

**Treesitter or colors wrong.** Check: `:echo &syntax` and `pacman -Ql tree-sitter-python | grep highlights`. Expected: python, and a highlights.scm path. Cause: parser without highlight rules. Fix: our treesitter.lua then keeps the normal coloring.

**File tree not opening.** Check: `ls ~/.local/share/nvim/site/pack/core/opt/` and `:messages`. Expected: oil.nvim listed. Cause: the first launch had no internet. Fix: connect, restart Neovim.

**fzf not finding files.** Check: `which fzf fd rg` and `:checkhealth fzf-lua`. Expected: three paths, no ERROR. Cause: Neovim started outside the project folder, or .gitignore hides the files. Fix: cd into the project, then nvim.

**Formatter not working.** Check: `which ruff`, client count 2, file type python. Cause: ruff missing or not a Python file. Fix: `sudo pacman -S --needed ruff`.

**Git signs missing.** Check: `git rev-parse --is-inside-work-tree`. Expected: true. Cause: not a repository, or the file is untracked. Fix: `git init`, `git add .`, commit once.

**Qwen not responding.** Check: `free -h`, `curl -s http://127.0.0.1:8080/health`, `ls -lh ~/models`. Expected: 1500 MB or more available, status ok, a 1 GB file. Cause: low RAM or wrong model path. Fix: close Firefox; run the manual server command in section 9 to see its messages.

**llama.cpp not running.** Check: `pgrep -a llama-server`. Nothing printed is normal when idle. Cause: it only runs after you ask. Fix: ask a question, or use the manual command.

**RAM too high.** Check: `ps aux --sort=-%mem | head`. Fix: `:QwenStop`, close Firefox tabs, `pkill llama-server` if one is left over.

**Neovim slow.** Check: the startup loop in section 11, run three times. Cause: first run after a heavy disk load. Fix: judge runs two and three; if still slow, comment out the slowest plugin.

**E325 swap file warning.** Check: `pgrep -a nvim`. Cause: Neovim was closed without quitting (closing the window, shutting down). Fix: if no Neovim is running and nothing unsaved matters, `rm ~/.local/state/nvim/swap/*`.

## 14. Maintenance

- Back up the config and track changes (once):

```
cd ~/.config/nvim && git init && git add . && git commit -m 'nvim config'
```

- System: `sudo pacman -Syu`. Read the list first, and never update packages without a full -Syu on Arch.
- Plugins: in Neovim run `:lua vim.pack.update()`, read the changes, and confirm. Check `:help vim.pack` if the command differs in your version. Versions are pinned in nvim-pack-lock.json.
- Model: download a newer GGUF into \~/models, change the MODEL path at the top of ai.lua, delete the old file with `rm`.
- Every month or so: repeat the benchmark commands in section 11 and compare with section 10.
