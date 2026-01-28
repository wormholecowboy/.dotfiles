# 💻 Coding Assistant Guidelines

CRITICAL: Always check the cwd when performing file operations. Make sure you are in the right worktree/branch. Ask the user if it is uncertain.

## 1. Code Style & Organization
- **Prefer simplicity:** Always choose the simplest working solution.  
- **Reuse before adding:** Check for existing implementations before duplicating logic.  
- **Stick to the stack:** When fixing issues, exhaust current tech and patterns before introducing new ones.  
- **Scoped changes:** Only modify code directly relevant to the request unless closely related functionality is impacted.  
- **Clean up:** Remove unused code and obsolete implementations.  
- **Structure matters:**  
  - Keep files under **500 lines** → refactor into modules/helpers when larger.  
  - Organize code by **feature or responsibility**.  
  - Use **clear, consistent imports** (prefer relative imports inside packages).  
- **Design patterns:** Apply when they reduce complexity. Always state which pattern is used.  

## 2. Testing
- **Frameworks:** Use `pytest` (Python) and `jest` (JavaScript).  
- **Mocking/stubbing:** Only for tests. Never in dev/prod code.  
- **Coverage:** For each new/updated function, include:  
  - 1 expected use case  
  - 1 edge case  
  - 1 failure case  
- **Maintenance:** Update existing tests whenever logic changes.  

## 3. Documentation & Explainability
- **Comments:**  
  - Only comment non-obvious code.  
  - For complex logic, add an inline `# Reason:` comment explaining *why*, not just *what*.  

## 4. Security
- Always enable **row-level security** if supported by the database.  
- **Rate-limit** all API endpoints.  
- Require **CAPTCHAs** on authentication and signup flows.  

## 5. Workflow & Safety
- Focus only on code relevant to the current task.  
- Don’t change stable architecture/patterns unless explicitly told.  
- Think through impacts on related code before making changes.  
- Confirm file paths and module names exist before using them.  
- Ask before overwriting `.env` files.  
- Only use **known, verified** packages/libraries/functions.  
- Shut down any servers you start.  
- Ask for help when missing context.  
- IF we are planning/brainstorming, keep code snippets to a minimum. Focus on concepts.

## 6. Git & Repo Setup
- New repos: use **blank settings** (no `.gitignore`, no README, MIT license).  
- Default branch: `main`.  
- Use **git** and **GitHub CLI** for all repo commands.  
- Assume you are already in the parent directory of the repo unless otherwise specified. Run search tools from cwd.

## 7. ANTI-Patterns (avoid these)
- **Magic strings, numbers, etc:** Use named constants instead.  
- **Random reformatting**: Don’t reformat code.

## 8. Modifiers
If you see these modifiers in my query, apply them:
- `*sa`: give a short answer

## 9. Explore Agent Usage
When using the Explore agent, ALWAYS:
1. Pass the explicit cwd path in the prompt
2. Verify found files exist before reporting
3. Never assume standard project structures
4. Report back which worktree was searched, if any

## 10. Git-Ops Agent Usage
**Use git-ops agent for:**
- Reviewing/summarizing branch history or PRs
- Complex multi-step operations (rebase workflows, conflict resolution)
- Anything requiring synthesis of multiple git commands

**Run git commands directly for:**
- Simple one-liners: `git status`, `git diff`, `git add`, `git commit`
- Quick checks where raw output is needed immediately

## 11. Frontend/UI Work
- Use the **agent-browser** skill (`/agent-browser`) for:
  - Visual validation of UI changes
  - Taking screenshots for verification
  - Checking console logs for errors
  - Testing interactive elements and user flows
- Run browser validation after significant UI changes to catch visual regressions.

## 12. Shorthand
User will often use shorthand when typing. The list following are examples of common shorthand.

### EXAMPLES
- w: with
- bc: because
- def: definitely
- ref: reference
- dir: directory
- arch: architecture
- mem: memory
- diff: difference
- convo: conversation
- struct: structure
- str: stretching

Do your best to infer the meaning of any shorthand. Ask if you're not sure.

## 12. Debugger Agent Usage

**Use debugger agent PROACTIVELY for:**
- Test failures (any test failure)
- Runtime errors or exceptions
- Build failures
- Unexpected behavior reported by user
- Any error that requires investigation

**Run simple diagnostics directly for:**
- Obvious typos (missing comma, bracket)
- Import errors with clear missing dependency
- Single-line syntax errors

### Debug Context Format

When invoking the debugger agent, ALWAYS pass a Debug Context block:

```yaml
## Debug Context

### Current Issue
symptom: |
  [Exact error message or description]
error_type: [Test Failure | Runtime Error | Build Error | Unexpected Behavior]
file: [Primary file involved, if known]
line: [Line number, if known]

### Reproduction Steps
1. [Step 1]
2. [Step 2]

### Environment
language: [Python | TypeScript | etc.]
framework: [pytest | jest | etc.]
relevant_dependencies: [List any relevant packages]

### Previous Attempts (if any)
- attempt_1:
    hypothesis: [What we thought was wrong]
    action: [What we tried]
    result: [What happened]

### Constraints
- [Known constraints]
- [Things ruled out]
```

### Iteration Protocol

1. Debugger investigates, confirms root cause, and applies fix directly
2. Main thread runs verification steps returned by debugger
3. If fix fails: re-invoke debugger with updated Debug Context (add to Previous Attempts)
4. If multiple hypotheses remain: debugger will request more info or try most likely fix
5. Keep history concise - summarize older attempts, detail recent ones

### Output Handling

- Debugger reports what was found AND what was fixed
- Main thread runs verification steps and updates user
- If verification fails, re-invoke with updated Debug Context
- DO NOT copy entire debug report into response - summarize findings

## 13. Server/Process Startup

**Before starting any server:**
1. `lsof -i :PORT` - Check if already running. If yes, ask before killing.
2. Look for `requirements.txt` or `pyproject.toml` before installing deps one-by-one.
3. Use project venv (`uv run`, `.venv/bin/python`), never system Python.
4. If venv is broken, recreate it rather than patching symlinks.

**Common ports to check:** 3000 (React), 5173 (Vite), 8000 (FastAPI/uvicorn), 8080 (generic)

**Anti-pattern:** Spawning background server processes that respawn and conflict with each other. Always track what you've started.
