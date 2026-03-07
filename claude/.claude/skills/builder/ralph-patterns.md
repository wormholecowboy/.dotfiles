# Ralph Wiggum Development Patterns

Research findings to inform the builder skill's task isolation system.

**Sources:**
- [ghuntley/how-to-ralph-wiggum](https://github.com/ghuntley/how-to-ralph-wiggum)
- [snwfdhmp/awesome-ralph](https://github.com/snwfdhmp/awesome-ralph)
- [HumanLayer: Brief History of Ralph](https://www.humanlayer.dev/blog/brief-history-of-ralph)

---

## Core Philosophy

> "The key point of Ralph is not 'run forever' but 'carve off small bits of work into independent context windows.'"

> "Progress doesn't persist in the LLM's context window — it lives in your files and git history."

> "Sit on the loop, not in it" — engineer the setup and environment, let Ralph do the work.

---

## Architecture Principles

### 1. One Task Per Loop Iteration

Each iteration:
1. Spawns fresh agent with clean context
2. Agent reads specs from disk
3. Agent picks ONE task
4. Agent implements it
5. Agent validates
6. Agent updates state files
7. Agent exits

**Why:** Fresh context isolation prevents hallucination accumulation. No lossy compaction events.

### 2. State Lives in Files

Files that persist between iterations:
- `IMPLEMENTATION_PLAN.md` - Task list with status (shared state)
- `AGENTS.md` - Operational guide (how to run/test/build)
- `specs/*.md` - Requirements (one file per topic)
- Git history - The actual progress

**Rule:** Context windows rotate; files persist. Never rely on session memory.

### 3. Validation as Backpressure

> "The best Ralph tasks have built-in success signals: Tests pass. Types resolve. Linters approve. The loop can verify its own work without human judgment."

Downstream validation rejects invalid work:
- Tests
- Type checking
- Linting
- Build verification

**Calibration matters:** Too much rejection = friction. Too little = poor outputs through.

### 4. Deterministic Setup

Each iteration loads the same files deterministically:
```
1. Read PROMPT.md (instructions)
2. Read AGENTS.md (operational context)
3. Read specs/* (requirements)
4. Read IMPLEMENTATION_PLAN.md (current state)
5. Execute one task
6. Update state files
7. Exit
```

**Why:** Consistency despite nondeterministic LLM outputs.

---

## File Structure (Huntley's Pattern)

```
project-root/
├── loop.sh                    # Orchestration script
├── PROMPT_build.md            # Build mode instructions
├── PROMPT_plan.md             # Planning mode instructions
├── AGENTS.md                  # Operational guide (~60 lines max)
├── IMPLEMENTATION_PLAN.md     # Task list (generated/updated by Ralph)
├── specs/                     # Requirements (one file per topic)
│   ├── topic-a.md
│   └── topic-b.md
└── src/                       # Application source
```

### AGENTS.md (Operational Only)

What belongs:
- How to run the application
- Testing procedures
- Build commands
- Deployment steps

What doesn't belong:
- Status updates (→ IMPLEMENTATION_PLAN.md)
- Progress tracking (→ IMPLEMENTATION_PLAN.md)
- Task planning (→ IMPLEMENTATION_PLAN.md)

> "A bloated AGENTS.md pollutes every future loop's context."

### Spec Files

**One topic per file.** Test: Can you describe it in one sentence without "and"?
- "The color extraction system analyzes images to identify dominant colors"
- NOT "The user system handles authentication, profiles, and billing" → 3 files

---

## Loop Mechanics

### Basic Loop (Simplest Form)

```bash
while :; do
  cat PROMPT.md | claude
done
```

### Enhanced Loop with Controls

```bash
#!/bin/bash
MODE=${1:-build}
MAX_ITERATIONS=${2:-0}  # 0 = unlimited
ITERATION=0

while :; do
  ((ITERATION++))

  if [[ $MAX_ITERATIONS -gt 0 && $ITERATION -gt $MAX_ITERATIONS ]]; then
    echo "Max iterations reached"
    exit 0
  fi

  cat "PROMPT_${MODE}.md" | claude -p \
    --dangerously-skip-permissions \
    --output-format=stream-json
done
```

### Inner Loop Lifecycle (Per Iteration)

1. **Orient** - Study specs/requirements
2. **Read Plan** - Study IMPLEMENTATION_PLAN.md
3. **Select** - Pick most important task
4. **Investigate** - Study relevant source code
5. **Implement** - Execute the task
6. **Validate** - Run tests/lints (backpressure)
7. **Update Plan** - Mark task complete, note discoveries
8. **Update Agents.md** - Record operational learnings
9. **Commit & Push** - Persist changes
10. **Exit** - Clean termination

---

## Task Granularity

### What Makes a Good Task

- Has built-in success signals (tests, types, lint)
- Can be completed in one context window
- Has clear validation criteria
- Dependencies are explicit

### What Doesn't Work

- Tasks requiring deep understanding of entire codebase
- Tasks requiring nuanced human judgment
- Tasks without clear completion criteria
- Tasks with implicit/hidden dependencies

---

## Context Window Strategy

With ~176K usable tokens (from 200K advertised):
- **40-60% utilization** is the "smart zone"
- First ~5K tokens for specs
- Main agent as scheduler, spawn subagents for expensive work
- Each subagent adds ~156KB capacity

**Anti-pattern:** Stuffing context until compaction. Context rot degrades output quality.

---

## Common Pitfalls

### 1. Context Rot
Symptom: Quality degrades over long sessions
Fix: Rotate context windows (task isolation)

### 2. Plan Divergence
Symptom: Ralph implementing wrong things or duplicating work
Fix: Regenerate plan (cheap compared to Ralph going in circles)

### 3. Runaway Loops
Symptom: Infinite iterations without progress
Fix: Cap iterations, implement circuit breakers, monitor for exit conditions

### 4. State Desync
Symptom: Plan doesn't reflect actual code state
Fix: Gap analysis between specs and code before building

### 5. Bloated Context Files
Symptom: AGENTS.md grows with status updates
Fix: Strict separation—operational info only in AGENTS.md

---

## Steering Mechanisms

### Upstream (Before Generation)
- Deterministic file loading
- Existing code patterns shape output
- Spec files define requirements
- AGENTS.md defines operational context

### Downstream (After Generation)
- Tests reject invalid code
- Type checking catches errors
- Linting enforces style
- Build verification confirms integration

> "Update AGENTS.md when discovering new operational patterns; add utilities when Ralph generates wrong patterns"

---

## Key Metrics

| Term | Definition |
|------|------------|
| **JTBD** | Job to be Done (high-level user need) |
| **Topic** | Distinct aspect within a JTBD |
| **Spec** | Requirements doc for one topic |
| **Task** | Unit of work (one per iteration) |

---

## Video Research: Roman's Ralph Analysis

**Source:** https://www.youtube.com/watch?v=I7azCAgoUHc (NeurIPS published researcher)

### Context Window Strategy

**The "Dumb Zone":** Performance degrades rapidly around ~100k tokens. Traditional vibe coding pushes into this zone via context compaction. Ralph avoids it entirely by resetting context each iteration.

**Key insight:** Treat context windows as a **static allocation problem**, not a growing buffer that gets trimmed.

**Anti-pattern:** Anthropic's Ralph plugin runs loops within the same session using Stop hooks. This causes context rot and compaction. Use isolated subagents instead.

### Three Build Modes

| Mode | Planning Effort | Risk | Use Case |
|------|----------------|------|----------|
| Implementation | High | Medium | Real features, watched closely |
| Exploration | Low | Low | Research, MVPs, feature spikes |
| Brute Force Testing | Medium | Low | Security/UI testing overnight |

### Bidirectional Speccing

Before execution, you and Claude ask each other questions until fully aligned. This surfaces implicit assumptions that "typically are the root of many bugs."

The spec becomes source of truth, replacing "previous context" as the shared understanding.

### Task Validation Pattern

Each iteration writes an **unbiased unit test** to verify its own work. The test becomes validation for that task. If the test passes, mark complete. If not, the error is caught immediately rather than cascading.

### Error Cascade Warning

> "If you don't have a bulletproof plan, the errors will cascade down and are amplified. Each iteration goes off the previous iteration. One bad test can poison future loops."

### Planning is the Skill

> "The biggest skill in Ralph loops by far is the skill of **architecting a good plan**. The more you put into the plan, the more you get out of Ralph."

---

## Adaptation Notes for Builder Skill

### What We Keep
- One task per context window
- State lives in files (state.yaml)
- Validation after each task
- Deterministic setup (same files each iteration)
- Clear task dependencies

### What We Adapt
- **Dependency tracking** - Can't start task until deps complete
- **Code review per task** - Not per phase
- **Structured state file** - YAML with task status, deps, validation results
- **Task-level validation commands** - Each task defines its own checks

### What We Add
- **Phase-level validation** - After all tasks in phase complete
- **Commit tracking** - Hash recorded per task (not per phase)
- **Review status** - Per task, not per commit batch
- **Blocker escalation** - Path to human when stuck

---

## Docker/Container Setup for Ralph

> Research compiled 2026-01-25 from Docker docs, Anthropic docs, and community implementations.

### Why Containerization is Mandatory

`--dangerously-skip-permissions` bypasses Claude's permission system entirely. Without a sandbox:
- Home directory accessible (SSH keys, credentials, browser cookies)
- System files modifiable
- Network unrestricted (data exfiltration possible)

**Rule:** Container becomes your only security boundary.

### Option 1: Docker Official Claude Code Sandbox

**Quickest path to production Ralph:**

```bash
# Basic invocation
docker sandbox run claude

# With workspace
docker sandbox run -w ~/my-project claude

# With custom prompt
docker sandbox run -w ~/my-project -p "Your task here" claude
```

**Base image:** `docker/sandbox-templates:claude-code`

Includes:
- Ubuntu base
- Claude Code (with `--dangerously-skip-permissions` by default)
- Node.js, npm
- Python 3, pip
- Go
- Git, GitHub CLI
- ripgrep, jq
- Runs as non-root `agent` user with sudo access

**Credential management:**
- API keys stored in persistent volume `docker-claude-sandbox-data`
- Mounted at `/mnt/claude-data`
- Symlinked to agent's home directory

### Option 2: Custom Dockerfile (Project-Specific Validation)

For projects needing specific validation tools:

```dockerfile
FROM docker/sandbox-templates:claude-code

# Project-specific validation tools
# Python projects
RUN pip install pytest ruff mypy coverage

# Node projects
RUN npm install -g jest eslint prettier

# Both
RUN pip install pre-commit

# Optional: Language-specific
RUN pip install black isort  # Python formatting
RUN npm install -g typescript  # TypeScript

# Setup commands (run after container start)
WORKDIR /workspace
```

**Volume mounts (critical for security):**

```yaml
# docker-compose.yml
services:
  ralph:
    build: .
    volumes:
      # Project directory ONLY - no home directory access
      - ./:/workspace
      # Optional: cached dependencies (read-only)
      - ~/.npm:/home/agent/.npm:ro
      - ~/.cache/pip:/home/agent/.cache/pip:ro
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
```

### Option 3: DevContainer (VS Code/Cursor Integration)

For IDE-integrated development:

```json
// .devcontainer/devcontainer.json
{
  "name": "Ralph Environment",
  "image": "docker/sandbox-templates:claude-code",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "dbaeumer.vscode-eslint"
      ]
    }
  },
  "postCreateCommand": "pip install -r requirements.txt && npm install",
  "mounts": [
    "source=${localWorkspaceFolder},target=/workspace,type=bind"
  ],
  "remoteUser": "agent"
}
```

### Option 4: Native Sandboxing (No Docker)

Claude Code has built-in sandboxing via OS primitives:
- **macOS:** Seatbelt framework
- **Linux/WSL2:** bubblewrap + socat

Enable via: `/sandbox` command in Claude Code

```json
// settings.json
{
  "sandbox": {
    "mode": "auto-allow",  // or "regular-permissions"
    "filesystem": {
      "allowedPaths": ["./"],
      "deniedPaths": ["~/.ssh", "~/.aws", "~/.config"]
    },
    "network": {
      "allowedHosts": ["github.com", "api.anthropic.com", "registry.npmjs.org", "pypi.org"]
    }
  }
}
```

**Limitations:**
- Network filtering by domain only (no deep inspection)
- `docker` command incompatible with sandbox (must exclude)
- `watchman` incompatible (use `jest --no-watchman`)

### Validation Tool Requirements

**Minimum for any Ralph container:**

| Category | Tools | Purpose |
|----------|-------|---------|
| Linting | ruff, eslint | Style/error checking |
| Testing | pytest, jest | Test execution |
| Type checking | mypy, tsc | Static analysis |
| Formatting | black, prettier | Code formatting |
| Git | git, gh | Version control |

**Setup commands pattern:**

```bash
# In Dockerfile or postCreateCommand
pip install pytest ruff mypy black
npm install -g jest eslint prettier typescript
```

### Loop Script for Docker

```bash
#!/bin/bash
# ralph-loop.sh - Run Ralph in Docker container
set -euo pipefail

PROJECT_DIR="${1:-.}"
MODE="${2:-build}"
MAX_ITERATIONS="${3:-50}"
PROMPT_FILE="PROMPT_${MODE}.md"

cd "$PROJECT_DIR"

docker run --rm -it \
  -v "$(pwd):/workspace" \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  docker/sandbox-templates:claude-code \
  bash -c "
    cd /workspace
    ITERATION=0
    while [ \$ITERATION -lt $MAX_ITERATIONS ]; do
      cat $PROMPT_FILE | claude -p \
        --dangerously-skip-permissions \
        --output-format=stream-json

      git add -A && git commit -m 'Ralph iteration \$ITERATION' || true
      ITERATION=\$((ITERATION + 1))
    done
  "
```

### Security Checklist

Before running Ralph:

- [ ] Container has NO access to `~/.ssh`
- [ ] Container has NO access to `~/.aws` or `~/.config`
- [ ] Only project directory mounted
- [ ] API key passed via environment variable (not file)
- [ ] Network restricted to required domains only
- [ ] Max iterations set (prevent runaway)
- [ ] Git commits isolated (can rollback)

### Common Pitfalls

1. **Mounting home directory** - Don't. Mount only project directory.
2. **Caching credentials in image** - Don't. Pass via environment.
3. **Running as root** - Don't. Use `agent` user.
4. **No iteration limit** - Always set `--max-iterations`.
5. **Network unrestricted** - Whitelist required domains only.

### Sources

- [Docker Claude Code Sandbox Docs](https://docs.docker.com/ai/sandboxes/claude-code/)
- [Claude Code Sandboxing](https://code.claude.com/docs/en/sandboxing)
- [Andrea Bizzotto's DevContainer Guide](https://codewithandrea.com/articles/run-ai-agents-inside-devcontainer/)
- [textcortex/claude-code-sandbox](https://github.com/textcortex/claude-code-sandbox)
- [ghuntley/how-to-ralph-wiggum](https://github.com/ghuntley/how-to-ralph-wiggum)
- [frankbria/ralph-claude-code](https://github.com/frankbria/ralph-claude-code)
