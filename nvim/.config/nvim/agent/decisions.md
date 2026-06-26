# 2026-06-26

## 2026-06-26: Startup crash — SIGKILL (Code Signature Invalid) on LuaSnip jsregexp.so

**Symptom:** After `brew upgrade` (Neovim 0.11.6 → 0.12.3 on macOS Tahoe / Darwin 25.5), `nvim` died instantly at startup with `zsh: killed`. No Lua error, no crash dialog. `nvim -u NONE` started fine; full config did not.

**Diagnosis path (for next time):**
1. `nvim --headless +q` exited `137` (128+9 = SIGKILL), not a normal error.
2. macOS crash report under `~/Library/Logs/DiagnosticReports/nvim-*.ips` showed `EXC_BAD_ACCESS / SIGKILL (Code Signature Invalid)`, CODESIGNING "Invalid Page".
3. The faulting backtrace was in **dyld during `dlopen`**, called from **libluajit** while sourcing the config (`nlua_exec_file` → `lua_pcall` → `dlopen`) — i.e. a native `.so` `require`d at startup, NOT a config logic bug. (The `libtree-sitter` mention in the first report was a red herring.)
4. Hooking `package.loadlib` via `--cmd` pinned the exact file:
   `nvim --cmd 'lua local ol=package.loadlib; package.loadlib=function(p,f) local fh=io.open("/tmp/load.txt","a"); fh:write(tostring(p).."\n"); fh:close(); return ol(p,f) end' --headless +q`
   Last logged load before the kill = the culprit.

**Root cause:** `~/.local/share/nvim/lazy/LuaSnip/deps/luasnip-jsregexp.so` (locally-compiled native module LuaSnip loads at startup) had an **invalid ad-hoc code signature**. It passed static `codesign -v` ("valid on disk") but failed dyld's stricter runtime page-signature check on macOS Tahoe, so the kernel SIGKILLed nvim the instant it was `dlopen`ed. Mach-O was otherwise correct (arm64, minos 26.0).

**Fix applied:** re-sign the offending `.so`:
```bash
codesign --force --sign - ~/.local/share/nvim/lazy/LuaSnip/deps/luasnip-jsregexp.so
```
Confirmed: full config now starts clean (exit 0).

**Durability / next steps:** the re-sign holds until LuaSnip recompiles jsregexp (e.g. on `:Lazy update`), which can reintroduce a bad signature. If the SIGKILL returns, re-run the `codesign --force --sign -` line on that `.so`. **User barely uses LuaSnip — removing it entirely is an acceptable permanent fix if this recurs** (would drop snippet expansion; friendly-snippets/cmp_luasnip depend on it). Same `codesign` trick applies to any locally-compiled `.so` that triggers this on Tahoe.

**Unrelated 0.12 API fixes made in the same session** (real removals surfaced by the version bump, not the crash cause):
- `lspconfig.lua` — `vim.lsp.with()` / `vim.lsp.handlers[...]` overrides were removed in 0.12 → replaced with `vim.o.winborder = "rounded"` (global rounded borders for hover/signature/diagnostic floats).
- `autocommands.lua` — `vim.highlight.on_yank` → `vim.hl.on_yank` (renamed in 0.11+).
- `99.lua` — hardcoded `/Users/briangildea/...` dir → `vim.fn.expand("$HOME/things/myc/99/master")` for cross-machine portability (two machines with different usernames). Also required creating the missing git worktree locally: `git --git-dir=.bare worktree add master master` in `~/things/myc/99`.

# 2026-06-22

## 2026-06-22: 99 — local checkout + expanded keymaps
Switched the `99` plugin spec from the remote `"ThePrimeagen/99"` to a local checkout: `dir = "/Users/briangildea/things/myc/99/master"`. Reason: developing/iterating against a local copy of the plugin rather than the published repo.

Added 5 keymaps under the `<leader>a` (+ai) prefix in `99.lua`: `aV` vibe (AI session → quickfix), `at` tutorial, `ao` reopen last result, `am` select model (telescope), `ap` select provider (telescope). Existing `av`/`as`/`ax` unchanged. Updated the `+ai` block in `keymaps.lua` legend to match (source note now "local 99", box alignment verified at 78 cols). No keymap conflicts.

# 2026-06-17

## 2026-06-17: nvim-treesitter-textobjects API fix (follow-up to 2026-05-30 migration)
The 2026-05-30 migration switched to `branch = "main"` but the config still passed `keymaps`/`goto_next_start`/etc. inside `setup({...})`. Two issues compounded the failure:

