# herdr ↔ tmux parity — learnings and compromises

Config ported from `tmux/.tmux.conf` (herdr 0.7.5). Concepts map as:
tmux session → herdr workspace, tmux window → herdr tab, tmux pane → pane.

## Learnings

- **`copy_mode` exists but is undocumented in the shipped template.** It's a real
  `[keys]` action in 0.7.5 (validator accepts it; fake keys are rejected). Bound to
  `prefix+[`. Unverified: whether movement inside copy mode is vi-style.
- **Punctuation bindings work beyond the documented list.** The template only names
  minus/comma/ampersand/plus/backtick, but `prefix+"`, `prefix+%`, and `prefix+[`
  all pass validation. Use TOML literal strings (`'prefix+"'`) for quotes.
- **`herdr config check` genuinely validates** — unknown keys and bad key syntax
  both fail with diagnostics. Trust `config: ok`.
- **The socket CLI covers scripting needs**: `herdr workspace list` (JSON, parse
  with jq), `focus <id>`, `close <id>`, plus `tab`/`pane`/`session` subcommands.
  This is what powers the fzf popups.
- **`herdr server reload-config`** applies changes live — no restart, same as
  `prefix+r` (rebound reload_config).
- Several tmux settings were already herdr defaults: new tab in current dir with
  name prompt (`prefix+c`), `prefix+p`/`n` tab nav, `prefix+h/j/k/l` pane focus,
  `prefix+x` kill pane, `prefix+z` zoom, `prefix+1..9`, mouse on.

## Compromises

| tmux | herdr resolution |
|---|---|
| `bind o` fzf session switch popup | Native `goto` fuzzy palette on `prefix+o` (fzf clone removed as redundant) |
| `bind K` fzf multi-kill | Kept as custom fzf popup on `prefix+shift+k` — native `close_workspace` (`prefix+shift+d`) is current-workspace-only, no picker |
| `bind s` choose-tree | `workspace_picker` on `prefix+s`; herdr settings screen moved to `prefix+shift+s` |
| `bind D` jump to `0__dotfiles` | Not bound. Possible via shell command: `workspace list \| jq 'select(.label=="...")' \| focus` |
| `prefix+L` last session (`switch-client -l`) | **Unresolved.** herdr 0.7.5 has no last-workspace/MRU action (probed `last_workspace`, `last_tab`, etc. — all rejected) and `api snapshot` exposes only current focus, no history. A polling-watcher script was built and worked but was removed as too much machinery — revisit if herdr ships a native MRU action. Note: herdr *does* have a native `last_pane` action (pane-level toggle, currently unbound) |
| kill-session/pane without prompt | `confirm_close = false` — `prefix+shift+d` kills instantly now |
| `bind r` reload | `reload_config` on `prefix+r`; resize mode moved to `prefix+shift+r` |
| `bind g`/`G` lazygit popups | Custom popup commands, 90%×90%. Assumes popups inherit pane cwd via `new_cwd = "follow"` — verify |
| `bind P` nvim split | Custom pane command on `prefix+shift+p`; no way to force horizontal direction. `rename_pane` and `new_worktree` unbound to free keys |
| vi copy-mode `v`/`y`, MouseDragEnd unbind | No config for in-copy-mode keys. `copy_on_select = true` (drag auto-copies — differs from tmux); `prefix+e` opens scrollback in nvim as the vi fallback |
| vim-tmux-navigator (`C-h/j/k/l`) | [vim-herdr-navigation](https://github.com/paulbkim-dev/vim-herdr-navigation) plugin, cloned to `~/things/myc/vim-herdr-navigation` and linked via `herdr plugin link`. Herdr side: `plugin_action` bindings on bare ctrl+h/j/k/l (process detection → `send-keys` into vim, else `pane focus`). Nvim side: `after/plugin/herdr-nav.lua` dofiles the repo's `editor/nvim.lua`, which crosses split edges into herdr panes via `$HERDR_PANE_ID` and falls back to TmuxNavigate under $TMUX (tmux-navigator spec keeps only `<C-\>`, `tmux_navigator_no_mappings = 1`). Fully bidirectional, works in both multiplexers |
| `<`/`>` swap-window | No tab-reorder action found in 0.7.5 |
| nova theme, status top | `theme = "dracula"` + accent `#50fa7b`; no status-bar position (sidebar instead). Pane border test colors dropped — no per-border theme tokens |
| resurrect/continuum | `resume_agents_on_restore = true` + experimental `pane_history = true` |
| `history-limit 5000` (lines) | `scrollback_limit_bytes` default 10MB kept (bytes, not lines; more generous) |
| `base-index 1`, renumber | No option; herdr numbering appears 1-based natively |
| escape-time, focus-events, extended-keys/csi-u | No config equivalents; presumably handled internally — watch nvim autoread and csi-u apps for regressions |

## Still to verify by hand

1. Copy mode keys (`prefix+[`) — vi-like or not?
2. `prefix+"` registers as a shifted-punctuation prefix key.
3. Lazygit popup opens in the focused pane's repo.
4. fzf popups (`prefix+o` was replaced by native goto; `prefix+shift+k` remains).
5. `goto` vs `workspace_picker` — if goto covers everything, `prefix+s` could return to settings.
