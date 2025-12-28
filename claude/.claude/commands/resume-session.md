---
description: Resume work from the most recent session summary file
---

User's additional context: $ARGUMENTS

# Resume Session from Summary

You are resuming work from a previous Claude Code session. Your task is to load the most recent session summary and prepare to continue where things left off.

## Step 1: Find the Most Recent Session File

Look in `[git-repo-root]/tmp/session-summaries/` for files matching the pattern `claude-session-[initials]-[timestamp]-[branch].md`

Select the most recent one based on the timestamp in the filename (format: YYYYMMDD-HHMMSS).

If no session files exist, inform the user and stop.

## Step 2: Read and Present the Summary

Read the entire session summary file and present it to the user with:

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

## Handling Multiple Sessions

If multiple session files exist for the same branch:
- Default to the most recent
- If $ARGUMENTS contains "list", show all available sessions and let user choose
- If $ARGUMENTS contains a partial filename, timestamp, or initials, match that specific session

## Example Usage

- `/resume-session` - Load the most recent session
- `/resume-session list` - Show all available sessions
- `/resume-session 20250128` - Load session from specific date
- `/resume-session BG` - Load most recent session by developer initials
