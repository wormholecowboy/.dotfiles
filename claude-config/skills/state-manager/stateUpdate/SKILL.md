---
name: stateUpdate
description: Update the current state file with new learnings, decisions, and context from the conversation. Use periodically during long sessions to capture important information before context resets.
---

# State Update

Update the active state file with conversation progress.

## Prerequisites

Must have an active state file from either:
- `/stateCreate` in current session
- `/stateResume` earlier in session
- SessionStart hook auto-creation

If no active state file, prompt user to use `/stateCreate` or `/stateResume` first.

## Workflow

1. Find active state file (most recent in `.state/` if not tracked)
2. Read current contents
3. Analyze conversation since last update
4. Update relevant sections (see guidelines below)
5. Update `updated` timestamp in frontmatter
6. Write changes back to file
7. Confirm: "State file updated: .state/{timestamp}.state.md"

## Update Guidelines

**Context**: Keep concise (2-3 sentences). Update only if session focus has shifted significantly.

**Decisions Made**: Add decisions with brief rationale.
```markdown
- Chose X over Y because Z
- Decided to use {approach} for {reason}
```

**Open Questions**: Use checkboxes.
- Check off `[x]` resolved questions
- Add new `[ ]` unresolved questions
- Remove irrelevant questions

**Key Learnings**: Non-obvious insights discovered.
```markdown
- Learned that X works by Y
- Discovered {codebase pattern}
```

**Next Steps**: Actionable items.
- Check off `[x]` completed items
- Add new `[ ]` pending items
- Reorder by priority

## Output Format

After updating, show a brief summary:
```
Updated .state/{timestamp}.state.md:
- Added 2 decisions
- Resolved 1 question, added 2 new
- Added 1 learning
- Updated next steps
```
