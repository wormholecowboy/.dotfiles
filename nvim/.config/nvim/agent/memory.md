# Agent Memory  User Preferences & Patterns
*Updated: 2025-11-19 during initial scan*

## User Profile

**Username:** wormholecowboy
**Primary Languages:** JavaScript/TypeScript, Python, Ruby, Go, Terraform
**Environment:** macOS (Darwin 25.1.0), tmux user
**Workflow:** Git-heavy with worktrees, manual formatting preferred

---

## Configuration Philosophy

### Core Preferences
1. **Minimalism over features** - Removed noice, illuminate, dadbod (2025-03-18)
2. **Manual over automatic** - No format-on-save, no auto markdown preview
3. **Performance conscious** - Heavy lazy loading, indent guides off by default
4. **Keyboard-driven** - Comprehensive keybindings, tmux integration
5. **Git-centric** - Multiple git tools (neogit, gitsigns, diffview, worktrees)

### UI Preferences
- **Theme:** focuspoint (chase/focuspoint-vim) - active
- **Theme collection:** Keeps 12+ themes available for experimentation
- **Statusline:** lualine with full buffer path display
- **Bufferline:** Underline indicator style
- **Borders:** Rounded borders on LSP hover/signature
- **Diagnostic signs:** Emoji-style (Ô =,9)
- **Virtual text:** Enabled but toggleable

### Editing Behavior
- **Indentation:** 2 spaces, smart indent
- **Wrapping:** Off by default (except "Writing Mode")
- **Line numbers:** Relative + absolute
- **Scroll offset:** 8 lines
- **No swap files** - Undo directory at ~/.vim/undodir
- **System clipboard:** Always integrated
- **Better pasting:** Black hole register for x/c/s/r

