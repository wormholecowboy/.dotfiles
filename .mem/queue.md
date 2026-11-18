---
updated: 2026-11-18
---
## next
- [claude] Claude Code fixes backlog (#2,#4–#10 + runners-up) → .mem/artifacts/plan_claude-code-improvements.md
- [mem] .mem writes lossy: add a Stop-hook auto-commit and make dailies append-only (plan #2; git-track and main-thread writes are done)
- [ernie] Create the new ernie skill, then update the ernie routing in ~/.claude/CLAUDE.md §4 and §7. The mem skill no longer steps aside where ernie is on.
- [claude] Act on the plugin findings (superpowers 1% rule, sdd spec workflow, code-simplifier, two Snyk MCPs) → .mem/artifacts/ref_prompt-audit.md
- [athena] Athena deny rules inert; build permanent ~/things/scripts/athq w/ read-only guard (plan #4)
- [aws] ask admin to raise HLV_Developer_Admin MaxSessionDuration (now 3600)
- [herdr] delete herdr binary `~/.local/bin/herdr` later (user reverted to tmux 2026-11-15; herdr kept for now)
  also remove: herdr/ dir, zsh/scripts/herdr-workspace-status.sh, claude/.claude/hooks/herdr-agent-state.sh + SessionStart entry in claude/.claude/settings.json, herdr in claude/.claude/skills/dot/SKILL.md, ~/.config/herdr/
