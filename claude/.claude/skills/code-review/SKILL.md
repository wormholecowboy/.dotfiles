---
name: code-review
description: Performs a technical code review of recently changed files for bugs, security issues, and standards compliance, then writes a report. Use before committing, as a pre-commit quality gate. Optionally scoped to a specific commit, range, or file.
argument-hint: "[commit | commit-range | file/dir path] (default: uncommitted changes)"
---

# Code Review

Perform technical code review on recently changed files, or on a specific target passed as an argument.

## Scope (from arguments)

Arguments: `$ARGUMENTS`

Determine the review scope:

- **No argument** — review uncommitted changes (default behavior below).
- **A commit SHA/ref** (e.g. `abc1234`, `HEAD~1`) — review that commit: `git show <ref> --stat` and `git show <ref>`; read the full post-commit version of each touched file (`git show <ref>:<path>` if not at HEAD).
- **A commit range** (e.g. `main..HEAD`, `abc1234..def5678`) — review the combined diff: `git diff <range>` and `git diff --stat <range>`.
- **A file or directory path** — review that file/directory in its entirety as it exists now, plus its uncommitted diff if any.

If the argument is ambiguous (could be a ref or a path), check with `git rev-parse --verify` and whether the path exists; ask the user only if both match.

When a scope argument is given, skip the "recently changed files" gathering commands below and use the scoped commands instead. Everything else (analysis, verification, output) applies unchanged.

## Core Principles

Review Philosophy:

- Simplicity is the ultimate sophistication - every line should justify its existence
- Code is read far more often than it's written - optimize for readability
- The best code is often the code you don't write
- Elegance emerges from clarity of intent and economy of expression

## What to Review

Start by gathering codebase context to understand the codebase standards and patterns.

Start by examining:

- CLAUDE.md
- README.md
- Key files in the core module
- Documented standards in the docs directory (and any `.claude/references/` docs)

After you have a good understanding, run these commands:

```bash
git status
git diff HEAD
git diff --stat HEAD
```

Then check the list of new files:

```bash
git ls-files --others --exclude-standard
```

Read each new file in its entirety. Read each changed file in its entirety (not just the diff) to understand full context.

For each changed file or new file, analyze for:

1. **Logic Errors**
   - Off-by-one errors
   - Incorrect conditionals
   - Missing error handling
   - Race conditions

2. **Security Issues**
   - SQL injection vulnerabilities
   - XSS vulnerabilities
   - Insecure data handling
   - Exposed secrets or API keys

3. **Performance Problems**
   - N+1 queries
   - Inefficient algorithms
   - Memory leaks
   - Unnecessary computations

4. **Code Quality**
   - Violations of DRY principle
   - Overly complex functions
   - Poor naming
   - Missing type hints/annotations

5. **Adherence to Codebase Standards and Existing Patterns**
   - Adherence to standards documented in the docs directory
   - Linting, typing, and formatting standards
   - Logging standards
   - Testing standards

## Verify Issues Are Real

- Run specific tests for issues found
- Confirm type errors are legitimate
- Validate security concerns with context

## Output Format

Save a new file to `.claude/code-reviews/[appropriate-name].md`

**Stats:**

- Files Modified: 0
- Files Added: 0
- Files Deleted: 0
- New lines: 0
- Deleted lines: 0

**For each issue found:**

```
severity: critical|high|medium|low
file: path/to/file.py
line: 42
issue: [one-line description]
detail: [explanation of why this is a problem]
suggestion: [how to fix it]
```

If no issues found: "Code review passed. No technical issues detected."

## Important

- Be specific (line numbers, not vague complaints)
- Focus on real bugs, not style
- Suggest fixes, don't just complain
- Flag security issues as CRITICAL
