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

## 2026-06-10: NVM `--no-use` + `.zshenv` PATH

**Problem:** Eager NVM sourcing accounted for ~80% of shell startup (~1050ms of ~1300ms). Most of the cost was `nvm_auto`/`nvm_ensure_version_installed` — the auto-`nvm use` step, not loading the function itself.

**Changes made:**
1. Created `zsh/.zshenv` that resolves the NVM default alias chain (`default` → `lts/*` → `lts/krypton` → `v24.14.1`) and prepends that version's bin to `PATH`, without sourcing `nvm.sh`. `.zshenv` is read by *all* zsh invocations including non-interactive (Claude Code's Bash tool, scripts) — fixes the 2026-04-09 regression at the root.
2. Changed `.zshrc` NVM source to use `--no-use` flag (per [nvm-sh/nvm#1261](https://github.com/nvm-sh/nvm/issues/1261)) — loads the `nvm` command but skips the slow auto-activation.
3. Dropped the duplicate `nvm.sh` source (both paths were the same symlinked file).
4. Symlinked `~/.zshenv → .dotfiles/zsh/.zshenv` (matching the `.zshrc` pattern).

**Result:** 1.29s → 0.24s startup (~5x faster). `node`/`npm` available in interactive shells, non-interactive shells, and Claude Code's Bash tool. `nvm` command still works interactively.

**Maintenance notes:**
- If `nvm alias default` is ever changed, `.zshenv` re-resolves on next shell startup — no manual action needed.
- Remaining startup cost (~75ms) is mostly `compaudit`/`compinit`; not worth optimizing yet.
