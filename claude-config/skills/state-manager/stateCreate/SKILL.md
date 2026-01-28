---
name: stateCreate
description: Create a new conversation state file for the current session. Use when starting a new working session that you want to persist across context resets. Creates .state/{timestamp}.state.md in repo root.
---

# State Create

Create a new state file to track conversation context.

## Workflow

1. Get repo root: `git rev-parse --show-toplevel`
2. Create `.state/` directory if missing
3. Add `.state/` to `.gitignore` if not present
4. Generate filename using Unix timestamp: `$(date +%s).state.md`
5. Create state file with template below
6. Confirm creation to user

## State File Template

```markdown
---
created: {ISO_TIMESTAMP}
updated: {ISO_TIMESTAMP}
session_id: {SESSION_ID}
status: active
topic: ""
---

## Context
[Session context - update as conversation progresses]

## Decisions Made
- [None yet]

## Open Questions
- [ ] [None yet]

## Key Learnings
- [None yet]

## Next Steps
- [ ] [None yet]
```

## Notes

- State files use Unix timestamps for easy sorting
- Status values: `active`, `paused`, `completed`
- After creation, remember the filename for `/stateUpdate` calls
