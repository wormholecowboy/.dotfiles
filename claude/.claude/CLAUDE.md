# 💻 Coding Assistant Guidelines

CRITICAL: Always check the cwd when performing file operations. Make sure you are in the right worktree/branch. Ask the user if it is uncertain.

## 1. Code Style & Workflow
- **Prefer simplicity:** Always choose the simplest working solution.
- **Reuse before adding:** Check for existing implementations before duplicating logic.
- **Stick to the stack:** When fixing issues, exhaust current tech and patterns before introducing new ones. Don't change stable architecture unless explicitly told.
- **Scoped changes:** Only modify code directly relevant to the request. Think through impacts on related code.
- **Clean up:** Remove unused code and obsolete implementations.
- **Structure:** Keep files under **500 lines**. Organize by feature/responsibility. Use clear, consistent imports.
- **Design patterns:** Apply when they reduce complexity. State which pattern is used.
- **Comments:** Only for non-obvious code. Use `# Reason:` for complex logic explaining *why*.
- **Safety:** Confirm paths/modules exist. Ask before overwriting `.env`. Only use verified packages.
- **Context resets:** Help update memory files so user can pick up where you left off.
- **No Laziness:** Find root causes. No temporary fixes. Senior developer standards.

## 2. Testing
- **Frameworks:** `pytest` (Python), `jest` (JavaScript).
- **Mocking/stubbing:** Only for tests. Never in dev/prod.
- **Coverage:** 1 expected case, 1 edge case, 1 failure case per function.
- **Maintenance:** Update tests when logic changes.

## 3. Git & Repo Setup
- New repos: **blank settings** (no `.gitignore`, no README, MIT license).
- Default branch: `main`.
- Use **git** and **GitHub CLI** for all repo commands.
- Assume already in repo parent directory. Run search tools from cwd.

## 4. ANTI-Patterns (avoid these)
- **Magic strings, numbers, etc:** Use named constants instead. Don't inline magic strings, etc.
- **Random reformatting:** Don't reformat code.

## 5. Shorthand & Modifiers
Infer meaning from shorthand. Ask if unsure.

| Short | Meaning |
|-------|---------|
| w | with |
| bc | because |
| def | definitely |
| ref | reference |
| dir | directory |
| arch | architecture |
| mem | memory |
| diff | difference |
| convo | conversation |
| struct | structure |
| str | stretching |
| `*sa` | give a short answer |

## 6. Agent Usage

Use subagents liberally for clean context. One task per agent.

| Agent | Use For | Run Directly Instead |
|-------|---------|---------------------|
| **Explore** | Codebase exploration, finding files/patterns | Specific file reads |
| **git-ops** | Branch analysis, PR summaries, rebases, conflicts | Simple `git status`, single commands |
| **debugger** | Test failures, runtime errors, build failures | Obvious typos, missing imports |
| **agent-browser** | UI validation, screenshots, console logs, user flows | N/A - always use skill |

**Explore:** Always pass explicit cwd path. Verify files exist. Report which worktree searched.

**Debugger:** Use PROACTIVELY. Pass minimal context: `symptom`, `error_type`, `file`. If fix fails, re-invoke with what was tried.

## 7. Server/Process Startup

**Before starting any server:**
1. `lsof -i :PORT` - Check if running. Ask before killing.
2. Look for `requirements.txt` or `pyproject.toml` before installing deps.
3. Use project venv (`uv run`, `.venv/bin/python`), never system Python.
4. If venv broken, recreate it.

**Common ports:** 3000 (React), 5173 (Vite), 8000 (FastAPI), 8080 (generic)

**Anti-pattern:** Background processes that respawn and conflict. Track what you start.
