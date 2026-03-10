---
description: Resume work from the most recent session state file
---

User's additional context: $ARGUMENTS

# Resume Session from State File

You are resuming work from a previous Claude Code session. Your task is to load the most recent session state and prepare to continue where things left off.

## Step 1: Find the State File

Look in the current git repository root (use `git rev-parse --show-toplevel`) for files matching the pattern `.state/.state-[timestamp]-[brief-description].md`

Select the most recent one based on the timestamp in the filename (format: YYYY-MM-DD-HH:MM).

If no state files exist, inform the user and stop.

## Step 2: Read and Present the Summary

Read the entire session state file and present it to the user with:

1. **Session Overview** - When it was created, what branch, brief status
2. **Where We Left Off** - Current task status and any work in progress
3. **Open Items** - Questions, blockers, or decisions pending
4. **Recommended First Action** - What should be done first based on the "Next Steps" section

## Step 3: Load Essential Context

From the "Files to Read in Next Session" section:
- Read all files listed under "Must Read"
- Note the "Should Read" files for reference
- Be aware of "Reference Only" files

## Step 4: Ready to Continue

After loading context, ask the user:
> "I've loaded the session from [filename]. Ready to continue with [next step from summary]. Shall I proceed, or would you like to focus on something else?"

## Handling Multiple State Files

If multiple state files exist:
- Default to the most recent
- If $ARGUMENTS contains "list", show all available state files and let user choose
- If $ARGUMENTS contains a partial filename, timestamp, or description keyword, match that specific session

## Example Usage

- `/state-resume` - Load the most recent state
- `/state-resume list` - Show all available state files
- `/state-resume 2025-01-28` - Load state from specific date
- `/state-resume auth` - Load state matching "auth" in description
