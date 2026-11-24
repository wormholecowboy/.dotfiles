# 💻 Coding Assistant Guidelines

Check the cwd before file operations: several worktrees and branches of one repo are often open. Ask me if the right one is unclear.

## 1. Code Style & Workflow
- **Comments:** Only for non-obvious code. Use `# Reason:` for complex logic explaining *why*. No ticket/story numbers or conversation-specific labels (e.g. "Option B", "the new approach", "per our discussion") — keep comments generalized to the repo long-term.
- **Explicit Variable Naming** Prefer more explicit, descriptive variable names, if the variable represents something specific. 
- **Method Names** Avoid prepending with `_`.
- **Break long conditionals one branch/predicate per line** (all languages — SQL, JS, Python, Go, Terraform, ...): once a multi-branch conditional or multi-predicate boolean runs long (~100+ chars, or 3+ branches/predicates), split it — each `WHEN`/`ELSE`/`END`, `case`, `if`/`elif`/`else`, and each `AND`/`OR`/`&&`/`||` predicate on its own line, indented one level under its opener. Short ones stay inline — `isTrue ? runFunc() : otherThing()` is one line, not three. Applies equally to machine-generated SQL/config I check in (e.g. Presto view DDL dumps) — reformat before committing.
- Prefer guard clauses over deeply nested if/else

## 2. Refactors / Moving Code
- **Prefer `Edit` over `Write`** when relocating existing code. `Edit` preserves bytes exactly; `Write` retypes from memory and can introduce drift (extra blank lines, stripped whitespace, dropped lines).
- **Verify with `diff`** after moving blocks: compare the original range (`git show HEAD:path`) against the new location. `ast.parse` only proves syntax — it won't catch missing or altered lines.
- **Smoke-test imports** with a `python3 -c "from new.module import ..."` to catch broken refs that syntax checks miss.

## 3. Testing
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
`*um`=update memory (ernie skill where ernie is on, else mem skill)
`*mr <topic>`=read memory by topic (ernie skill where ernie is on, else mem skill)
`*op`=update/create repo operating instructions in long.md (ernie skill where ernie is on, else mem skill)
`*bu`=give me an answer in bullet points only
`*sub <task>`=delegate the task to the best-fit subagent (see Subagents section). Give the subagent the full context it needs, and tell it to return everything the main thread must keep.
`*one`=give me questions or problems one at a time
`*cap`=commit and push

## 5. Server/Process Startup

**Before starting any server:**
1. `lsof -i :PORT` - Check if running. Ask before killing.
2. Look for `requirements.txt` or `pyproject.toml` before installing deps.
3. Use project venv (`uv run`, `.venv/bin/python`), never system Python.
4. If venv broken, recreate it.

**Common ports:** 3000 (React), 5173 (Vite), 8000 (FastAPI), 8080 (generic)

**Anti-pattern:** Background processes that respawn and conflict. Track what you start.

## 6. Available Tools

### AWS CLI

Run `aws ...` directly. `AWS_PROFILE=saml` and `AWS_REGION` are set in settings `env`, and the CLI reads the credentials that `saml2aws` saves to `~/.aws/credentials`.

```bash
aws s3 ls
```

- Never run `awsl` or `saml2aws` yourself, and never wrap AWS calls in `zsh -ic`. Login prompts for a password and hangs a non-interactive shell.
- Sessions last 1h. On `ExpiredToken`, `Unable to locate credentials`, or `security token ... invalid`: stop, ask me to run `! awsl`, then retry once.

### MySQL (reporting data pond / public Aurora)

Use the 8.0 client — the default Homebrew `mysql` (9.x) lacks the `mysql_native_password` plugin these servers need.

The reporting data pond is the reporting database. Public / stagePublic still run but are being deprecated — default to the pond for reporting data; use public only for data not yet moved.

```bash
M=/opt/homebrew/opt/mysql-client@8.0/bin/mysql
$M --defaults-group-suffix=_reporting-data-pond-prod    -e "SELECT 1;"   # prod, read-only
$M --defaults-group-suffix=_reporting-data-pond-nonprod -e "SELECT 1;"   # nonprod, admin
$M --defaults-group-suffix=_public      -e "SELECT 1;"   # deprecated: prod, read-only
$M --defaults-group-suffix=_stagePublic -e "SELECT 1;"   # deprecated: stage, admin
```

- Host/user/db live in `~/.my.cnf`; passwords live in `~/.mylogin.cnf` (via `mysql_config_editor`, login-path = the full group name, e.g. `client_reporting-data-pond-prod`). Never print, decode, or copy the passwords.
- `reporting-data-pond-nonprod` and `stagePublic` use admin users — read-only queries unless I explicitly ask for writes.
- `_stageGeneral` / `_general` are not set up yet (placeholder creds, need an SSH tunnel).

### Other Tools

- **Atlassian MCP:** Use this for reading Jira tickets, Confluence docs, and Bitbuckets branches and PRs
- **Microsoft MCP:** Use this to read my emails and teams messages and cloud docs
- **Postman MCP:** Use this to update Postman routes
- **tfswitch CLI:** Use `tfswitch` to use another version of terrafom, if needed.

## 7. Memory

**Where ernie is on** (an `ernie ·` session header, or `ernie where` prints `state on`): memory lives at `.ernie/mem/<branch>/`, ernie writes it, and the SessionStart dump replaces `/mem`. See the `ernie` skill for the triggers.

