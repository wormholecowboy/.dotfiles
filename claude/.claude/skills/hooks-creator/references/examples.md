# Hook Examples

Complete working examples for common use cases.

## 1. Auto-Format Code (PostToolUse)

Format TypeScript/Python files after Write/Edit.

**Configuration** (settings.json):
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/format_code.py"
          }
        ]
      }
    ]
  }
}
```

**Script** (.claude/hooks/format_code.py):
```python
#!/usr/bin/env python3
import json
import sys
import subprocess

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

file_path = input_data.get('tool_input', {}).get('file_path', '')
if not file_path:
    sys.exit(0)

if file_path.endswith(('.ts', '.tsx', '.js', '.jsx')):
    subprocess.run(['npx', 'prettier', '--write', file_path], capture_output=True)
elif file_path.endswith('.py'):
    subprocess.run(['black', file_path], capture_output=True)

sys.exit(0)
```

---

## 2. Block Sensitive Files (PreToolUse)

Prevent modifications to .env, credentials, etc.

**Configuration**:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/file_protection.py"
          }
        ]
      }
    ]
  }
}
```

**Script** (~/.claude/hooks/file_protection.py):
```python
#!/usr/bin/env python3
import json
import sys

PROTECTED = ['.env', 'credentials', 'private_key', 'secrets/', '.git/']

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

file_path = input_data.get('tool_input', {}).get('file_path', '')

for pattern in PROTECTED:
    if pattern in file_path:
        print(f"Cannot modify protected file: {pattern}", file=sys.stderr)
        sys.exit(2)  # Block

sys.exit(0)
```

---

## 3. Custom Notifications (Notification)

Desktop alert when Claude needs permission.

**macOS**:
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude needs permission\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

**Linux**:
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "notify-send -u critical 'Claude Code' 'Permission required'"
          }
        ]
      }
    ]
  }
}
```

---

## 4. Validate Bash Commands (PreToolUse)

Suggest better alternatives for common commands.

**Configuration**:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/bash_validator.py"
          }
        ]
      }
    ]
  }
}
```

**Script**:
```python
#!/usr/bin/env python3
import json
import re
import sys

RULES = [
    (r"\bgrep\b(?!.*\|)", "Use 'rg' (ripgrep) instead of 'grep'"),
    (r"\bfind\s+\S+\s+-name\b", "Use 'fd' or 'rg --files' instead of 'find -name'"),
]

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

command = input_data.get('tool_input', {}).get('command', '')

for pattern, message in RULES:
    if re.search(pattern, command):
        print(f"Suggestion: {message}", file=sys.stderr)
        sys.exit(2)

sys.exit(0)
```

---

## 5. Inject Context on Prompt (UserPromptSubmit)

Add current date/time to every prompt.

**Configuration**:
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/inject_context.py"
          }
        ]
      }
    ]
  }
}
```

**Script**:
```python
#!/usr/bin/env python3
import json
import sys
from datetime import datetime

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

# Print context to stdout - added to conversation
print(f"Current time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
sys.exit(0)
```

---

## 6. Session Environment Setup (SessionStart)

Load virtual environment and set variables.

**Configuration**:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/setup_env.sh"
          }
        ]
      }
    ]
  }
}
```

**Script** (~/.claude/hooks/setup_env.sh):
```bash
#!/bin/bash

# Persist environment for subsequent bash commands
if [ -n "$CLAUDE_ENV_FILE" ]; then
    # Activate Python venv
    if [ -f "$HOME/.venv/bin/activate" ]; then
        echo 'source ~/.venv/bin/activate' >> "$CLAUDE_ENV_FILE"
    fi

    # Set common variables
    echo 'export NODE_ENV=development' >> "$CLAUDE_ENV_FILE"
fi

exit 0
```

---

## 7. Logging All Commands (PostToolUse)

Log every bash command for audit.

**Configuration**:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/log_commands.py"
          }
        ]
      }
    ]
  }
}
```

**Script**:
```python
#!/usr/bin/env python3
import json
import sys
from datetime import datetime
from pathlib import Path

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

command = input_data.get('tool_input', {}).get('command', '')
session_id = input_data.get('session_id', 'unknown')

log_file = Path.home() / '.claude' / 'command_log.txt'
log_file.parent.mkdir(parents=True, exist_ok=True)

with open(log_file, 'a') as f:
    timestamp = datetime.now().isoformat()
    f.write(f"[{timestamp}] [{session_id}] {command}\n")

sys.exit(0)
```

---

## 8. Auto-Allow Read Operations (PermissionRequest)

Skip permission prompts for reading docs.

**Configuration**:
```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/auto_read.py"
          }
        ]
      }
    ]
  }
}
```

**Script**:
```python
#!/usr/bin/env python3
import json
import sys

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

file_path = input_data.get('tool_input', {}).get('file_path', '')

# Auto-allow for documentation files
if file_path.endswith(('.md', '.txt', '.json', '.yml', '.yaml')):
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PermissionRequest",
            "decision": {"behavior": "allow"}
        }
    }
    print(json.dumps(output))

sys.exit(0)
```

---

## 9. Stop Hook - Verify Completion (Stop)

Use LLM to evaluate if work is complete.

**Configuration (prompt-based)**:
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if Claude completed all requested tasks. Context: $ARGUMENTS. Respond with {\"decision\": \"approve\"} if done, or {\"decision\": \"block\", \"reason\": \"what's missing\"} if not.",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

---

## 10. Modify Tool Input (PreToolUse)

Add safety flags to dangerous commands.

**Configuration**:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/safe_rm.py"
          }
        ]
      }
    ]
  }
}
```

**Script**:
```python
#!/usr/bin/env python3
import json
import sys

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

command = input_data.get('tool_input', {}).get('command', '')

# Add -i flag to rm commands
if command.startswith('rm ') and '-i' not in command:
    modified = command.replace('rm ', 'rm -i ', 1)
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow",
            "updatedInput": {"command": modified}
        }
    }
    print(json.dumps(output))

sys.exit(0)
```
