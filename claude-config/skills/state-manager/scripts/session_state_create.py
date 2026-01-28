#!/usr/bin/env python3
"""
SessionStart hook to auto-create state files.
Creates a new state file in .state/ directory on session startup.
"""
import json
import os
import subprocess
import sys
from datetime import datetime, timezone


def get_repo_root():
    """Get git repo root, or None if not in a repo."""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return None


def create_state_file(repo_root: str, session_id: str) -> str:
    """Create a new state file and return its path."""
    state_dir = os.path.join(repo_root, ".state")
    os.makedirs(state_dir, exist_ok=True)

    # Ensure .state is gitignored
    gitignore_path = os.path.join(repo_root, ".gitignore")
    gitignore_entry = ".state/"
    try:
        if os.path.exists(gitignore_path):
            with open(gitignore_path, "r") as f:
                content = f.read()
            if gitignore_entry not in content:
                with open(gitignore_path, "a") as f:
                    f.write(f"\n{gitignore_entry}\n")
        else:
            with open(gitignore_path, "w") as f:
                f.write(f"{gitignore_entry}\n")
    except (IOError, PermissionError):
        pass  # Skip gitignore update if we can't write

    timestamp = int(datetime.now().timestamp())
    filename = f"{timestamp}.state.md"
    filepath = os.path.join(state_dir, filename)

    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    template = f"""---
created: {now_iso}
updated: {now_iso}
session_id: {session_id}
status: active
topic: ""
---

## Context
[Session context - update as conversation progresses]

## Decisions Made
- [None yet]

## Open Questions
- [ ] [None yet]

## Key Learnings
- [None yet]

## Next Steps
- [ ] [None yet]
"""

    with open(filepath, "w") as f:
        f.write(template)

    return filepath


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    # Only create on fresh startup, not resume/clear/compact
    source = input_data.get("source", "")
    if source != "startup":
        sys.exit(0)

    repo_root = get_repo_root()
    if not repo_root:
        # Not in a git repo, skip
        sys.exit(0)

    session_id = input_data.get("session_id", "unknown")

    try:
        filepath = create_state_file(repo_root, session_id)
        rel_path = os.path.relpath(filepath, repo_root)
        # Output added to conversation context
        print(f"[State file created: {rel_path}]")
    except (IOError, PermissionError) as e:
        # Don't block session start on failure
        print(f"[Could not create state file: {e}]", file=sys.stderr)

    sys.exit(0)


if __name__ == "__main__":
    main()
