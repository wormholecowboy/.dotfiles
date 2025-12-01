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

