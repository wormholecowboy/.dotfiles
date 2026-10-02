## learnings
- [claude-hooks] UserPromptSubmit + SessionStart: plain stdout (exit 0) → added to Claude context. SessionStart matchers: startup|resume|clear|compact|fork (docs, 2026-10-02)
- [claude-hooks] Stop hook block = top-level `{"decision":"block","reason":"…"}`; `stop_hook_active` not listed in hooks reference
- [claude-hooks] PostToolUse Bash `tool_response` shape undocumented — capture real payload before parsing
- [claude-hooks] `claude -p --resume <id>` on a session open elsewhere interleaves into one transcript; open TUI never sees it → can't push into a live session. Channels can (research preview: `notifications/claude/channel`, `--dangerously-load-development-channels server:<name>`; Team/Enterprise orgs need `channelsEnabled`)
## gotchas
- [nvim] always update `lua/wormholecowboy/core/keymaps.lua` when adding/editing keybindings anywhere in the config
- [claude-hooks] hook exit code 2 = blocking error, and Go panics exit 2 → Go hook handlers must recover and exit 0
- [claude-hooks] dotfiles hooks calling tools built in ~/things/myc must guard on the binary (`[ -x … ] && … || true`); ~/things/myc isn't synced by dotfiles, missing binary = hook error every tool call
## arch
- [ernie] source in ~/things/myc/ernie; dotfiles holds only Claude-side pieces (hooks in claude/.claude/settings.json, ernie skill, mem/gtg/handoff edits, install.txt entry). Plan docs move to ~/things/myc/ernie/docs/ at build task 1.1
## reference
- [ernie] live context UI plan → /Users/brian.gildea/.dotfiles/plans/live-context-ui/plan.md (spec) + impl.md (build plan) (+ mock.html, proposal.html); repoint after the docs move
