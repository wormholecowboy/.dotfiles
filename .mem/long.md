## learnings
- [claude-hooks] UserPromptSubmit + SessionStart: plain stdout (exit 0) → added to Claude context. SessionStart matchers: startup|resume|clear|compact|fork (docs, 2026-10-02)
- [claude-hooks] Stop hook block = top-level `{"decision":"block","reason":"…"}`; `stop_hook_active` not listed in hooks reference
- [claude-hooks] PostToolUse Bash `tool_response` shape undocumented — capture real payload before parsing
- [claude-hooks] `claude -p --resume <id>` on a session open elsewhere interleaves into one transcript; open TUI never sees it → can't push into a live session. Channels can (research preview: `notifications/claude/channel`, `--dangerously-load-development-channels server:<name>`; Team/Enterprise orgs need `channelsEnabled`)
- [claude] Claude Code Bash tool replays zsh config via shell snapshot; $CLAUDECODE=1 set — guard aliases/options on it (f20e1ff)
- [aws] Claude uses AWS_PROFILE=saml + AWS_REGION=us-west-2 (settings env); saml2aws writes [saml] profile; profile has no region in ~/.aws/config (659f489)
- [settings] `syncClaudeAiSkills: false` in user settings stops the claude.ai skill sync; the next launch moves synced skills to ~/.claude/skills/.trash/. A folder deleted by hand comes back on the next sync (docs, 77a2fe3).
- [claude] Skill frontmatter honors `effort:` (Claude Code 2.1.311 loader); a misspelled key is ignored silently.
## gotchas
- [nvim] always update `lua/wormholecowboy/core/keymaps.lua` when adding/editing keybindings anywhere in the config
- [claude-hooks] hook exit code 2 = blocking error, and Go panics exit 2 → Go hook handlers must recover and exit 0
- [claude-hooks] dotfiles hooks calling tools built in ~/things/myc must guard on the binary (`[ -x … ] && … || true`); ~/things/myc isn't synced by dotfiles, missing binary = hook error every tool call
- [herdr] herdr ctrl+hjkl plugin link points at lazy clone `~/.local/share/nvim/lazy/vim-herdr-navigation`; nvim no longer uses it → `:Lazy clean`/`:Lazy sync` deletes it and breaks herdr nav. Fine once herdr removed.
## arch
- [ernie] source + spec + memory in ~/things/myc/ernie (its own .mem/); dotfiles holds only Claude-side pieces (hooks in claude/.claude/settings.json, ernie skill, CLAUDE.md §4/§7 routing, install.txt entry)
- [claude] ~/.claude/{CLAUDE.md,agents,skills,commands,settings.json} are symlinks into ~/.dotfiles/claude/.claude/, so an edit there affects every project.
- [mem] The mem skill runs *um, *mr and *op in the main thread; there is no memory subagent (c974ee3).
## reference
- [claude] Claude Code improvement plan → .mem/artifacts/plan_claude-code-improvements.md
- [claude] Prompt audit open items (flags, plugin findings) → .mem/artifacts/ref_prompt-audit.md
- [ernie] spec + build plan → ~/things/myc/ernie/.mem/artifacts/ (spec_ernie.md, plan_ernie_build.md)
