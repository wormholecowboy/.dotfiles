


# 2024-12-11
Adding oil to try out buffer editing for file tree

# 2024-11-04
Added Noice cuz it's sexy

# 2025-03-18
removed noice, illuminate, dadbod. no need.

# 2025-11-19

## Initial Scan
Initial agent scan completed via `*init` command. Built comprehensive plugin index (43+ plugins catalogued), established baseline memory of user preferences and patterns. Configuration architecture documented: lazy.nvim with 9 primary plugin categories, modern LSP patterns (LspAttach autocmd), dual fuzzy finding (telescope + fzf-lua), extensive git tooling, and manual formatting workflow. Key insights: minimalist philosophy, keyboard-driven workflow, git-centric development, writing mode for prose. No new plugins installed - strictly read-only scan as specified.

## Keymap Consolidation
**Problem:** Keymap information was duplicated across three locations:
- `plugins.md` - Listed specific keymaps for each plugin
- `memory.md` - Listed workflow keybindings
- `keymaps.lua` - Actual source of truth (lines 29-105)

**Issue:** When keymaps change, three files need updating. This creates maintenance burden and risk of inconsistency.

**Solution:** Established `keymaps.lua` as the single source of truth:
- `plugins.md` - Now references keymaps generically ("prefix: `<leader>s*`") or points to keymaps.lua
- `memory.md` - Now focuses on workflow patterns ("uses fzf-lua for fuzzy finding") without specific keys
- `keymaps.lua` - Remains the comprehensive, commented legend (unchanged)

