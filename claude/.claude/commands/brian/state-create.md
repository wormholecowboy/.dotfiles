---
description: Summarize session context to a state file before context window fills up
---

User's additional context: $ARGUMENTS

# Create Session State File

You are about to create a session state file that will allow work to continue in a fresh Claude Code session. This is an alternative to auto-compact when approaching context limits.

## Output Location

Create the state file at: `[git-root]/.state/.state-[timestamp]-[brief-description].md`

Where:
- `[git-root]` is the root of the current git repository (use `git rev-parse --show-toplevel`)
- `[timestamp]` is current datetime as YYYY-MM-DD-HH:MM
- `[brief-description]` is a short, kebab-case description of the session's main focus (e.g., "auth-refactor", "api-bugfix", "new-dashboard")

## Analysis Instructions

Review the ENTIRE conversation history and intelligently determine what to include:

### EXCLUDE (completed/resolved items):
- Tasks that are fully completed with no follow-up needed
- Questions that were already answered and acted upon
- Debugging sessions where the issue was resolved
- Code that was written, tested, and confirmed working
- Decisions that were made and implemented

### INCLUDE (active/pending items):

**1. Open Questions & Decisions**
- Any unanswered questions from the user
- Pending decisions that need user input
- Clarifications still being sought

**2. Work In Progress**
- Current task being worked on (with status)
- Any partially completed work
- Code that was written but not yet tested/verified

**3. Essential Context**
- Key architectural decisions made this session
- Database schema changes or migrations discussed
- Environment/configuration details discovered
- Any constraints or requirements established

**4. Files for Continuation (CRITICAL)**
- ALL files that were read and are relevant to ongoing work
- Files that need to be modified next
- Config files, schema files, or type definitions needed for context
- Test files related to work in progress
- Documentation files that informed decisions
- Use FULL ABSOLUTE PATHS for all file references

**5. Known Issues & Blockers**
- Bugs discovered but not yet fixed
- Blockers preventing progress
- Errors that need investigation

**6. Next Steps**
- Explicitly stated next actions
- Implied follow-up work
- Items the user mentioned wanting to do

## State File Format

```markdown
# Claude Session State
Generated: [timestamp]
Repository: [repo-path]
Branch: [current branch name]
Session Focus: [brief-description]

## User's Additional Context
[Include $ARGUMENTS here if provided, otherwise state "None provided"]

## Current Task Status
[What was being worked on and its current state]

## Open Questions
[List any unanswered questions or pending decisions]

## Key Context
[Essential information needed to continue work]

## Known Issues
[Any problems discovered that need attention]

## Next Steps
[Clear action items for the next session]

## Files to Read in Next Session
[CRITICAL: List ALL files that the next session should read to continue work effectively.
Include full absolute paths. Categorize as:]

### Must Read (essential for continuing)
- [files that MUST be read to understand the current state]

### Should Read (important context)
- [files that provide important background]

### Reference Only (consult if needed)
- [files mentioned but not immediately critical]

## Files Modified This Session
[List of files that were created or changed, with full paths]

## Important Code References
[Key file:line references that will be needed - use format: /full/path/to/file.py:123]
```

## Execution

1. Analyze the full conversation
2. Apply the include/exclude logic above
3. Generate the state file at the git worktree root
4. Report the file path to the user
5. Suggest they can resume with: `/state-resume` or `/state-resume [description-keyword]`

Be ruthless about excluding completed work - the goal is a minimal, actionable summary that lets work continue efficiently.
