---
name: cr
description: Run the native /code-review skill for 1 or more rounds, each in a fresh general-purpose agent. Each round fixes obvious mistakes and collects judgment calls for the user.
argument-hint: "[count] [low|medium|high|xhigh|max] [#PR | branch | path] (defaults: 1, high, branch commits + uncommitted changes)"
disable-model-invocation: true
---

# cr

Arguments: `$ARGUMENTS`

## 1. Read the arguments

The arguments are all optional and can come in any order.

- **count** — a bare integer. Default: `1`.
- **effort** — `low`, `medium`, `high`, `xhigh` or `max`. Default: `high`.
- **target** — any other argument.
  - `#42` is PR 42. Send it to the skill as `42`.
  - Any other value is a branch or a path. Send it without changes.
  - No target: the skill reviews `@{upstream}...HEAD` (or `main...HEAD`) and also the uncommitted changes.

If you find more than one count, effort or target, stop and ask the user.

**Fix mode.** Fixes go into the current working tree. If the target is a PR or a branch that is not the current `HEAD`, run in review-only mode: the agent fixes nothing, and all findings go to the open concerns.

## 2. Run the rounds

Run the rounds one after the other. Start each round only after the previous round returns.

For each round, start a fresh `general-purpose` agent with the prompt in section 3. Give it:

- the round number and the count
- the effort and the target
- fix mode or review-only mode
- the open concerns from all previous rounds, as `file:line — summary`

Add the agent's concerns to the open concerns. Keep the list of fixes.

Stop early when a round returns `new_findings: 0`.

## 3. Agent prompt

> You are round {n} of {count} of a code review. Do not commit. Do not push.
>
> 1. Use the Skill tool to run `code-review` with the args `{effort} {target}`. Do not pass `--fix` or `--comment`. The skill runs as a background agent. Wait for its result before you continue.
> 2. Ignore each finding that matches an open concern below. Count the other findings as new.
> 3. Read the code at each new finding, and make sure the finding is real. Drop it if it is not.
> 4. {Fix mode only} Fix a new finding only if all of these statements are true:
>    - The fix changes only the lines near the finding.
>    - The fix does not change behavior that a caller, a user, or a test expects.
>    - Only one fix is reasonable.
>
>    After the fixes, run the tests or checks that cover the changed files, if they exist. Undo a fix that makes them fail, and report that finding as a concern.
> 5. Report all other new findings as concerns. Do not fix them.
>
> Open concerns from previous rounds:
> {open concerns, or "none"}
>
> Return only this:
>
> ```
> new_findings: <number of new findings after step 3>
> fixed:
>   - file:line — what was wrong — what you changed
> concerns:
>   - file:line — the problem — why it needs a human — the options
> dropped:
>   - file:line — why the finding is not real
> checks: <the commands you ran and their result, or "none">
> ```

## 4. Report to the user

After the last round, give the user:

1. The rounds that ran, and why they stopped (count reached, or a round found nothing new).
2. The fixes, as `file:line — change`, grouped by round.
3. The concerns. Give each one a handle (`C1`, `C2`, ...) and a priority, so the user can answer by handle.
4. The output of `git diff --stat`.

Do not commit the fixes.
