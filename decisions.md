# Decisions

## 2026-02-02: Optimize zsh startup time

**Problem:** Shell boot time was ~2.4s

**Changes made:**
1. Removed duplicate NVM block (was loading twice)
2. Removed duplicate `compinit` call (Docker had added a second one)
3. ~~Implemented lazy loading for NVM~~ (reverted 2026-04-09 — was causing issues)
4. Cached zoxide and starship init scripts (source static files instead of `eval`)

**Result:** 2.37s → 0.58s (75% faster)

**Maintenance notes:**
- After upgrading zoxide: `zoxide init zsh > ~/.config/zsh/zoxide.zsh`

## 2026-02-02: Replace starship with custom zsh prompt

**Problem:** Starship was an extra dependency to maintain

**Changes made:**
1. Created `~/.config/zsh/prompt.zsh` with native zsh prompt using `vcs_info`
2. Removed starship cached init script and config directory
3. Prompt replicates starship look: orange path (#FFA825), green git branch with white brackets

**Result:** Same 0.58s startup, one less dependency

**File:** `zsh/.config/zsh/prompt.zsh`

## 2026-04-09: Remove NVM lazy loading

**Problem:** Claude Code shells don't source `.zshrc`, so the lazy-load stubs never existed in those shells — meaning `node`/`npm` were unavailable to Claude Code's Bash tool.

**Changes made:**
1. Replaced lazy-load stubs with direct NVM sourcing in `.zshrc`

**Result:** NVM loads eagerly on shell startup (trades some startup time for reliability). Claude Code shells can access node/npm via PATH set by NVM.
