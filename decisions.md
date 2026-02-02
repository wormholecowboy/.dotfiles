# Decisions

## 2026-02-02: Optimize zsh startup time

**Problem:** Shell boot time was ~2.4s

**Changes made:**
1. Removed duplicate NVM block (was loading twice)
2. Removed duplicate `compinit` call (Docker had added a second one)
3. Implemented lazy loading for NVM (only loads when node/npm/nvm/npx is called)
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
