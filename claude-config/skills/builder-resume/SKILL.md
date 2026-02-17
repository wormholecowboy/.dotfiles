---
name: builder-resume
description: Resume the current plan and load context for a fresh session. Use at the start of a new session to continue work on a plan.
---

# Resume Plan Skill

Loads full context for the current plan, designed for starting a fresh session. Reads the plan set by `/builder-set` and displays everything needed to continue work.

## Usage

```
/builder-resume
```

Or with explicit plan name:
```
/builder-resume <plan-name>
```

## Activation

When invoked via `/builder-resume [plan-name]`:

1. **Determine plan to resume**
   - If plan-name argument provided, use that
   - Otherwise, read `.claude/skills/builder/.current-plan`
   - If no current plan set, show error and suggest `/builder-set`

2. **Validate plan exists**
   - Check for directory at `.claude/plans/[plan-name]/`
   - Check for `state.yaml` in that directory

3. **Load and display context**

   Read and summarize:
   - `state.yaml` - Current stage, task statuses, decisions
   - `main.md` - PRD summary (just the Overview/Goals sections)
   - `impl/*.md` - List implementation plans available
   - `reviews/*.md` - List any reviews (note escalated items)

4. **Show task status**
   ```
   ## Task Status

   Phase 1: [status]
     [x] phase1-task1 - [description] (commit: abc123)
     [x] phase1-task2 - [description] (commit: def456)
     [ ] phase1-task3 - [description] <- NEXT

   Phase 2: pending
     [ ] phase2-task1 - [description] (blocked by: phase1-task3)
   ```

5. **Highlight important items**
   - Any tasks with `escalated: true` (need human decision)
   - Any blocked tasks and what's blocking them
   - Any failed validations

6. **Show next action**
   ```
   ## Next Action

   Ready to build: phase1-task3
   Run `*build phase1-task3` or `*build-next` to continue.
   ```

   Or if blocked:
   ```
   ## Next Action

   BLOCKED: All remaining tasks depend on [task-id] which has escalated issues.
   Review: reviews/task-[task-id]-review.md
   ```

7. **Activate builder mode**
   - After displaying context, activate builder mode
   - Ready to accept builder commands (`*build`, `*status`, etc.)

## Output Format

```
# Resuming: [plan-name]

## Overview
[Brief description from PRD]

## Current Stage: [stage]

## Task Status
[Task breakdown with status indicators]

## Escalated Items (if any)
[List of items needing human decision]

## Next Action
[What to do next]

---
Planning mode active. Ready for commands.
```

## Plans Directory

Plans are located at: `.claude/plans/`

## Current Plan File

Read from: `.claude/skills/builder/.current-plan`

## Example

```
/builder-resume
```

Output:
```
# Resuming: voice-agent-v2

## Overview
Build a voice agent using LiveKit for real-time audio processing.

## Current Stage: building

## Task Status

Phase 1: complete
  [x] phase1-task1 - Set up LiveKit client (commit: abc123)
  [x] phase1-task2 - Implement audio capture (commit: def456)
  [x] phase1-task3 - Add WebSocket connection (commit: ghi789)

Phase 2: in_progress
  [~] phase2-task1 - Implement voice activity detection (escalated)
  [ ] phase2-task2 - Add real-time transcription (blocked by: phase2-task1)
  [ ] phase2-task3 - Build response playback (blocked by: phase2-task2)

## Escalated Items

- phase2-task1: Security review found potential DoS vector in audio buffer handling
  See: reviews/task-phase2-task1-security.md

## Next Action

BLOCKED: phase2-task1 has escalated security issues requiring human decision.
Review the security findings and decide on approach before continuing.

---
Planning mode active. Ready for commands.
```
