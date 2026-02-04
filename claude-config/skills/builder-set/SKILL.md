---
name: builder-set
description: Set the current plan being worked on. Use when switching between plans or starting work on a specific plan.
---

# Set Plan Skill

Sets the active plan for the current working session. This allows `/builder-resume` to quickly load context without specifying the plan name.

## Usage

```
/builder-set <plan-name>
```

## Activation

When invoked via `/builder-set [plan-name]`:

1. **Parse argument** - Get the plan name from the command arguments
   - If no argument provided, infer from context:
     - Check recent conversation for plan files being read/modified
     - Look for paths matching `.claude/plans/[name]/`
     - Extract the plan name from those paths
   - If cannot infer, list available plans and ask

2. **Validate plan exists**
   - Check for directory at `.claude/plans/[plan-name]/`
   - Check for `state.yaml` in that directory
   - If not found, show error and list available plans

3. **Write current plan file**
   - Write the plan name to `.claude/skills/builder/.current-plan`
   - This is a simple text file containing just the plan name

4. **Show confirmation with brief status**
   - Read `state.yaml` from the plan
   - Display:
     ```
     Current plan set: [plan-name]

     Status: [current_stage]
     Tasks: [X complete] / [Y total]
     Next eligible: [task-id] (or "none" if blocked/complete)

     Use /builder-resume to load full context.
     ```

## Plans Directory

Plans are located at: `.claude/plans/`

Archived plans are in: `.claude/plans/archive/`

## Current Plan File

The current plan is stored in: `.claude/skills/builder/.current-plan`

This file contains just the plan name (not the full path), e.g.:
```
my-feature
```

## Examples

### With explicit plan name
```
/builder-set voice-agent-v2
```

Output:
```
Current plan set: voice-agent-v2

Status: building
Tasks: 3 complete / 8 total
Next eligible: phase2-task1

Use /builder-resume to load full context.
```

### Inferring from context
After working on files in `plans/auth-refactor/`:
```
/builder-set
```

Output:
```
Detected plan from context: auth-refactor

Current plan set: auth-refactor

Status: impl-planning
Tasks: 0 complete / 5 total
Next eligible: phase1-task1

Use /builder-resume to load full context.
```
