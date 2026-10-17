---
name: dot
description: Update my dotfiles in ~/.dotfiles (zsh, tmux, nvim, ghostty, herdr, lazygit, claude config, etc.)
argument-hint: "<what to update>"
disable-model-invocation: true
---

Update my dotfiles in `~/.dotfiles/`. Extra context below says what to change.

## 1. Orient
- Work in `~/.dotfiles/` regardless of the current cwd. Read `~/.dotfiles/CLAUDE.md` first.
- Stow-style layout: each top-level dir (`zsh/`, `tmux/`, `nvim/`, `ghostty/`, `herdr/`, `lazygit/`, `claude/`, ...) mirrors `~/` and is symlinked there. Edit the file inside `~/.dotfiles/`, never the symlink target's copy elsewhere.
- Some dirs have their own notes (e.g. nvim `agent/decisions.md`, `herdr/.config/herdr/compromises.md`). Check for them in the dir you're touching.
- If the context is ambiguous about which tool/file, ask.

## 2. Change
- Find the existing config and match its style. Prefer `Edit` over `Write`.
- Keep it scoped to what was asked.
- New config file → put it in the right top-level dir so the symlink lands in the right place. Tell me if it needs a new symlink/stow step.

## 3. Verify
Use the tool's own check where one exists:
- zsh: `zsh -n <file>`, then `time zsh -i -c exit` for startup-sensitive changes
- tmux: `tmux source-file ~/.tmux.conf` (only if a server is running)
- nvim: `nvim --headless "+qa"` and check for errors
- herdr: `herdr config check && herdr server reload-config`
- json (claude settings, etc.): `jq . <file>`

## 4. Record
- Significant change (new tool, behavior change, workaround) → add a dated entry to `~/.dotfiles/decisions.md` (top of file, same format as existing entries). Skip for small tweaks.
- Don't commit. Tell me what changed (`file:line`), how you verified it, and any reload/restart I need to do.

extra context from user = $ARGUMENTS
