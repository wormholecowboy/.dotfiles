# 💻 Coding Assistant Guidelines

CRITICAL: Always check the cwd when performing file operations. Make sure you are in the right worktree/branch. Ask the user if it is uncertain.

## 1. Code Style & Workflow
- **Stick to the stack:** When fixing issues, exhaust current tech and patterns before introducing new ones. Don't change stable architecture unless explicitly told.
- **Scoped changes:** Only modify code directly relevant to the request. Think through impacts on related code.
- **Comments:** Only for non-obvious code. Use `# Reason:` for complex logic explaining *why*. No ticket/story numbers or conversation-specific labels (e.g. "Option B", "the new approach", "per our discussion") — keep comments generalized to the repo long-term.
- **Safety:** Confirm paths/modules exist. Ask before overwriting `.env`. Only use verified packages.
- **Explicit Variable Naming** Prefer more explicit, descriptive variable names, if the variable represents something specific. 
- **Refactoring** If you need to refactor something, refactor and then stop for my review BEFORE continuing with feature add.
- **Method Names** Avoid prepending with `_`.
- **Break long conditionals one branch/predicate per line** (all languages — SQL, JS, Python, Go, Terraform, ...): once a multi-branch conditional or multi-predicate boolean runs long (~100+ chars, or 3+ branches/predicates), split it — each `WHEN`/`ELSE`/`END`, `case`, `if`/`elif`/`else`, and each `AND`/`OR`/`&&`/`||` predicate on its own line, indented one level under its opener. Short ones stay inline — `isTrue ? runFunc() : otherThing()` is one line, not three. Applies equally to machine-generated SQL/config I check in (e.g. Presto view DDL dumps) — reformat before committing.
- Prefer guard clauses over deeply nested if/else

## 2. Refactors / Moving Code
- **Prefer `Edit` over `Write`** when relocating existing code. `Edit` preserves bytes exactly; `Write` retypes from memory and can introduce drift (extra blank lines, stripped whitespace, dropped lines).
- **Verify with `diff`** after moving blocks: compare the original range (`git show HEAD:path`) against the new location. `ast.parse` only proves syntax — it won't catch missing or altered lines.
- **Smoke-test imports** with a `python3 -c "from new.module import ..."` to catch broken refs that syntax checks miss.

## 3. Testing
- ALWAYS ask if I want new tests before creating them.
- **Mocking/stubbing:** Only for tests. Never in dev/prod.
- **Coverage:** 1 expected case, 1 edge case, 1 failure case per function.
- **Maintenance:** Update tests when logic changes.
- **Mocks grow per-test, not per-plan:** Start with the minimum stub that lets `require`/import succeed. For each new test: write the assertion first, run it, then add only the mock surface the failure demands. No closure-state, configurators (`__configure`/`__reset`), captured-args helpers, or pagination-cursor mocks until a test fails for lack of them. First test inlines; second creates the abstraction.
- **Anti-pattern (plan-driven mock factory):** writing a large mock factory upfront from the test plan, then writing tests against it. Most surface goes unused.
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
`*op`=update/create repo operating instructions in long.md (mem skill)
`*bu`=give me an answer in bullet points only
`*sub <task>`=delegate the task to the best-fit subagent (see Subagents section). The subagent MUST be given full context to do the job effectively, and MUST return all relevant information so the main agent retains what it needs in its own context.

## 5. Server/Process Startup

**Before starting any server:**
1. `lsof -i :PORT` - Check if running. Ask before killing.
2. Look for `requirements.txt` or `pyproject.toml` before installing deps.
3. Use project venv (`uv run`, `.venv/bin/python`), never system Python.
4. If venv broken, recreate it.

**Common ports:** 3000 (React), 5173 (Vite), 8000 (FastAPI), 8080 (generic)

**Anti-pattern:** Background processes that respawn and conflict. Track what you start.

## 6. Available Tools

### Terraform Switch

Use `tfswitch` to use another version of terrafom, if needed.

### AWS CLI

Run `aws ...` directly. `AWS_PROFILE=saml` and `AWS_REGION` are set in settings `env`, and the CLI reads the credentials that `saml2aws` saves to `~/.aws/credentials`.

```bash
aws s3 ls
```

- Never run `awsl` or `saml2aws` yourself, and never wrap AWS calls in `zsh -ic`. Login prompts for a password and hangs a non-interactive shell.
- Sessions last 1h. On `ExpiredToken`, `Unable to locate credentials`, or `security token ... invalid`: stop, ask me to run `! awsl`, then retry once.

### MySQL (public / stagePublic Aurora)

Use the 8.0 client — the default Homebrew `mysql` (9.x) lacks the `mysql_native_password` plugin these servers need.

```bash
M=/opt/homebrew/opt/mysql-client@8.0/bin/mysql
$M --defaults-group-suffix=_public      -e "SELECT 1;"   # prod, user readonly, no default DB
$M --defaults-group-suffix=_stagePublic -e "SELECT 1;"   # stage, DB stagePublicDigmsDB
```

- Host/user/db live in `~/.my.cnf`; passwords live in `~/.mylogin.cnf` (via `mysql_config_editor`). Never print, decode, or copy the passwords.
- `stagePublic` uses an admin user — read-only queries unless I explicitly ask for writes.
- `_stageGeneral` / `_general` are not set up yet (placeholder creds, need an SSH tunnel).

## 7. Memory

Persistent context lives in `.mem/` at git root. See `mem` skill for spec and triggers (`*um`, `*mr`, `/mem`).

Route the file mechanics through the `mem-ops` subagent: `*mr` delegates wholesale (retrieval), `*um` delegates after I've distilled what to remember. `/mem` resume stays in the main thread.

## 8. Communication Style

- If I ask for an explanation, ALWAYS include a small, atomic example. Keep it short. 

### Output Style

- If you are asking me more than 3 questions at a time, break them up and keep track of which ones you asked me. Also, visually show me curr/total (example: Q3/5)

## 9. Important File Paths
- `~/.dotfiles/` All my config files, many are git controlled. (neovim, tmux, zsh, zsh aliases, etc.)
- `~/things/myc/` All my code repos, including forks
- `~/things/scripts/` Various scripts, often tied to zsh or tmux commands

## 10. Subagents

Delegate to a subagent when the work would flood my context with material I don't need to keep — broad searches, multi-file reads, research, reviews, debugging. I keep the conclusion, not the file dumps.

**When NOT to:** a subagent can't see my uncommitted context, can't ask me follow-ups, and adds latency. For a single lookup where I already know the file/symbol, or anything needing back-and-forth, do it inline.

**Parallelize:** independent tasks go out in ONE message (multiple tool calls) so they run concurrently. Don't serialize what doesn't depend.

**Pick the right agent:** `Explore` for read-only search, `Plan` for strategy, `debugger`/`code-reviewer`/`security-reviewer` for their domains. Only fall back to `general-purpose` when nothing fits.

**Return contract:** ALWAYS tell the subagent exactly what to return, in what format, with `file:line` citations — its final message is the only thing that reaches my context, so vague prompts mean a re-run.
