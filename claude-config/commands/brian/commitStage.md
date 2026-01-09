---
description: Create a git commit for only staged files, leaving working tree uncommitted
---

Use the **git-ops** subagent (via Task tool) to commit only staged files.

Instructions for the subagent:
- Run `git status && git diff --staged && git status --porcelain` to see staged vs unstaged files
- Commit ONLY the staged files (do NOT add unstaged files)
- Working tree changes MUST stay uncommitted
- Use conventional commit format (feat, fix, docs, etc.)
- Create an atomic commit with appropriate message