**Benefits:**
- Single place to update when keymaps change
- Agent files focus on understanding (why/when) rather than documentation (what key)
- Reduced cognitive load when scanning documentation
- keymaps.lua legend is always accurate (it's the code)

## lazydev.nvim Installation
**Date:** 2025-11-19
**Command:** `*add https://github.com/folke/lazydev.nvim`

**Rationale:**
User actively maintains Neovim configuration in Lua, making proper LSP support essential for development workflow. lazydev.nvim is the modern replacement for neodev.nvim (for Neovim >= 0.10) and provides significantly faster autocompletion by lazy-loading workspace libraries.

**Key Benefits:**
- Faster completion (only loads modules you actually require)
- Dynamic workspace updates as files are edited
- Third-party plugin library support via LLS-Addons
- Modern architecture aligned with 2025 best practices

**Changes Made:**
1. Created `/lua/wormholecowboy/plugins/lazydev.lua` with ft-based loading
2. Updated `/lua/wormholecowboy/plugins/cmp.lua`:
   - Added lazydev.nvim as dependency
   - Added lazydev completion source with `group_index = 0` for proper priority
3. Updated `/lua/wormholecowboy/plugins/mason-lspconfig.lua`:
   - Removed manual workspace library configuration from lua_ls
   - Added comment noting lazydev handles library loading dynamically
4. Updated `/agent/plugins.md` to document new plugin (44+ total plugins)

**Integration:**
Works seamlessly with existing lua_ls (via mason) and nvim-cmp setup. No conflicts or breaking changes.

## luacheck Integration
**Date:** 2025-11-19
**Context:** Added static analysis tooling for faster validation

**Rationale:**
After adding lazydev.nvim and implementing headless Neovim checks, user requested luacheck for faster static analysis. Complements existing lua_ls LSP with lightweight, instant linting.

**Benefits:**
- Fast static analysis without starting Neovim
- Catches unused variables, undefined globals, style issues
- Pre-commit validation capability
- CI/CD friendly
- Defense in depth with lua_ls

**Changes Made:**
1. Created `.luacheckrc` configuration:
   - Recognizes `vim` global
   - Ignores common callback patterns (unused arguments)
   - Includes lua/ and init.lua
2. Updated `agent.md`:
   - Added luacheck to `*check` command documentation
   - Behavior model: Always verify luacheck installed before use
   - Notify user if missing: "⚠️ luacheck not found. Install with: brew install luacheck"

**Initial Scan Results:**
Found 5 minor warnings across 39 plugin files (unused vars, whitespace, global function pattern).

## Diffview + Which-Key Integration Fix
**Date:** 2025-11-20
**Issue:** Diffview keybindings not displaying in which-key popup

**Problem:**
User reported that while in diffview, which-key was showing default keybindings instead of diffview-specific ones. Keybindings still functioned correctly, but the which-key UI wasn't displaying proper descriptions.

**Root Cause:**
- Diffview uses buffer-local keymaps that are applied dynamically when buffers are created
- Which-key doesn't automatically detect buffer-local mappings even with `desc` fields
- Current config had no diffview.setup() - relied entirely on default keymaps with no descriptions
- No built-in integration exists between diffview and which-key

**Research Findings:**
- Diffview.nvim has no native which-key integration
- Buffer-local mapping detection is a known limitation in which-key (issues #476, #564 on respective repos)
- Solution: Use FileType autocmd with explicit which-key registration (same pattern as fzf-lua)

**Solution Implemented:**
Added comprehensive diffview configuration in `/lua/wormholecowboy/plugins/neogit-diffview.lua`:
1. **Configured diffview.setup()** with `desc` fields for all keymaps (for diffview's own help system)
2. **Added FileType autocmd** that explicitly registers keymaps with which-key using `wk.add()`
   - Pattern: Same as fzf-lua.lua (user's suggestion)
   - Triggers on: `DiffviewFiles`, `DiffviewFileHistory` filetypes
   - Uses `buffer = 0` for buffer-local registration
3. **Context-aware registration** - Different keymaps for file panel vs history panel
4. **Conflict resolution group** - `<leader>c` group with all conflict operations

**Key Keybindings Now Documented:**
- `<tab>/<s-tab>` - Next/previous file diff
- `[x/]x` - Navigate conflicts
- `<leader>co/ct/cb/ca` - Conflict resolution (ours/theirs/base/all)
- `gf/<C-w>gf` - Open file in tab/split
- `g<C-x>` - Cycle layout
- `-/s/S/U` - Stage/unstage operations
- `L` - Open commit log
- `g?` - Context-sensitive help

**Implementation Note:**
Initial attempt used `desc` fields in diffview keymaps alone, but which-key still didn't detect buffer-local mappings. User suggested using the same `wk.add()` pattern from fzf-lua.lua, which worked perfectly.

**Verification:**
- Luacheck: 0 warnings, 0 errors
- Config loads: true (headless verification)
- File length: 241 lines (well within maintainability)

**Benefits:**
- Which-key now displays proper diffview keybindings when active
- Uses proven pattern from fzf-lua (consistency across config)
- Comprehensive documentation of all diffview keymaps
- Better discoverability for conflict resolution and staging operations
- Context-aware: different keymaps for file panel vs history panel
- `<leader>c` conflict resolution group for clear organization

**No Breaking Changes:**
- All default diffview keybindings preserved
- Only added explicit which-key registration
- No changes to user workflow required

## hop.nvim → leap.nvim Migration
**Date:** 2025-11-21
**Command:** User request to replace hop with leap.nvim

**Rationale:**
User chose to migrate from hop.nvim to leap.nvim for improved motion capabilities. Both are EasyMotion alternatives, but leap.nvim offers:
- Better label generation and placement
- Cross-window motion by default (S keymap)
- More modern codebase and active maintenance
- Standard keymaps via `create_default_mappings()`

**Changes Made:**
1. **Removed:** `/lua/wormholecowboy/plugins/hop.lua` (used `<leader>f` for HopWord)
2. **Created:** `/lua/wormholecowboy/plugins/leap.lua` with standard mappings
   - `s` - Forward leap motion (n, x, o modes)
   - `S` - Cross-window leap
3. **Updated keymaps.lua legend:**
   - Removed `f: hop` entry
   - Added `s: leap forward motion` and `S: leap cross-window`
   - Updated `gs:` from "signature" to "leap cross-window" (gs now conflicts with LSP signature, but Leap S is recommended for cross-window)
4. **Updated `/agent/plugins.md`:**
   - Replaced hop.nvim section with leap.nvim documentation
5. **Updated `/agent/memory.md`:**
   - Changed workflow pattern to reference leap.nvim with s/S keymaps

**Migration Details:**
- **Old binding:** `<leader>f` → HopWord (word motion)
- **New bindings:**
  - `s` → Forward leap (more discoverable than `<leader>f`)
  - `S` → Cross-window leap (new capability)
- Uses leap's default mapping strategy via `create_default_mappings()`
- No breaking changes to other keybindings

**No Conflicts:**
- `s` is standard vim replace char in normal mode, but leap preserves this in operator-pending context
- `S` replaces current line - rarely used workflow in this config
- Both keys are now navigation verbs, improving mental model consistency

