---
name: hooks-creator
description: Guide for creating Claude Code hooks - user-defined shell commands that execute at lifecycle points. Use when the user wants to create, add, or configure a hook for Claude Code, including PreToolUse, PostToolUse, Notification, UserPromptSubmit, Stop, SubagentStop, PreCompact, SessionStart, or SessionEnd hooks.
---

# Hooks Creator

Create Claude Code hooks - shell commands that execute automatically at specific lifecycle points.

## Quick Reference: Hook Events

| Event | When it Runs | Can Block | Matcher | Common Use |
|-------|--------------|-----------|---------|------------|
| PreToolUse | Before tool call | Yes | Yes | Validate/block commands, modify inputs |
| PermissionRequest | Permission dialog | Yes | Yes | Auto-allow/deny permissions |
| PostToolUse | After tool succeeds | No | Yes | Format code, log, provide feedback |
| Notification | Notification sent | No | Yes | Custom alerts (permission_prompt, idle_prompt) |
| UserPromptSubmit | User submits prompt | Yes | No | Validate prompts, inject context |
| Stop | Claude finishes | Yes | No | Evaluate completion, force continue |
| SubagentStop | Subagent finishes | Yes | No | Evaluate subagent completion |
| PreCompact | Before compaction | No | Yes | Pre-compact cleanup (manual, auto) |
| SessionStart | Session begins | No | Yes | Setup env, load context (startup, resume, clear, compact) |
| SessionEnd | Session ends | No | No | Cleanup, logging |

## Workflow

### Step 1: Determine Hook Requirements

Ask the user:
1. **What should trigger the hook?** (which event from table above)
2. **What should the hook do?** (the action to take)
3. **Should it block/modify behavior?** (for events that support blocking)

### Step 2: Determine Installation Scope

Ask where to install the hook:

| Scope | Path | Use Case |
|-------|------|----------|
| Project (shared) | `.claude/settings.json` | Team-shared hooks, committed to git |
| Project (local) | `.claude/settings.local.json` | Personal project hooks, not committed |
| User global | `~/.claude/settings.json` | Personal hooks for all projects |
| User profile | `~/.claude-<profile>/settings.json` | Profile-specific hooks |

For user-level hooks, ask which profile or if using default `~/.claude/`.

### Step 3: Create the Hook

#### Configuration Format

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",
        "hooks": [
          {
            "type": "command",
            "command": "path/to/script.py",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

#### Matcher Patterns

- **Exact match**: `"Write"` - matches only Write tool
- **Wildcard**: `"*"` or `""` - matches all tools
- **Regex**: `"Edit|Write"` - matches Edit OR Write
- **MCP tools**: `"mcp__server__tool"` pattern

Events WITHOUT matcher support: UserPromptSubmit, Stop, SubagentStop, SessionEnd

#### Hook Script Template

Create a Python script that:
1. Reads JSON from stdin
2. Processes the input
3. Outputs JSON for control (optional)
4. Exits with appropriate code

```python
#!/usr/bin/env python3
import json
import sys

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

# Process input_data based on hook event
# Common fields: session_id, transcript_path, cwd, permission_mode, hook_event_name

# Exit codes:
#   0 = Success (allow)
#   2 = Block (stderr used as error message)
#   other = Non-blocking error

sys.exit(0)
```

### Step 4: Hook Input/Output Reference

See `references/hook-events.md` for detailed input/output fields per event.

See `references/examples.md` for complete working examples.

## Environment Variables

| Variable | Available In | Description |
|----------|--------------|-------------|
| `CLAUDE_PROJECT_DIR` | All hooks | Project root directory |
| `CLAUDE_CODE_REMOTE` | All hooks | "true" if remote, empty if local |
| `CLAUDE_ENV_FILE` | SessionStart only | File to persist env vars |

## Security Considerations

- Hooks run with your user credentials
- Always validate and sanitize inputs
- Quote shell variables: `"$CLAUDE_PROJECT_DIR"`
- Block path traversal: reject paths with `..`
- Set reasonable timeouts (default 60s)
- Never access `.env`, credentials, private keys
