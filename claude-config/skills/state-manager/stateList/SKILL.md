---
name: stateList
description: List all state files in the current repository. Shows timestamp, human-readable date, topic, and status for each file. Use to find a specific state file to resume.
---

# State List

List all state files in the current repository.

## Workflow

1. Get repo root: `git rev-parse --show-toplevel`
2. Check if `.state/` directory exists
3. List all `.state/*.state.md` files
4. For each file, extract:
   - Timestamp (from filename)
   - Human-readable date (convert timestamp)
   - Topic (from frontmatter)
   - Status (from frontmatter)
5. Display as formatted table

## Output Format

```
State files in .state/:

| Timestamp  | Date                | Topic              | Status    |
|------------|---------------------|--------------------|-----------|
| 1737999600 | 2026-01-27 14:30:00 | API refactoring    | active    |
| 1737985200 | 2026-01-27 10:30:00 | Bug fix session    | completed |
| 1737912000 | 2026-01-26 14:00:00 | Initial setup      | paused    |

To resume: /stateResume [timestamp]
```

## Empty State

If no state files exist:
```
No state files found in .state/
Use /stateCreate to start a new session.
```

## Parsing Frontmatter

Extract topic and status from YAML frontmatter:
```yaml
---
topic: "API refactoring"
status: active
---
```

If topic is empty, show "(no topic)".
