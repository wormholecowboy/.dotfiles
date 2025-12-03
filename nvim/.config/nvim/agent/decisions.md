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

