---
description: Create a git commit for all uncommitted changes with conventional commit message
---

Use the **git-ops** subagent (via Task tool) to commit all uncommitted changes.

Instructions for the subagent:
- Run `git status && git diff HEAD && git status --porcelain` to see all uncommitted files
- Add all untracked and changed files
- Use conventional commit format (feat, fix, docs, etc.)
- Create multiple commits if necessary for logically separate changes 
