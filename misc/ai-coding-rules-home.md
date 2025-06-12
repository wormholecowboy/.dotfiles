# RULES FOR ANY AI ASSISTANTS THAT ARE READING THIS DOCUMENT. FOLLOW THESE RULES.

## CODE STYLE
- Always prefer simple solutions
- Always look for existing code to iterate on instead of creating new code. Do not drastically change the patterns before trying to iterate on existing patterns.
- Instead of duplicating code, check for other areas of the codebase that might already have similar code and functionality
- You are careful to only make changes that are requested, unless you are sure that the new functionality is related to the request
- When fixing an issue or bug, do not introduce a new pattern or technology without first exhausting all options for the existing implementation. Remove old implementations if they are no longer used. 
- Keep the codebase very clean and organized
- Use design patterns when it helps to reduce complexity and make code more elegant. Always tells me when you are using a design pattern.
- If the file reaches over 500 lines, refactor by splitting it into modules or helper files.
- **Organize code into clearly separated modules**, grouped by feature or responsibility.
- **Use clear, consistent imports** (prefer relative imports within packages).

## TESTING
- Mocking data is only needed for tests, never mock data for dev or prod
- Use pytest for python and jest for javascript. 
- **After updating any logic**, check whether existing unit tests need to be updated. If so, do it.
- **Tests should live in a `/tests` folder** mirroring the main app structure.
  - Include at least:
    - 1 test for expected use
    - 1 edge case
    - 1 failure case

## MISC
- Avoid writing scripts in files if possible, especially if the script is likely only to be run once
- Focus on the areas of code relevant to the task
- Avoid making major changes to the patterns and architecture of how a feature works, after it has shown to work well, unless explicitly instructed
- Always think about what other methods and areas of code might be affected by code changes
- Only add stubbing or fake data patterns for testing
- Always ask before overwriting my .env files
- Ask for help if you think you are missing context
- Always use only use known, verified packages, libraries and functions to avoid hallucination.
- **Always confirm file paths and module names** exist before referencing them in code or tests.

## SECURITY
- Always use row-level security if it is an options with the database
- Always rate-limit API endpoints
- Always put captchas on auth and signup pages

## PROJECTS
- **Always read `PLANNING.md`** if it exists at the start of a new conversation to understand the project's architecture, goals, style, and constraints.
- **Check `TASKS.md`** if it exists before starting a new task. If the task isn’t listed, add it with a brief description and today's date.
- **Use consistent naming conventions, file structure, and architecture patterns** as described in `PLANNING.md`.
- **Mark completed tasks in `TASKS.md`** immediately after finishing them.
- Add new sub-tasks or TODOs discovered during development to `TASKS.md` under a “Discovered During Work” section.

### 📚 Documentation & Explainability
- **Update `README.md`** when new features are added, dependencies change, or setup steps are modified.
- **Comment non-obvious code** and ensure everything is understandable to a mid-level developer.
- When writing complex logic, **add an inline `# Reason:` comment** explaining the why, not just the what.

## GIT
- Use all blank settings when creating a repo (no .gitignore, no readme, mit license). Name the main branch "main". 
