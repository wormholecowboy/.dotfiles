# Neovim Plugin Index
*Last updated: 2025-11-19*
*Consolidated keymaps: 2025-11-19 - All keymaps now referenced from keymaps.lua*
*Plugin addition: 2025-11-19 - Added lazydev.nvim for Lua development*

## Configuration Architecture

**Plugin Manager:** lazy.nvim (v11.x)
- Auto-imports from `lua/wormholecowboy/plugins/`
- Lazy loading via events: `BufReadPre`, `BufNewFile`, `InsertEnter`, `VeryLazy`
- Location: `lua/wormholecowboy/lazy.lua`

**Config Structure:**
```
nvim/
   init.lua (bootstrap)
   lua/wormholecowboy/
      lazy.lua (plugin manager setup)
      core/
         init.lua
         options.lua
         keymaps.lua (COMPREHENSIVE keymap legend - SINGLE SOURCE OF TRUTH)
         autocommands.lua
      plugins/ (43 plugin configs)
```

**For all keymaps:** See `lua/wormholecowboy/core/keymaps.lua` (lines 29-105)

---

## Plugin Inventory

### File Navigation & Management

#### oil.nvim
- **Repo:** stevearc/oil.nvim
- **Purpose:** Buffer-style file explorer (like vim's :edit for directories)
- **Key Features:**
  - Default file explorer (replaces netrw)
  - Trash instead of delete
  - LSP file methods enabled
  - Float window interface
- **Keymaps:** `<leader>e` prefix
- **Dependencies:** mini.icons

#### telescope.nvim
- **Repo:** nvim-telescope/telescope.nvim
- **Version:** 0.1.8
- **Purpose:** Fuzzy finder framework (just for git workflows)
- **Config:** Loads git_worktree extension, integrates harpoon
- **Keymaps:** `<M-f>` for harpoon integration
- **Dependencies:** plenary.nvim

#### fzf-lua
- **Repo:** ibhagwan/fzf-lua
- **Purpose:** Native fzf integration (main search tool)
- **Key Features:**
  - Searches: files, buffers, git files/branches/commits, help, keymaps, strings, marks
  - Custom fd/rg opts to include hidden files
- **Keymap prefix:** `<leader>s*`
- **Dependencies:** nvim-web-devicons

#### harpoon
- **Repo:** ThePrimeagen/harpoon
- **Branch:** harpoon2
- **Purpose:** Quick file marking and navigation (6 slots)
- **Keymap prefix:** `,*`
- **Dependencies:** plenary.nvim, telescope.nvim

---

### LSP & Completion

#### nvim-lspconfig
- **Repo:** neovim/nvim-lspconfig
- **Purpose:** Core LSP client configuration
- **Key Features:**
  - Modern LspAttach autocmd pattern (2025)
  - Rounded borders on hover/signature
  - Custom diagnostic signs
  - Workspace folder management
- **Keymaps:** Buffer-local on LSP attach - `g*` prefix for navigation, `<leader>u*` for actions, `[d/]d` for diagnostics
- **Dependencies:** cmp-nvim-lsp

#### lazydev.nvim
- **Repo:** folke/lazydev.nvim
- **Purpose:** Faster LuaLS setup for Neovim Lua development
- **Event:** ft = "lua" (filetype-based loading)
- **Key Features:**
  - Lazy loads workspace libraries (only modules you require)
  - Dynamic workspace updates as you edit
  - Third-party plugin library support
  - Replaces neodev.nvim for Neovim >= 0.10
- **Integration:** nvim-cmp completion source with group_index = 0
- **Dependencies:** None (integrates with lua_ls and nvim-cmp)
- **Note:** Handles lua_ls workspace configuration automatically

#### mason.nvim
- **Repo:** williamboman/mason.nvim
- **Purpose:** LSP/DAP/linter/formatter installer
- **Config:** Minimal (default opts)

#### mason-lspconfig.nvim
- **Repo:** williamboman/mason-lspconfig.nvim
- **Purpose:** Bridge mason and lspconfig
- **Ensures Installed:**
  - basedpyright (Python)
  - ts_ls (JS/TS)
  - bashls
  - terraformls
  - lua_ls (with vim global recognition)
- **Modern handlers-based setup (2025)**
- **Dependencies:** mason.nvim, nvim-lspconfig

#### nvim-cmp
- **Repo:** hrsh7th/nvim-cmp
- **Purpose:** Completion engine
- **Event:** InsertEnter
- **Sources:** lazydev (priority), nvim_lsp, luasnip, buffer, npm, path, vim-dadbod-completion
- **Key Features:**
  - Tailwind colorizer integration
  - Custom window styling
  - SQL filetype special config
- **Keymaps:** Configured in plugin file (`<C-n/p/l/y>`)
- **Dependencies:** cmp-nvim-lsp, cmp-buffer, cmp-path, cmp-cmdline, LuaSnip, lspkind.nvim, tailwindcss-colorizer-cmp

#### LuaSnip
- **Repo:** L3MON4D3/LuaSnip
- **Version:** v2.*
- **Purpose:** Snippet engine
- **Build:** `make install_jsregexp`
- **Key Features:**
  - VSCode snippet loader
  - Auto-cleanup jump points on InsertLeave
- **Keymaps:** Configured in plugin file (`<C-K/J>`)
- **Dependencies:** friendly-snippets, cmp_luasnip

#### cmp-npm
- **Repo:** David-Kunz/cmp-npm
- **Purpose:** NPM package completion in package.json
- **Filetype:** json
- **Dependencies:** plenary.nvim

#### Supporting Plugins
- **vim-surround** (tpope/vim-surround) - surround text objects
- **friendly-snippets** (rafamadriz/friendly-snippets) - snippet collection
- **cmp-path** (hrsh7th/cmp-path) - path completion
- **cmp-buffer** (hrsh7th/cmp-buffer) - buffer completion

---

### Treesitter

#### nvim-treesitter
- **Repo:** nvim-treesitter/nvim-treesitter
- **Event:** BufReadPre, BufNewFile
- **Build:** :TSUpdate
- **Parsers Installed:**
  - javascript, typescript, tsx
  - lua, vim, vimdoc, query
  - c, go, java, ruby, bash
  - html, json, jq, dockerfile
  - terraform, markdown
- **Key Features:**
  - Auto-install enabled
  - Indent enabled
  - Autotag enabled
  - Text objects configured (functions, classes, conditionals, loops)
- **Keymaps:** Text objects configured in plugin file (`af/if`, `ac/ic`, `ai/ii`, `al/il`, `at`)

#### nvim-treesitter-context
- **Repo:** nvim-treesitter/nvim-treesitter-context
- **Event:** BufReadPre, BufNewFile
- **Purpose:** Shows function/class context at top of window
- **Mode:** cursor
- **Max lines:** unlimited

#### nvim-treesitter-textobjects
- **Repo:** nvim-treesitter/nvim-treesitter-textobjects
- **Event:** BufReadPre, BufNewFile
- **Purpose:** Enhanced text objects via treesitter
- **Dependencies:** nvim-treesitter

---

### Git Integration

#### neogit
- **Repo:** NeogitOrg/neogit
- **Purpose:** Magit-style git interface
- **Key Features:**
  - vsplit commit editor
  - Staged diff shown
  - Spell check enabled
- **Keymap prefix:** `<leader>g*`
- **Dependencies:** plenary.nvim, diffview.nvim, fzf-lua

#### diffview.nvim
- **Repo:** sindrets/diffview.nvim
- **Purpose:** Advanced diff viewer
- **Integration:** Used by neogit

#### gitsigns.nvim
- **Repo:** lewis6991/gitsigns.nvim
- **Purpose:** Git decorations in sign column
- **Key Features:**
  - Custom signs (+, |, _, ~, ‾)
  - Current line blame (disabled by default)
  - Hunk navigation and staging
- **Keymap prefix:** `<leader>h*` and `]c/[c`

#### git-worktree.nvim
- **Repo:** ThePrimeagen/git-worktree.nvim
- **Purpose:** Manage git worktrees
- **Key Features:**
  - Auto cd on change
  - Clear jumps on change
  - Telescope integration
- **Keymaps:** `<leader>gw/gcw`

---

### Code Formatting & Linting

#### conform.nvim
- **Repo:** stevearc/conform.nvim
- **Event:** BufReadPre, BufNewFile
- **Purpose:** Async formatting
- **Formatters Configured:**
  - Python: isort, black
  - JS/TS/React: prettierd, prettier
  - Lua: stylua
  - Go: gofmt
  - Many others (see config for full list)
- **Keymaps:** `<leader>uf`
- **Note:** format_on_save disabled

#### nvim-lint
- **Repo:** mfussenegger/nvim-lint
- **Event:** BufReadPre, BufNewFile
- **Purpose:** Async linting
- **Linters Configured:**
  - Python: pylint (with custom .pylintrc)
  - Kotlin: ktlint
  - Terraform: tflint
  - Ruby: standardrb
- **Auto-lint:** BufEnter, BufWritePost, InsertLeave
- **Keymaps:** `<leader>ll/lv`

---

### UI & Appearance

#### lualine.nvim
- **Repo:** nvim-lualine/lualine.nvim
- **Purpose:** Statusline
- **Theme:** codedark
- **Sections:**
  - A: mode
  - B: branch, diff, diagnostics
  - C: full buffer path (custom function)
  - X: filetype
  - Y: progress
  - Z: location
- **Dependencies:** nvim-web-devicons

#### bufferline.nvim
- **Repo:** akinsho/bufferline.nvim
- **Purpose:** Buffer tabs at top
- **Key Features:**
  - Underline indicator style
  - LSP diagnostics integration
- **Keymaps:** `[b/]b` for reordering, `L/H` for navigation
- **Dependencies:** nvim-web-devicons

#### which-key.nvim
- **Repo:** folke/which-key.nvim
- **Event:** VeryLazy
- **Purpose:** Keymap hints popup
- **Timeout:** 300ms
- **Key Features:**
  - Marks and registers hints
  - Spelling suggestions
  - Custom operators (gc for comments)

#### indent-blankline.nvim
- **Repo:** lukas-reineke/indent-blankline.nvim
- **Purpose:** Rainbow indent guides
- **Key Features:**
  - 7 rainbow colors
  - Character: │
  - Disabled by default
- **Keymaps:** `<leader>i`
- **Note:** User prefers off by default

#### colors (Theme Collection)
- **Primary:** martinsione/darkplus.nvim
- **Active Theme:** focuspoint (chase/focuspoint-vim)
- **Available Themes:**
  - everforest (neanias/everforest-nvim) - configured
  - gruvbox (morhetz/gruvbox)
  - nightfox (EdenEast/nightfox.nvim)
  - mellow (kvrohit/mellow.nvim)
  - noctis (talha-akram/noctis.nvim)
  - gotham (whatyouhide/vim-gotham)
  - desertink (toupeira/vim-desertink)
  - molokai (tomasr/molokai)
  - ayu (ayu-theme/ayu-vim)
  - alduin (AlessandroYorba/Alduin)
  - happy_hacking (yorickpeterse/happy_hacking.vim)
- **Function:** ColorMyPencils() - theme switcher

---

### Editing Enhancements

#### nvim-autopairs
- **Repo:** windwp/nvim-autopairs
- **Event:** BufReadPre, BufNewFile
- **Purpose:** Auto-close pairs
- **Integration:** CMP integration for function parens

#### nvim-ts-autotag
- **Repo:** windwp/nvim-ts-autotag
- **Event:** BufReadPre, BufNewFile
- **Purpose:** Auto-close HTML/JSX tags

#### Comment.nvim
- **Repo:** numToStr/Comment.nvim
- **Event:** BufReadPre, BufNewFile
- **Purpose:** Smart commenting
- **Keymaps:** `<leader>/` toggle, `gb/gc` operators

#### leap.nvim
- **Repo:** ggandor/leap.nvim
- **Event:** BufReadPre, BufNewFile
- **Purpose:** Fast motion plugin for precise navigation
- **Keymaps:**
  - `s` - Forward leap motion (normal, visual, operator-pending modes)
  - `S` - Cross-window leap
- **Setup:** Uses `create_default_mappings()` for standard Leap behavior

---

### Productivity & Navigation

#### trouble.nvim
- **Repo:** folke/trouble.nvim
- **Event:** BufReadPre, BufNewFile
- **Purpose:** Pretty diagnostics list
- **Key Features:**
  - Auto-focus
  - No warn on empty
- **Keymaps:** `<leader>D`
- **Dependencies:** nvim-web-devicons

#### aerial.nvim
- **Repo:** stevearc/aerial.nvim
- **Purpose:** Code outline sidebar
- **Backends:** treesitter, lsp, markdown, asciidoc, man
- **Key Features:**
  - Lazy load
  - Close on select
  - Auto-jump
  - Prefer left placement
- **Keymaps:** `<leader>t` toggle, `{/}` navigation
- **Dependencies:** nvim-treesitter, nvim-web-devicons

#### todo-comments.nvim
- **Repo:** folke/todo-comments.nvim
- **Event:** BufReadPre, BufNewFile
- **Purpose:** Highlight TODO/FIXME/etc
- **Keywords:** FIX, TODO, HACK, WARN, PERF, NOTE, TEST
- **Search:** ripgrep integration
- **Dependencies:** plenary.nvim

#### zen-mode.nvim
- **Repo:** folke/zen-mode.nvim
- **Purpose:** Distraction-free writing
- **Keymaps:** `<leader>z`
- **Integration:** Used in "Writing Mode" autocommand

---

### Specialized Tools

#### ccc.nvim
- **Repo:** uga-rosa/ccc.nvim
- **Event:** BufReadPre, BufNewFile
- **Purpose:** Color picker
- **Key Features:**
  - Auto-enable highlighter
  - LSP integration
  - RGB, HSL, CMYK inputs
- **Keymaps:** `<M-c>`

#### icon-picker.nvim
- **Repo:** ziontee113/icon-picker.nvim
- **Purpose:** Emoji/icon/symbol picker
- **Keymaps:** `<C-e>` (insert mode)
- **Dependencies:** dressing.nvim, telescope.nvim

#### tailwindcss-colorizer-cmp.nvim
- **Repo:** roobert/tailwindcss-colorizer-cmp.nvim
- **Purpose:** Show Tailwind colors in completion menu
- **Config:** 2px color square

#### markdown-preview.nvim
- **Repo:** iamcco/markdown-preview.nvim
- **Build:** npm install in app/
- **Filetype:** markdown
- **Key Features:**
  - Manual start (not auto)
  - npx fallback for build
- **Keymaps:** `<leader>m`

#### vim-tmux-navigator
- **Repo:** christoomey/vim-tmux-navigator
- **Purpose:** Seamless tmux/vim pane navigation
- **Keymaps:** `<C-h/j/k/l>`

#### windsurf.vim
- **Repo:** Exafunction/windsurf.vim
- **Event:** BufEnter
- **Purpose:** Windsurf integration

---

## Special Configurations

### Terraform Filetype Detection
Located in `lua/wormholecowboy/lazy.lua` (lines 27-31):
- `.tf, .tfvars` → terraform
- `.hcl, .terraformrc, terraform.rc` → hcl
- `.tfstate, .tfstate.backup` → json

### Custom Autocommands
*See: `lua/wormholecowboy/core/autocommands.lua`*

1. **TextYankPost** - Highlight on yank (150ms)
2. **VimEnter** - Deferred keymaps for buffer path display, Writing Mode, and variable logger
3. **DiagnosticsToggleVirtualText** - User command to toggle diagnostic virtual text

### Keymap Organization
**For complete keymap reference:** `lua/wormholecowboy/core/keymaps.lua` (lines 29-105)

**Leader:** `<space>`

**Organizational structure:**
- `[]` prefix: diagnostics, git changes, buffer moving
- `g` prefix: LSP navigation (gd, gD, gi, gt, go, gr, gs, gl, gP)
- `<leader>` prefix: Main command namespace
  - `a` - AI (placeholder)
  - `c` - close buffer
  - `d/D` - diagnostics
  - `e` - file tree (oil)
  - `f` - hop (find)
  - `gg` - neogit + git commands
  - `h` - git hunks
  - `i` - toggle indent lines
  - `l` - linting + log var
  - `m` - markdown preview
  - `q` - writing mode
  - `r` - rename
  - `s` - search (fzf-lua)
  - `t` - aerial (tree)
  - `u` - user namespace
  - `w` - write
  - `z` - zen mode
- `,` prefix: harpoon operations
- `<C-*>`: Window/pane navigation
- `<M-*>`: Special tools (color picker, etc.)
- `F2`: Rename

**Disabled keys:** Q, <C-z>
**Better pasting:** x/p/r/s/c use black hole register

---

## Plugin Statistics
- **Total plugins:** 44+ (including dependencies)
- **Primary categories:** 9
- **LSP servers managed:** 5 (via mason-lspconfig)
- **Colorschemes available:** 12+
- **Lazy loading:** Heavy use of events for performance
- **Modern patterns:** LspAttach autocmd, handlers-based mason setup (2025)

---

## Notes & Observations

### User Preferences
1. **No format-on-save** - Manual formatting preferred
2. **Oil not default explorer** - Netrw still available
3. **Indent guides off by default** - Toggle when needed
4. **Virtual text diagnostics on** - But toggleable
5. **No noice/illuminate/dadbod** - Removed per decisions.md
6. **Focuspoint theme** - Current active colorscheme

### Architecture Strengths
1. **Comprehensive keymap documentation** - Inline legend in keymaps.lua (SINGLE SOURCE OF TRUTH)
2. **Consistent lazy loading** - Good startup performance
3. **Modern LSP patterns** - LspAttach autocmd (2025)
4. **Git workflow optimized** - Multiple complementary git tools
5. **Dual search** - Both telescope and fzf-lua available
6. **Professional code quality tools** - Conform + nvim-lint combo

### Potential Areas for Future Enhancement
1. Consider DAP/debugging setup (currently no debugger)
2. AI/LLM integration (placeholder in keymaps)
3. Session management (no auto-session or persistence plugin)
4. Project management (no project.nvim)
5. Testing integration (no neotest or similar)

### Removed Plugins (per decisions.md)
- noice.nvim - UI overhaul (2025-03-18)
- illuminate - word highlighting (2025-03-18)
- dadbod - database UI (2025-03-18)

---

## Maintenance Commands
- `:Lazy` - Plugin manager UI
- `:Mason` - LSP/tool installer UI
- `:TSUpdate` - Update treesitter parsers
- `:checkhealth` - Verify config health
- `:DiagnosticsToggleVirtualText` - Custom diagnostic toggle
