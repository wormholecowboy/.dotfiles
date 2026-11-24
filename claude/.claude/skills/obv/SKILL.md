---
name: obv
description: Quiet mode. Fix obvious problems without asking; surface only judgment calls, critical problems, and security risks. Use when the user runs /obv.
argument-hint: [extra context]
disable-model-invocation: true
---

# obv

Quiet mode is on for the rest of this session. Fix obvious problems yourself. Tell me only about the items under "Surface".

## Fix without asking
- Typos, formatting, lint and type errors.
- Missing imports, broken refs, or dead code that your own change caused.
- Tests that fail because of your change, when the intended behavior is clear.
- Small follow-ups the task clearly needs (e.g. update callers after a rename).

## Surface
- Judgment calls: two or more valid options with different trade-offs.
- Behavior changes I did not ask for: public API, schema, config defaults, user-visible output.
- Critical problems: data loss, broken build or deploy, wrong results that tests do not catch.
- Security risks: secrets, auth, injection, unsafe permissions.
- Actions that are hard to undo or leave this machine (push, publish, delete, send). The normal confirm rules still apply.

## When unsure
If the fix is small, easy to undo, and inside the task scope, do it. Otherwise, surface it in one line.

## Report
At the end of a task, add one line: `Fixed quietly: <n> (<short list>)`. Omit it when n = 0.

Extra context: $ARGUMENTS
