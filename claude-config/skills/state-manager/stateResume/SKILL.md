---
name: stateResume
description: Resume from an existing state file. Use when returning to continue previous work. Without arguments, resumes most recent state file. Pass a timestamp to resume a specific file. Injects state content into conversation context.
---

# State Resume

Resume a conversation from an existing state file.

## Arguments

- No argument: Resume most recent state file
- `$ARGUMENTS` = timestamp: Resume specific `.state/{timestamp}.state.md`

## Workflow

1. Get repo root: `git rev-parse --show-toplevel`
2. Find state file:
   - If no argument: `ls -1 .state/*.state.md | sort -rn | head -1`
   - If timestamp provided: `.state/{timestamp}.state.md`
3. If file not found, error and suggest `/stateList`
4. Read the state file contents
5. Update frontmatter:
   - Set `status: active`
   - Update `updated` timestamp
6. Output header + full contents:
   ```
   Resuming from state file: .state/{timestamp}.state.md
   ---
   [file contents]
   ```
7. Remember filename for `/stateUpdate` calls

## Error Handling

If no state files exist:
```
No state files found in .state/
Use /stateCreate to start a new session.
```

If specified timestamp not found:
```
State file not found: .state/{timestamp}.state.md
Use /stateList to see available state files.
```
