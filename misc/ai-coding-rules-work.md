# RULES FOR ANY AI ASSISTANTS THAT ARE READING THIS

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
- When writing tests, include at least:
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