### Keymap Philosophy
- **Leader:** Space
- **Secondary leader:** Comma (for harpoon)
- **Organized prefixes:** Clear mental model documented in keymaps.lua
- **Disabled keys:** Q, <C-z>
- **Escape alternatives:** `kj` in insert mode, `QQ` for quit
- **Text manipulation:** Keep cursor centered (C-d, C-u, n, N, *, #)

---

## Workflow Patterns

### File Navigation
1. **Primary:** fzf-lua (`<leader>sf`) - seems preferred over telescope
2. **Quick access:** harpoon for 6 frequent files
3. **Tree view:** aerial for code outline (`<leader>t`)
4. **File explorer:** oil.nvim in float mode (`<leader>e`)
5. **Quick motion:** hop.nvim for word jumping (`<leader>f`)

### Git Workflow
1. **Primary interface:** neogit (`<leader>gg`)
2. **Diff viewing:** diffview (`<leader>gv/gx`)
3. **Hunk management:** gitsigns with extensive `<leader>h*` bindings
4. **Worktrees:** Active user of git worktrees (`<leader>gw/gcw`)
5. **Search commits:** fzf-lua git integration

### Code Editing
1. **Completion:** nvim-cmp with LSP + buffer + path + npm sources
2. **Snippets:** LuaSnip with friendly-snippets
3. **LSP navigation:** Standard `g*` prefix (gd, gr, etc.)
4. **Diagnostics:** Trouble for list (`<leader>D`), inline with virtual text
5. **Formatting:** Manual via conform (`<leader>uf`)
6. **Linting:** Auto on save/enter, manual trigger (`<leader>ll`)

### Special Modes
1. **Writing Mode** (`<leader>q`):
   - Activates ZenMode
   - Disables completion
   - Enables word wrap + linebreak
   - Disables Codeium AI
   - Minimal scroll offset
   - For markdown/prose editing

2. **Zen Mode** (`<leader>z`):
   - Distraction-free coding
   - Standalone toggle

### Development Tools
1. **Logging:** Custom variable logger (`<leader>lv`)
   - Detects variable/expression intelligently
   - Language-aware (JS/TS/Python)
   - Inserts console.log or print statement

2. **Color tools:**
   - CCC color picker (`<M-c>`)
   - Tailwind colors in completion

3. **Icons/Emoji:** Icon picker in insert mode (`<C-e>`)

---

## LSP Configuration

### Installed Servers (via mason)
- **basedpyright** - Python (modern, with inlay hints)
- **ts_ls** - JavaScript/TypeScript
- **bashls** - Bash scripting
- **terraformls** - Terraform/HCL
- **lua_ls** - Lua (configured for Neovim development)

### LSP Keybindings Pattern
- **Navigation:** `g*` prefix (definition, declaration, implementation, type, references)
- **Actions:** `<leader>uc` (code actions), `<F2>` (rename)
- **Diagnostics:** `[d/]d` (navigation), `gl` (float)
- **Workspace:** `<leader>uw*` (add/remove/list folders)

### Formatting & Linting Strategy
- **Formatter:** conform.nvim (no auto-save)
- **Linter:** nvim-lint (auto on events)
- **Python:** pylint with custom .pylintrc, black + isort
- **JS/TS:** prettierd/prettier
- **Lua:** stylua
- **Manual trigger preferred** - User wants control

---

## Treesitter Usage

### Enabled Features
- **Syntax highlighting** - Primary use
- **Auto-indent** - Enabled
- **Context** - Function/class context at top (nvim-treesitter-context)
- **Text objects** - Extensive (functions, classes, conditionals, loops, comments)
- **Auto-tag** - For HTML/JSX

### Text Object Patterns
User has configured rich text objects:
- `af/if` - function outer/inner
- `ac/ic` - class outer/inner
- `ai/ii` - conditional outer/inner
- `al/il` - loop outer/inner
- `at` - comment outer
- Movement: `]m/[m` for functions, `]]/[[` for classes

---

## Anti-Patterns (Things User Explicitly Avoids)

1. **No auto-formatting** - Removed format_on_save
2. **No excessive UI** - Removed noice.nvim
3. **No word highlighting** - Removed illuminate
4. **No database UI** - Removed dadbod (may reconsider for SQL work)
5. **Not using netrw** - Prefers oil.nvim
6. **Minimal notifications** - lazy.nvim checker notify=false, change_detection notify=false

---

## Technology Stack Indicators

### Primary Development
- **Frontend:** JavaScript/TypeScript/React (tsx, jsx configs)
- **Backend:** Python, Ruby, Go
- **Infrastructure:** Terraform (custom filetype detection)
- **Shell:** Bash, zsh (.zshrc quick edit)
- **Tooling:** Docker (Dockerfile syntax), JSON, Markdown

### Build/Package Managers Visible
- npm (cmp-npm plugin)
- Python packages (pylint configuration)
- Go modules (gofmt)
- Ruby gems (standardrb)

### Notable Absences
- **No Rust tooling** (rustfmt in conform but no rust LSP)
- **No Java/Kotlin LSP** (formatters present but no LSP)
- **No debugging setup** (no DAP/nvim-dap)
- **No testing framework** (no neotest)
- **No AI integration yet** (`<leader>a` placeholder)

---

## Quick Access Patterns

### Frequently Used Combos
- `<leader>sf` ’ Find files
- `<leader>ss` ’ Grep string
- `<leader>e` ’ File explorer
- `<leader>gg` ’ Git status
- `<leader>f` ’ Hop to word
- `,a/s/d/f` ’ Harpoon slots

### Tmux Integration
- `<C-h/j/k/l>` - Seamless vim/tmux navigation
- Indicates heavy tmux use in workflow

### Buffer Management
- `L/H` - Next/prev buffer
- `<leader>c` - Close buffer (keep window)
- `<leader>ux` - Close split buffer
- `[b/]b` - Move buffer in bufferline

---

## Future Considerations

### Explicit Placeholders
- **AI integration** - `<leader>a` reserved but unused
- Codeium mentioned in Writing Mode (might be installed separately?)

### Workflow Gaps
1. **Session management** - No persistence plugin
2. **Project switching** - No project.nvim or similar
3. **Debugging** - No DAP setup
4. **Testing** - No test runner integration
5. **Note-taking** - References `pnotes` directory but no note plugin

### Config Maintenance
- **Quick edits configured:**
  - `<leader>uz` ’ Edit .zshrc
  - `<leader>uv` ’ Edit nvim config
  - `<leader>up` ’ Edit pnotes
- Indicates desire for fast config iteration

---

## Notes & Observations

### Code Quality
- Professional setup with modern patterns (2025 LSP practices)
- Comprehensive keymap documentation (rare and valuable)
- Clean separation of concerns (core vs plugins)
- Thoughtful lazy loading strategy

### Unique Aspects
1. **Dual fuzzy finders** - Both telescope and fzf-lua (seems to prefer fzf)
2. **Extensive git tooling** - More than typical setup
3. **Writing mode** - Shows prose/documentation work
4. **Terraform focus** - Custom filetype detection
5. **Variable logger** - Custom implementation for debugging

### Maintenance Habits
- Keeps decisions.md updated (3 entries found)
- Maintains colorscheme collection (12+)
- Comments explain "why" not just "what"
- Version pins where stability matters (telescope@0.1.8, LuaSnip@v2.*)

---

## Questions for Future Clarification

1. Is Codeium installed externally? (referenced but no plugin file)
2. What's in the `pnotes` directory? Personal knowledge base?
3. Why both telescope and fzf-lua? Performance comparison or feature overlap?
4. Any plans for debugging setup (DAP)?
5. Interest in AI/LLM integration beyond Codeium?
6. Would database work return (dadbod was removed)?

---

*This memory file will be updated via `*mem` command when new patterns emerge.*
