# OWASP Security Review

In-depth security audit based on OWASP Top 10 (Web/API) and OWASP Top 10 for LLMs. Modular architecture loads only relevant checks based on detected code patterns.

## Usage

- `/owasp-review` - Review staged/changed files (default)
- `/owasp-review --deep` - Full repository audit
- `/owasp-review --focus=auth` - Deep dive on specific category
- `/owasp-review path/to/file.py` - Review specific file(s)

## Modes

### Standard (default)
Scope: git diff or staged changes
- Detects code types via router patterns
- Loads only triggered check files
- Fast, focused review

### Deep Dive (`--deep`)
Scope: entire repository
1. Map repo structure (entry points, auth, API routes, LLM integrations)
2. Run router against full codebase
3. Load ALL triggered check files
4. Prioritize by risk:
   - Entry points (routes, handlers, controllers)
   - Auth/authz code paths
   - Data flow (input → processing → storage → output)
   - External integrations (APIs, LLMs, databases)
5. Generate comprehensive report with file-by-file findings

### Focus Mode (`--focus=[category]`)
Deep dive on a single category:
- `auth` - Authentication & authorization
- `injection` - All injection types (SQL, OS, XSS, etc.)
- `llm` - All LLM-specific checks
- `crypto` - Cryptographic issues
- `secrets` - Hardcoded credentials
- `deps` - Dependency vulnerabilities

## Workflow

```
1. SCOPE
   ├── Parse arguments (mode, focus, files)
   ├── Determine file set (diff, staged, repo, or specified)
   └── Identify languages/frameworks

2. DETECT (router.md)
   ├── Scan code for trigger patterns
   ├── Map patterns → check files
   └── Build check list

3. LOAD
   ├── Read only relevant checks/ files
   └── Skip irrelevant categories

4. ANALYZE
   ├── Run each check against scoped code
   ├── Identify anti-patterns
   └── Assess severity

5. REPORT
   ├── Group findings by category
   ├── Rank by severity (Critical > High > Medium > Low)
   ├── Include file:line references
   └── Provide fix suggestions
```

## Check Files

Located in `./checks/`:

| File | Category | Triggers |
|------|----------|----------|
| auth.md | Authentication & Access Control | login, session, jwt, role checks |
| injection.md | SQL, NoSQL, OS, XSS injection | queries, exec, innerHTML |
| crypto.md | Cryptographic failures | crypto imports, hashing |
| config.md | Security misconfiguration | env vars, CORS, headers |
| ssrf.md | Server-side request forgery | HTTP clients, URL building |
| secrets.md | Hardcoded credentials | api_key, password, tokens |
| deps.md | Vulnerable dependencies | package.json, requirements.txt |
| llm-injection.md | Prompt injection | LLM APIs, prompt building |
| llm-output.md | Insecure output handling | eval with LLM response |
| llm-agency.md | Excessive agent permissions | tool definitions, MCP |
| llm-data.md | Sensitive data in prompts | logging, PII in context |

## Severity Levels

**Critical**: Directly exploitable, immediate risk
- Auth bypass, RCE, SQL injection with data access

**High**: Exploitable with moderate effort
- IDOR, stored XSS, weak crypto on sensitive data

**Medium**: Requires specific conditions
- Reflected XSS, session issues, missing headers

**Low**: Defense-in-depth, best practice
- Verbose errors, missing secure cookie flags

## Output Format

```markdown
# OWASP Security Review

## Summary
- Files reviewed: X
- Checks run: [list]
- Findings: X critical, X high, X medium, X low

## Critical Findings

### [CATEGORY] Title
**File:** `path/to/file.py:42`
**Severity:** Critical
**Description:** What the vulnerability is
**Exploit:** How it could be exploited
**Fix:** How to remediate

## High Findings
...

## Recommendations
- Priority fixes
- Patterns to adopt
```

## Execution

1. Parse `$ARGUMENTS` for mode/focus/files
2. Run git status/diff to determine scope (unless --deep)
3. Read `router.md` and scan scope for triggers
4. For each triggered category, read `checks/{category}.md`
5. Analyze code against loaded check patterns
6. Generate report sorted by severity
7. If `--fix` flag: offer safe auto-remediation options

## Integration with Existing Tools

This skill complements `/brian:validation:security-review`:
- `security-review` = Fast PR check, false-positive filtering
- `owasp-review` = In-depth audit, educational, full patterns

Use `security-review` for CI/PR gates. Use `owasp-review` for:
- Pre-release audits
- Learning secure patterns
- Full repo health checks
- LLM/agent security validation
