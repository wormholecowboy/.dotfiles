# Decisions

## 2026-08-01: vim-herdr-navigation moved to lazy.nvim (nvim side) — dropping the `~/things/myc` clone

**Problem:** The nvim keymaps were loaded by `dofile`-ing `~/things/myc/vim-herdr-navigation/editor/nvim.lua`. That clone isn't carried by dotfiles sync, so on machines without it `<C-h/j/k/l>` didn't map at all and tmux pass-through into nvim broke (bare tmux panes fine, dead inside nvim).

**Changes made:**
- nvim now installs `paulbkim-dev/vim-herdr-navigation` via lazy.nvim (folded into the `vim-tmux-navigator` spec, `lazy = false`, loads `editor/nvim.lua` from lazy's install dir). Deleted `after/plugin/herdr-nav.lua`. Detail in nvim `agent/decisions.md` (2026-08-01 entry).
- The herdr side (`navigate.sh` via `herdr plugin link` + config.toml keybinds) is unchanged and still works.

### ⚠ ACTION PENDING on the herdr machine — hand this to that machine's agent

The nvim side is done and synced via git. The herdr-side link still points at the
unwanted `~/things/myc/vim-herdr-navigation` and needs to move onto lazy's clone so
the myc copy can be deleted. Steps for the herdr machine:

1. `git pull` this dotfiles repo so the updated `nvim/.../plugins/tmux-navigator.lua`
   is in place.
2. Install the plugin under lazy: open nvim once, or headless:
   ```bash
   nvim --headless "+Lazy! sync" +qa
   ```
   This clones it to `~/.local/share/nvim/lazy/vim-herdr-navigation`.
3. Re-point herdr at that dir and remove the old clone:
   ```bash
   herdr plugin unlink vim-herdr-navigation
   herdr plugin link ~/.local/share/nvim/lazy/vim-herdr-navigation
   herdr server reload-config          # or prefix+r inside herdr
   rm -rf ~/things/myc/vim-herdr-navigation
   ```
4. Verify:
   - `herdr plugin list` shows `vim-herdr-navigation` linked to the
     `~/.local/share/nvim/lazy/...` path.
   - Inside a herdr pane running nvim, `<C-h/j/k/l>` crosses from a vim split edge
     into the neighbouring herdr pane; in a bare herdr pane it moves pane focus.

After this the lazy install dir is the single source for both nvim and herdr — nothing
in `~/things/myc`. Caveat: removing the plugin from the nvim config would then also
break the herdr link (shared clone).

## 2026-07-31: herdr trial — tmux-parity config, tmux left untouched

**Problem:** Evaluating herdr (terminal workspace manager) as a possible tmux replacement. Needed the muscle-memory bindings ported without breaking the existing tmux setup during the trial.

**Changes made:**
1. Built `herdr/.config/herdr/config.toml` mirroring `.tmux.conf`: prefix `ctrl+a`, `prefix+s` workspace picker, `prefix+o` native fuzzy goto, `prefix+r` reload, `prefix+[` copy mode, `prefix+"`/`prefix+%` splits, lazygit popups on `prefix+g`/`G`, nvim scratch pane on `prefix+P`, fzf multi-select workspace kill on `prefix+K` (via `herdr workspace list` JSON + jq), dracula theme.
2. Adopted [vim-herdr-navigation](https://github.com/paulbkim-dev/vim-herdr-navigation) (cloned to `~/things/myc/vim-herdr-navigation`, registered with `herdr plugin link`) for bare `ctrl+h/j/k/l` vim-aware pane navigation — replaces an equivalent homegrown script.
3. nvim: `<C-h/j/k/l>` now mapped by the plugin's `editor/nvim.lua` (loaded from `after/plugin/herdr-nav.lua`), which detects herdr vs tmux via env vars at runtime — see nvim's `agent/decisions.md` for detail.
4. Last-workspace jump (tmux `prefix+L` / `switch-client -l`): herdr 0.7.5 has no MRU action and its API exposes only current focus. A polling-watcher script worked but was removed as too much machinery — left unresolved until herdr ships a native action (see compromises.md).
5. Full mapping rationale, gaps, and unverified items logged in `herdr/.config/herdr/compromises.md`.

**Result:** herdr usable with tmux muscle memory; `.tmux.conf` unchanged and tmux fully functional — the two coexist, nvim picks the right multiplexer per session.

**Maintenance notes:**
- Config edits apply live via `herdr config check && herdr server reload-config` (or `prefix+r` inside herdr).
- The nav plugin is a linked local clone — `git pull` in `~/things/myc/vim-herdr-navigation` to update it.

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

## 2026-06-10: Daily compinit audit (skip compaudit on most startups)

**Problem:** After the NVM fix, `compaudit` was the next biggest cost (~65ms, ~30% of remaining startup). It runs a security audit of every directory in `$fpath` on every shell start — overkill when the dirs haven't changed.

**Changes made:**
1. Replaced unconditional `compinit` with a daily-audit pattern: run full `compinit` (with audit) only if `~/.zcompdump` is older than 24 hours; otherwise use `compinit -C` (skips audit, trusts cached dump).
2. Wrapped the conditional in an anonymous function with `emulate -L zsh -o extendedglob` because the `(#q...)` glob qualifier needs `EXTENDED_GLOB`, which isn't globally enabled. Initial attempt without this silently fell through and `-C` never fired.

**Result:** 0.24s → 0.18s (compinit 75ms → 7ms). Total project: 1.29s → 0.18s, ~7x faster than baseline.

**Caveat:** If you add a new completion script to `$fpath`, it may not be picked up until either (a) 24h passes, or (b) you `rm ~/.zcompdump` to force a rebuild.