**Elsewhere:** persistent context lives in `.mem/` at git root; in a non-git folder they live in `./.mem/`, except in a memory-only folder made by `mkmem <dir>`, where the files sit directly in the folder (keyed on `./long.md`). See `mem` skill for spec and triggers (`*um`, `*mr`, `/mem`).

**Old `.mem/` folders** move by hand when I next work there: I run `ernie init`, then `ernie mem import` and its `queue.md` table.

## 8. Communication Style

### Writing (ASD-STE100)

Write all prose in ASD-STE100 Simplified Technical English: replies, explanations, issue reports, questions, and the docs and memory you write. Exceptions: code, commands, quoted text, commit messages (conventional commits), and code comments (match the surrounding code).

- One idea per sentence: at most 20 words in an instruction, 25 in a description.
- Active voice, the actor first: "the hook stops the push", not "the push is stopped".
- An instruction starts with a verb: "Run …", "Select one option".
- Common words with one meaning; no idioms or loose verbs ("flip", "land", "skip", "mid-session").
- Keep "the", "a" and "this"; no stack of more than 3 nouns.
- Commands, flags, ids and paths stay exactly as written.
- One topic per paragraph, at most 6 sentences.

### General

- **Explanations:** Lead with one small, atomic, real example, traced through. Rates/mechanism after. Keep it short.
- Don't talk to me about deployment unless I ask or there is some problem

### Explaining issues

- **Open with a plain-language problem statement:** a few sentences anyone could follow cold (like `/tldr`): what goes wrong, in everyday words, and what I must do (or "nothing"). Never lead with a label (L3, M1) or jargon — I don't have them memorized.
- **Tag claims:** ✓ verified (cmd/query you ran) · ~ inferred · ✗ unchecked. No "root cause"/"fixed" without ✓.
- **Define labels on first use in each reply** (G0, H1, L3) in one line — coined now or pulled from memory/plans/reviews.
- **Impact per issue:** what breaks if skipped. Rank by it; say when something barely matters.
- **Purpose before options:** what it is and why it exists, then the choices.
- **Assumptions are questions:** "I assumed X = Y. True?" — never stated as fact.
- **Before/after:** 3–5 lines, not full diffs. Arrow chains ≤4 hops; longer → numbered steps.

### Output Style

- **Handles:** Give every item I might reply to a unique handle: questions `Q1`, `Q2`; issues, findings and options likewise. Handles run on across the reply and never repeat. Skip only when there is exactly one item. A priority label is not a handle — two questions can share `P2`.
- **Questions:** Label each question with a priority, so I can skip "barely matters" ones, and show the running count with the total as a denominator: `**Q1/8 (P1):** ...`.
- **Either/or questions:** number the choices, one per line, so I can reply with a number:
  ```
  1. Take them in that order
  2. Go straight to P2 (planning flow)
  ```

## 9. Important File Paths
- **Write home paths as `~/`**, never `/Users/<name>/`, in anything that persists (memory, docs, configs, scripts, commit messages). My username differs between machines (e.g. `briangildea` vs `brian.gildea`). Use the absolute form only where `~` won't expand (tool calls that require absolute paths, quoted strings in configs that don't expand it); use `$HOME` in scripts.
- `~/.dotfiles/` All my config files, many are git controlled. (neovim, tmux, zsh, zsh aliases, etc.)
- `~/things/myc/` All my code repos, including forks
- `~/things/scripts/` Various scripts, often tied to zsh or tmux commands

## Machines

A SessionStart hook prints `Machine hostname: <name>`. Find the name in this table to know which machine this session runs on. If the name is not in the table, ask me which machine it is.

| Hostname | Machine |
|---|---|
| `bmm.local` | Mac mini |
| `lvus-…` (TODO: confirm) | Work computer |
| `Brians-Laptop.local` | Laptop |
| `vultr` | Cloud machine |

## 10. Subagents

Delegate to a subagent when the work would flood my context with material I don't need to keep — broad searches, multi-file reads, research, reviews, debugging. I keep the conclusion, not the file dumps.

**Parallelize:** independent tasks go out in ONE message (multiple tool calls) so they run concurrently. Don't serialize what doesn't depend.

**Pick the right agent:** `Explore` for read-only search, `Plan` for strategy, `debugger`/`security-reviewer` for their domains. For a code review, run the native `/code-review` skill directly, not through a subagent: it starts its own reviewers. Only fall back to `general-purpose` when nothing fits.

**Return contract:** Tell the subagent exactly what to return, in what format, with `file:line` citations — its final message is the only thing that reaches my context, so vague prompts mean a re-run.

<!-- postman-cli:installation:start -->
Postman CLI is installed on this device, and can be used for API Engineering work.
<!-- postman-cli:installation:end -->

<!--# BEGIN SNYK GLOBAL RULE -->
# Project security best practices

- Always run snyk_code_scan tool for new first party code that is generated in a Snyk-supported language.
- If any security issues are found based on newly introduced or modified code or dependencies, attempt to fix the issues using the results context from Snyk.
- Rescan the code after fixing the issues to ensure that the issues were fixed and that there are no newly introduced issues.
- Repeat this process until no new issues are found.
<!--# END SNYK GLOBAL RULE -->
