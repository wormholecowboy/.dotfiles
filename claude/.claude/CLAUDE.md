# 💻 Coding Assistant Guidelines

CRITICAL: Always check the cwd when performing file operations. Make sure you are in the right worktree/branch. Ask the user if it is uncertain.

## 1. Code Style & Workflow
- **Stick to the stack:** When fixing issues, exhaust current tech and patterns before introducing new ones. Don't change stable architecture unless explicitly told.
- **Scoped changes:** Only modify code directly relevant to the request. Think through impacts on related code.
- **Comments:** Only for non-obvious code. Use `# Reason:` for complex logic explaining *why*.
- **Safety:** Confirm paths/modules exist. Ask before overwriting `.env`. Only use verified packages.
- **No Laziness:** Find root causes. No temporary fixes. Senior developer standards.

## 2. Refactors / Moving Code
- **Prefer `Edit` over `Write`** when relocating existing code. `Edit` preserves bytes exactly; `Write` retypes from memory and can introduce drift (extra blank lines, stripped whitespace, dropped lines).
- **Verify with `diff`** after moving blocks: compare the original range (`git show HEAD:path`) against the new location. `ast.parse` only proves syntax — it won't catch missing or altered lines.
- **Smoke-test imports** with a `python3 -c "from new.module import ..."` to catch broken refs that syntax checks miss.

## 3. Testing
- **Mocking/stubbing:** Only for tests. Never in dev/prod.
- **Coverage:** 1 expected case, 1 edge case, 1 failure case per function.
- **Maintenance:** Update tests when logic changes.
- **Mocks grow per-test, not per-plan:** Start with the minimum stub that lets `require`/import succeed. For each new test: write the assertion first, run it, then add only the mock surface the failure demands. No closure-state, configurators (`__configure`/`__reset`), captured-args helpers, or pagination-cursor mocks until a test fails for lack of them. First test inlines; second creates the abstraction.
- **Anti-pattern (plan-driven mock factory):** writing a large mock factory upfront from the test plan, then writing tests against it. Most surface goes unused; speculative machinery rots into the foundation; reviewer can't justify any line because nothing concrete motivates it yet.
- **Production-code testability gaps emerge during the build, not planning** (e.g., `exports.handler = serverless(app)` blocking supertest until `exports.app` is added alongside). Don't plan around them — let real test failures surface them.

## 4. Shorthand & Modifiers
Infer meaning from shorthand. Ask if unsure.

`w`=with
`bc`=because
`def`=definitely
`ref`=reference
`arch`=architecture
`mem`=memory
`convo`=conversation
`*sa`=give a short answer
`*um`=update memory (mem skill)
`*mr <topic>`=read memory by topic (mem skill)
`*bu`=give me an answer in bullet points only

## 5. Server/Process Startup

**Before starting any server:**
1. `lsof -i :PORT` - Check if running. Ask before killing.
2. Look for `requirements.txt` or `pyproject.toml` before installing deps.
3. Use project venv (`uv run`, `.venv/bin/python`), never system Python.
4. If venv broken, recreate it.

**Common ports:** 3000 (React), 5173 (Vite), 8000 (FastAPI), 8080 (generic)

**Anti-pattern:** Background processes that respawn and conflict. Track what you start.

## 6. Work Computer Config

### AWS CLI

You don't have the AWS credentials exported in your environment, so bare `aws ...` commands fail with permission errors. Prepend `awsl; ` to any AWS CLI command and it will work — `awsl` is an alias to a script that exports the AWS variables into the current shell.

```bash
awsl; aws s3 ls
```

<!--# BEGIN SNYK GLOBAL RULE -->
---
alwaysApply: true
always_on: true
trigger: always_on
applyTo: "**"
description: Snyk Security At Inception
---

Note: snyk CLI is only available on my work computer. Hostname begins with `LVUS`.

### Project security best practices

- Always run snyk_code_scan tool for new first party code that is generated in a Snyk-supported language.
- If any security issues are found based on newly introduced or modified code or dependencies, attempt to fix the issues using the results context from Snyk.
- Rescan the code after fixing the issues to ensure that the issues were fixed and that there are no newly introduced issues.
- Repeat this process until no new issues are found.
<!--# END SNYK GLOBAL RULE -->

## 7. Memory

Persistent context lives in `.mem/` at git root. See `mem` skill for spec and triggers (`*um`, `*mr`, `/mem`).

## 8. Communication Style

- **Zero Filler**: Do not use sycophantic phrases like "You're absolutely right!", "Great question!", or "I hope this helps!".

### Output Style

- I hate answering multiple questions at once. If you are asking me more than 3 questions at a time, break them up and keep track of which ones you asked me. Also, visually show me curr/total (example: Q3/5)
