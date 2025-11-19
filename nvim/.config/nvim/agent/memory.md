# Agent Memory User Preferences & Patterns
*Updated: 2025-11-19 during initial scan*
*Keymaps consolidated: 2025-11-19 - All keymaps now in keymaps.lua only*

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
6. **Official docs first** - Always use official documentation when researching Neovim and plugins

### UI Preferences
- **Theme:** focuspoint (chase/focuspoint-vim) - active
- **Theme collection:** Keeps 12+ themes available for experimentation
- **Statusline:** lualine with full buffer path display
- **Bufferline:** Underline indicator style
- **Borders:** Rounded borders on LSP hover/signature
- **Diagnostic signs:** Emoji-style (Ԡ=,9)
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
**For all specific keymaps:** See `lua/wormholecowboy/core/keymaps.lua` (lines 29-105)

- **Leader:** Space (primary), Comma (harpoon)
- **Organized prefixes:** Clear mental model with logical groupings
- **Disabled keys:** Q, <C-z>
- **Text manipulation:** Keep cursor centered during navigation

---

## Workflow Patterns

### File Navigation
1. **Primary:** fzf-lua for fuzzy finding - seems preferred over telescope
2. **Quick access:** harpoon for 6 frequent files
3. **Tree view:** aerial for code outline
4. **File explorer:** oil.nvim in float mode
5. **Quick motion:** hop.nvim for word jumping

### Git Workflow
1. **Primary interface:** neogit for magit-style git operations
2. **Diff viewing:** diffview for detailed diffs
3. **Hunk management:** gitsigns for inline git decorations
4. **Worktrees:** Active user of git worktrees
5. **Search commits:** fzf-lua git integration

### Code Editing
1. **Completion:** nvim-cmp with LSP + buffer + path + npm sources
2. **Snippets:** LuaSnip with friendly-snippets
3. **LSP navigation:** Standard `g*` prefix pattern
4. **Diagnostics:** Trouble for list view, inline with virtual text
5. **Formatting:** Manual via conform (no auto-save)
6. **Linting:** Auto on save/enter, manual trigger available

### Special Modes
1. **Writing Mode:**
   - Activates ZenMode
   - Disables completion
   - Enables word wrap + linebreak
   - Disables Codeium AI
   - Minimal scroll offset
   - For markdown/prose editing

2. **Zen Mode:**
   - Distraction-free coding
   - Standalone toggle

### Development Tools
1. **Logging:** Custom variable logger
   - Detects variable/expression intelligently
   - Language-aware (JS/TS/Python)
   - Inserts console.log or print statement

2. **Color tools:**
   - CCC color picker for visual color selection
   - Tailwind colors in completion

3. **Icons/Emoji:** Icon picker in insert mode

---

## LSP Configuration

### Installed Servers (via mason)
- **basedpyright** - Python (modern, with inlay hints)
- **ts_ls** - JavaScript/TypeScript
- **bashls** - Bash scripting
- **terraformls** - Terraform/HCL
- **lua_ls** - Lua (configured for Neovim development)

### LSP Usage Pattern
- **Navigation:** `g*` prefix for all LSP navigation commands
- **Actions:** Code actions and rename via leader namespace
- **Diagnostics:** Navigate with bracket notation, view in float
- **Workspace:** Workspace folder management available

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
User has configured rich text objects via treesitter:
- Functions (outer/inner)
- Classes (outer/inner)
- Conditionals (outer/inner)
- Loops (outer/inner)
- Comments (outer)
- Movement commands for functions and classes

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

### Frequently Used Operations
- Find files via fzf-lua
- Grep strings in project
- File explorer toggle
- Git status interface
- Hop to word navigation
- Harpoon file slots

### Tmux Integration
- Seamless vim/tmux pane navigation
- Indicates heavy tmux use in workflow

### Buffer Management
- Next/prev buffer navigation
- Close buffer (keep window)
- Close split buffer
- Move buffer order in bufferline

---

## Future Considerations

### Explicit Placeholders
- **AI integration** - Leader key reserved but unused
- Codeium mentioned in Writing Mode (might be installed separately?)

### Workflow Gaps
1. **Session management** - No persistence plugin
2. **Project switching** - No project.nvim or similar
3. **Debugging** - No DAP setup
4. **Testing** - No test runner integration
5. **Note-taking** - References `pnotes` directory but no note plugin

### Config Maintenance
- **Quick edits configured for:**
  - .zshrc
  - nvim config
  - pnotes
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
