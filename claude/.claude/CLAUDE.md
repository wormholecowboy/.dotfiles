# 💻 Coding Assistant Guidelines

CRITICAL: Always check the cwd when performing file operations. Make sure you are in the right worktree/branch. Ask the user if it is uncertain.

## 1. Code Style & Workflow
- **Stick to the stack:** When fixing issues, exhaust current tech and patterns before introducing new ones. Don't change stable architecture unless explicitly told.
- **Scoped changes:** Only modify code directly relevant to the request. Think through impacts on related code.
- **Comments:** Only for non-obvious code. Use `# Reason:` for complex logic explaining *why*.
- **Safety:** Confirm paths/modules exist. Ask before overwriting `.env`. Only use verified packages.
- **No Laziness:** Find root causes. No temporary fixes. Senior developer standards.

## 2. Testing
- **Mocking/stubbing:** Only for tests. Never in dev/prod.
- **Coverage:** 1 expected case, 1 edge case, 1 failure case per function.
- **Maintenance:** Update tests when logic changes.

## 3. Shorthand & Modifiers
Infer meaning from shorthand. Ask if unsure.

`w`=with
`bc`=because
`def`=definitely
`ref`=reference
`arch`=architecture
`mem`=memory
`convo`=conversation
`*sa`=give a short answer

## 4. Server/Process Startup

**Before starting any server:**
1. `lsof -i :PORT` - Check if running. Ask before killing.
2. Look for `requirements.txt` or `pyproject.toml` before installing deps.
3. Use project venv (`uv run`, `.venv/bin/python`), never system Python.
4. If venv broken, recreate it.

**Common ports:** 3000 (React), 5173 (Vite), 8000 (FastAPI), 8080 (generic)

**Anti-pattern:** Background processes that respawn and conflict. Track what you start.

## 5. Work Computer Config

<!--# BEGIN SNYK GLOBAL RULE -->
---
alwaysApply: true
always_on: true
trigger: always_on
applyTo: "**"
description: Snyk Security At Inception
---

Note: snyk CLI is only available on my work computer. Hostname begins with `LVUS`.

# Project security best practices

- Always run snyk_code_scan tool for new first party code that is generated in a Snyk-supported language.
- If any security issues are found based on newly introduced or modified code or dependencies, attempt to fix the issues using the results context from Snyk.
- Rescan the code after fixing the issues to ensure that the issues were fixed and that there are no newly introduced issues.
- Repeat this process until no new issues are found.
<!--# END SNYK GLOBAL RULE -->