1. **Stale on-disk checkout.** `lazy-lock.json` pinned commit `851e865` (the rewritten main with `.setup()`), but `~/.local/share/nvim/lazy/nvim-treesitter-textobjects` was still at `ad8f0a4` (pre-rewrite, only `M.init` / `define_modules` — no `setup` field, hence `attempt to call field 'setup' (a nil value)`). Fix: `git fetch origin main && git checkout 851e865` directly in the plugin dir — `:Lazy restore` would do the same.
2. **Wrong setup schema.** The rewrite's `setup()` accepts only `select.{lookahead, lookbehind, selection_modes, include_surrounding_whitespace}` and `move.set_jumps`. Bindings must be set manually:
   - `vim.keymap.set({"x","o"}, lhs, function() require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects") end)`
   - `vim.keymap.set({"n","x","o"}, lhs, function() require("nvim-treesitter-textobjects.move").goto_*(query, "textobjects") end)`

Rewrote `treesitter-objects.lua` accordingly. All original bindings preserved: `af/if`, `ac/ic`, `ai/ii`, `al/il`, `at`, `]m/[m`, `]]/[[`, `]M/[M`, `][/[]`. Selection modes (`@parameter.outer=v`, `@function.outer=V`, `@class.outer=<c-v>`) and `include_surrounding_whitespace = true` kept.

# 2024-12-11
Adding oil to try out buffer editing for file tree

# 2024-11-04
Added Noice cuz it's sexy

# 2025-03-18
removed noice, illuminate, dadbod. no need.

# 2025-11-19

## 2025-11-19: Initial Scan
Built plugin index (43+ plugins), established baseline memory, documented architecture (lazy.nvim, LSP, dual fuzzy finders, git tools, manual formatting).

## 2025-11-19: Keymap Consolidation
Consolidated keymaps to single source of truth in `keymaps.lua` (lines 29-105). Removed duplicate info from plugins.md and memory.md. Agent files now focus on understanding (why/when) vs documentation (what key).

## 2025-11-19: lazydev.nvim
Added for faster Lua LSP development. Modern replacement for neodev (Neovim >= 0.10). Lazy-loads workspace libraries, integrated with cmp. Updated plugins.md (44+ total).

## 2025-11-19: luacheck Integration
Added `.luacheckrc` for static analysis. Recognizes `vim` global, ignores callback patterns. Updated `agent.md` with `*check lint` command documentation.

## 2025-11-20: Diffview + Which-Key Fix
Configured `neogit-diffview.lua` with explicit which-key registration via FileType autocmd (pattern from fzf-lua). Documents all keybindings: `<tab>/<s-tab>`, `[x/]x`, `<leader>co/ct/cb/ca`, `gf/<C-w>gf`, `g<C-x>`, `-/s/S/U`, `L`, `g?`.

## 2025-11-21: hop.nvim → leap.nvim
Replaced hop with leap.nvim. Removed hop.lua, created leap.lua with preview filter, equivalence classes, repeat keys, and explicit s/S mappings. Updated keymaps.lua legend. New bindings: `s` forward, `S` cross-window.

## 2025-11-25: cmp.lua Cleanup
Removed dadbod-completion references (lines 43, 93-98) - plugin was removed. Removed redundant cmp-npm.setup() call (already in cmp-npm.lua). Removed redundant global formatting config (lines 24-26). Added lua_ls diagnostic suppression (`---@diagnostic disable-next-line: undefined-field`) for false positive on `cmp.config.sources`. Config now has 6 completion sources.

## 2025-11-26: mason-lspconfig v2.0 Migration
Migrated from deprecated `handlers` API to Neovim 0.11+ `vim.lsp.config()` API. mason-lspconfig v2.0+ removed handlers entirely. Server configs (basedpyright, lua_ls, etc.) now defined in lspconfig.lua using vim.lsp.config(). Fixed basedpyright typeCheckingMode="off" not being applied.

## 2025-11-28: Removed tailwindcss-language-server
Uninstalled tailwindcss LSP via Mason. Was causing BufReadPost errors when oil.nvim created special buffers - tailwindcss root_dir function (lsp/tailwindcss.lua:130) received invalid bufnr and crashed on nvim_buf_get_name(). Never explicitly configured, not in ensure_installed, no tailwind config files found. User only needs tailwindcss-colorizer-cmp plugin (works without LSP).

## 2025-12-03: which-key v3 + Keymap Legend Improvements
Updated which.lua from v2 to v3 format. Added group labels (`ai`, `git`, `hunks`, `lint/log`, `search`, `user`, `workspace`, `harpoon`, `prev`, `next`) and descriptions for leader single keys so which-key shows readable names instead of raw commands. Reformatted keymaps.lua legend with box-drawing characters for cleaner visualization. Removed redundant `<leader>f` LSP format keymap from lspconfig.lua (F6/conform handles formatting).

## 2025-12-03: Migration to lazy.nvim keys spec
Migrated 17 plugin files from `vim.keymap.set`/`wk.add()` in config to lazy.nvim `keys` spec. Benefits: plugins lazy-load on keypress, no which-key dependency for keymaps, descriptions centralized with keymaps, cleaner declarative config.

**Converted:** fzf-lua, markdown-preview, bufferline, indent-blankline, zenmode, ccc, trouble, conform, nvim-lint, harpoon, git-worktree, neogit-diffview, oil, telescope, leap, comment, iconpicker, aerial.

