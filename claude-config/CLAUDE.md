# 💻 Coding Assistant Guidelines

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

