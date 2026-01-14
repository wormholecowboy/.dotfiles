To validate assumptions or questions, create a minimal test case and run that code.
extra optional user context = $ARGUMENTS

## CRITICAL: Worktree/Branch Constraints

**PROJECT_ROOT**: Use `git rev-parse --show-toplevel` to get the project root. This works for both:
- Regular git repos (returns repo root)
- Git worktrees (returns worktree root, NOT the bare repo)

**BEFORE ANY SEARCH OR ANALYSIS:**

1. Run: `PROJECT_ROOT=$(git rev-parse --show-toplevel)`
2. ALL file searches (Glob, Grep) MUST use `path: "$PROJECT_ROOT"` parameter
3. ALL subagent prompts MUST include: `"Stay within directory: $PROJECT_ROOT. Do NOT traverse to parent directories or other worktrees."`
4. NEVER use `git rev-parse --git-common-dir` or follow `.git` file references
5. When spawning Explore agents, explicitly pass: `"Search only within: {PROJECT_ROOT}"`

**Verification**: If you see paths containing `.bare/` or `worktrees/` in search results, STOP - you've escaped the worktree boundary.

