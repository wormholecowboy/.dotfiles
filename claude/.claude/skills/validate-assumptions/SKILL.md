---
name: validate-assumptions
description: >
  Write throwaway test code to validate an assumption, run it via a sub-agent,
  report findings, then clean up. Code is scratch — never committed. Triggers:
  "validate this assumption", "test whether X is true", "/validate-assumptions",
  or when an unverified assumption blocks progress.
argument-hint: the assumption to test (optional; else inferred from context)
---

# Validate Assumptions

When progress depends on an uncertain assumption, don't guess — write minimal
throwaway code that proves/disproves it, run it, report what's true. Disposable
scratch, never committed.

`$ARGUMENTS` = the assumption. If empty, infer the most load-bearing unverified
one from the conversation and state it before proceeding.

## Workflow

1. **State it.** One falsifiable sentence: "Assumption: ___". If several are
   tangled, test the one blocking the most downstream work first.

2. **Resolve scratch dir (worktree-safe).** `PROJECT_ROOT=$(git rev-parse --show-toplevel)`;
   use `$PROJECT_ROOT/.scratch/assumptions/`. Never use `--git-common-dir` or
   follow `.git` refs. If paths show `.bare/` or `worktrees/`, STOP — re-resolve
   `PROJECT_ROOT`. Ask the user if unsure of the path/working dir.

3. **Write the minimal test.** Smallest script exercising ONLY the assumption —
   no helpers/abstractions/test framework (unless the assumption is about the
   framework). Name it descriptively, top comment `# scratch: <assumption> — safe to delete`.
   Use the project runtime/venv (`uv run`, `.venv/bin/python`, project node) —
   never system Python.

4. **Run via sub-agent** (`debugger` or `general-purpose`) to keep the run out of
   main context. Prompt MUST include: the assumption; script path + exact command
   (correct runtime); `"Stay within $PROJECT_ROOT. Do NOT traverse to parent dirs
   or other worktrees."`; run + capture output, fixing only trivial errors
   (typos, bad imports) — never expand scope; return verdict
   (confirmed/refuted/inconclusive), evidence (output), and final script if changed.

5. **Report.** Lead with **Confirmed / Refuted / Inconclusive**, show the relevant
   evidence, state what it means for the problem. If refuted, note the corrected
   understanding.

6. **Clean up.** Ask whether to delete or keep. On confirm, `rm` the script (and
   the dir if empty). Never `git add` scratch files.

One assumption per script — if a test reveals a new one, restate and repeat.
Keep it cheap: a fast yes/no, not a polished tool.