**Kept as vim.keymap.set:** lspconfig (LspAttach), gitsigns (buffer-local), aerial on_attach (`{`/`}`), neogit-diffview (diffview buffer keymaps), luasnip (insert mode).

**which.lua simplified:** Now contains only groups (for `+` prefix) and keymaps.lua items without desc. Added subgroups: `<leader>gc` (create), `<leader>sc` (commands), `<leader>sg` (git search).

## 2025-12-03: Config Cleanup
Fixed 12 issues from deep dive audit:
- Removed duplicate terraform autocommands from lazy.lua (kept in core/init.lua)
- Removed undotree, `<leader>r`, `<leader>d` from legend (not implemented)
- Removed duplicate harpoon setup (kept in telescope.lua for integration)
- Removed `<leader>ux` (duplicate of `<leader>c`)
- Commented out `s` black hole keymap (leap.nvim uses it)
- Fixed lualine globalstatus=true (matches laststatus=3)
- Removed global `<leader>uc` (buffer-local in lspconfig is correct)
- Updated plugins.md oil default_file_explorer status
- Changed CodeiumDisable → WindsurfDisable in autocommands
- Removed unused solarized config from colors.lua
- Removed redundant `<C-h/j/k/l>` from keymaps.lua (tmux-navigator handles it)
- Set treesitter-context max_lines=4
- Added lazy loading event to gitsigns

## 2025-12-03: neotest Integration
Added test runner framework with adapters for pytest, jest, and Go. Bound to `<F3>` as which-key group.

**New plugin:** `neotest.lua` with:
- `neotest-python` (pytest)
- `neotest-jest`
- `neotest-golang`

**Keymaps (F3 prefix):**
- `n` nearest test, `f` file tests, `p` project tests
- `l` last test, `s` summary, `o/O` output
- `x` stop, `w` watch file
- `[t/]t` jump to prev/next failed test

## 2026-04-10: Auto-reload buffers on external file changes
Added `autoread` + `checktime` autocmd + tmux `focus-events on` so Neovim buffers auto-reload when files are edited externally (e.g., Claude Code in another tmux window). Three changes: tmux forwards focus events → Neovim fires `FocusGained`/`BufEnter` → `checktime` compares timestamps → `autoread` silently reloads.

## 2026-05-07: Added ThePrimeagen/99 (AI agent)
Added `lua/wormholecowboy/plugins/99.lua`. Fills the long-reserved `<leader>a` AI placeholder (which-key already had `{ "<leader>a", group = "ai" }`). Lazy-loaded via `keys` spec only — no user commands are registered upstream.

**Provider:** `ClaudeCodeProvider`. The plugin shells out to `claude --dangerously-skip-permissions --model <model> --print <query>` (providers.lua:192-201). The skip-permissions flag is upstream behavior, not configurable; acceptable because every invocation is user-initiated via a keymap and short-lived.

**Model:** `"opus"`. The claude CLI accepts `opus` / `sonnet` / `haiku` as aliases for "latest in family" (per `claude --help`); using the alias auto-tracks new releases instead of pinning to a specific version like `claude-opus-4-6` that goes stale. Runtime override available via `require("99.extensions.telescope").select_model()`.

**Keymaps:** `<leader>av` (visual replace), `<leader>as` (search), `<leader>ax` (stop). Remapped from upstream `<leader>9*` defaults to fit the existing `<leader>a` AI namespace convention. Updated `core/keymaps.lua` legend.

**Prerequisite verified:** `claude` CLI present at `/opt/homebrew/bin/claude` (v2.1.118).

## 2026-05-30: nvim-treesitter migration — native Neovim 0.12 treesitter

**Root cause:** nvim-treesitter `master` branch is frozen and incompatible with Neovim 0.12. The `Query:iter_matches()` API changed in 0.12 so `match[id]` returns a list of nodes instead of a single node; calling `.range()` on the table produced `attempt to call method 'range' (a nil value)`. nvim-treesitter was also archived on 2026-04-03.

**Changes made:**
- `treesitter.lua` — switched to `branch = "main"`, removed `require("nvim-treesitter.configs").setup()` entirely. Now only manages parser installation via `opts.ensure_installed`.
- `treesitter-objects.lua` — switched to `branch = "main"`, removed nvim-treesitter dependency, moved all textobjects/move config here with new standalone `require("nvim-treesitter-textobjects").setup({})` API.
- `autotag.lua` — added explicit `require("nvim-ts-autotag").setup()` (was relying on nvim-treesitter.configs integration).
- `autocommands.lua` — added FileType autocmd calling `pcall(vim.treesitter.start)` for native Neovim 0.12 highlighting.

**After this change:** Run `:Lazy update nvim-treesitter nvim-treesitter-textobjects` then `:TSUpdate` in Neovim. If parser compilation fails, install `tree-sitter-cli` first: `brew install tree-sitter`.

