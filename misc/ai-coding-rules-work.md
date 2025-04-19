# RULES FOR ANY AI ASSISTANTS THAT ARE READING THIS

## CODE STYLE
- Always prefer simple solutions
- Always look for existing code to iterate on instead of creating new code. Do not drastically change the patterns before trying to iterate on existing patterns.
- Avoid duplication of code whenever possible, which means checking for other areas of the codebase that might already have similar code and functionality
- Write code that takes into account the different environments: dev, test, and prod
- You are careful to only make changes that are requested or you are confident are well understood and related to the change being requested
- When fixing an issue or bug, do not introduce a new pattern or technology without first exhausting all options for the existing implementation. And if you finally do this, make sure to remove the old implementation afterwards so we don't have duplicate logic.
- Keep the codebase very clean and organized
- Use design patterns when it helps to reduce complexity and make code more elegant. Always tells me when you are using a design pattern.
- **Never create a file longer than 500 lines of code.** If a file approaches this limit, refactor by splitting it into modules or helper files.
- **Organize code into clearly separated modules**, grouped by feature or responsibility.
- **Use clear, consistent imports** (prefer relative imports within packages).

## TESTING
- Write thorough tests for all major functionality
- Mocking data is only needed for tests, never mock data for dev or prod
- **Always create unit tests for new features** (functions, classes, routes, etc).
- Use pytest for python and jest for javascript. 
- **After updating any logic**, check whether existing unit tests need to be updated. If so, do it.
- When writing tests, include at least:
    - 1 test for expected use
    - 1 edge case
    - 1 failure case
