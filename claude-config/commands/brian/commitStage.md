---
description: Create a git commit for only staged files, leaving working tree uncommitted
---

Create a new commit for ONLY changed files in staging (working tree MUST stay uncommited)
run git status && git diff HEAD && git status --porcelain to see what files are uncommitted

Add an atomic commit message with an appropriate message

add a tag such as "feat", "fix", "docs", etc. that reflects our work
