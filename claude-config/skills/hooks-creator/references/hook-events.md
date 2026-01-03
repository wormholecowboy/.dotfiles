# Hook Events Reference

Detailed input/output fields for each hook event.

## Common Input Fields (All Events)

```json
{
  "session_id": "unique-session-id",
  "transcript_path": "/path/to/conversation.json",
  "cwd": "/current/working/directory",
  "permission_mode": "default|plan|acceptEdits|bypassPermissions",
  "hook_event_name": "EventName"
}
```

## PreToolUse

Runs before tool call. Can block or modify.

### Input
```json
{
  "tool_name": "Bash|Write|Edit|Read|...",
  "tool_input": { /* tool-specific parameters */ },
  "tool_use_id": "unique-tool-use-id"
}
```

### Output (JSON to stdout)
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "Explanation",
    "updatedInput": { /* modified tool_input */ }
  }
}
```

### Exit Codes
- `0`: Allow tool execution
- `2`: Block tool, stderr shown to Claude

---

## PermissionRequest

Runs when permission dialog shown. Can auto-allow/deny.

### Input
Same as PreToolUse.

### Output
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow|deny",
      "updatedInput": { /* for allow */ },
      "message": "Why denied",
      "interrupt": false
    }
  }
}
```

---

## PostToolUse

Runs after tool succeeds. Cannot block (tool already ran).

### Input
```json
{
  "tool_name": "Bash|Write|Edit|...",
  "tool_input": { /* parameters used */ },
  "tool_response": { /* result from tool */ },
  "tool_use_id": "unique-tool-use-id"
}
```

### Output
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Feedback for Claude"
  }
}
```

---

## Notification

Runs when notification sent. Matcher values: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `""` (all).

### Input
```json
{
  "message": "Notification text",
  "notification_type": "permission_prompt|idle_prompt|..."
}
```

---

## UserPromptSubmit

Runs when user submits prompt. NO matcher support.

### Input
```json
{
  "prompt": "User's submitted text"
}
```

### Output
```json
{
  "decision": "block",
  "reason": "Why blocked (shown to user)"
}
```

Or for context injection, just print text to stdout (added to conversation).

### Exit Codes
- `0`: Allow, stdout added as context
- `2`: Block prompt, stderr shown to user

---

## Stop

Runs when Claude finishes. Can prevent stopping. NO matcher support.

### Input
```json
{
  "stop_hook_active": false
}
```

**Important**: If `stop_hook_active` is `true`, Claude is already continuing due to a previous stop hook. Allow stopping to prevent infinite loops.

### Output
```json
{
  "decision": "block",
  "reason": "Why Claude must continue"
}
```

---

## SubagentStop

Runs when subagent (Task tool) finishes. Same as Stop but for subagents.

---

## PreCompact

Runs before compaction. Matcher values: `manual`, `auto`.

### Input
```json
{
  "trigger": "manual|auto",
  "custom_instructions": "Only for manual"
}
```

---

## SessionStart

Runs when session begins. Matcher values: `startup`, `resume`, `clear`, `compact`.

### Input
```json
{
  "source": "startup|resume|clear|compact"
}
```

### Special: Environment Persistence
Use `$CLAUDE_ENV_FILE` to persist environment variables:
```bash
echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
```

### Output
stdout added as context for Claude.

---

## SessionEnd

Runs when session ends. NO matcher support.

### Input
```json
{
  "reason": "clear|logout|prompt_input_exit|other"
}
```

---

## Prompt-Based Hooks

For Stop, SubagentStop, UserPromptSubmit, PreToolUse, PermissionRequest, use `type: "prompt"` for LLM evaluation:

```json
{
  "type": "prompt",
  "prompt": "Evaluate if Claude should stop. Context: $ARGUMENTS",
  "timeout": 30
}
```

`$ARGUMENTS` is replaced with hook input JSON.
