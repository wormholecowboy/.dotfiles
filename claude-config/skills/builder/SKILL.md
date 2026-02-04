---
name: builder
description: Interactive planning facilitator for any task. Helps break down complex goals, identify dependencies, and create actionable plans. Use when starting a new project, feature, or complex task that needs structured thinking.
---

<!-- @builder-dep reads: //.claude/plans -->
<!-- @builder-dep provides: //.claude/skills/builder -->

# Builder Skill

Interactive planning for any task. Helps the user think through tasks systematically and create actionable plans with architecture review and implementation planning using subagents.

## Learnings File

**IMPORTANT:** Before planning, read `.claude/skills/builder/learnings.md` to surface relevant past learnings.

This file contains principles captured from real implementation experiences. Check it during:
- Stage 1 (PRD Creation) - to inform requirements and avoid known pitfalls
- Stage 3 (Implementation Planning) - to guide subagent usage and technical decisions

To add new learnings after implementation issues, use `/builder-learn`.

## Plans Directory

All plans are stored as folders at `.claude/plans/[name]/`. Each plan folder contains:

```
plans/[name]/
├── state.yaml              # Plan state tracking
├── main.md                 # PRD (all phases defined here)
├── adr.md                  # Architecture Decision Record
├── impl/                   # Implementation plans (one per phase)
│   ├── phase1-impl.md
│   └── phase2-impl.md
└── reviews/                # Review outputs
    ├── prd-review.md
    ├── task-phase1-task1-review.md
    └── final-summary.md
```

Completed plans can be archived to `.claude/plans/archive/`.

## Activation

When invoked via `/builder`:

1. Output: "Planning mode active."
2. List active plan folders from `.claude/plans/` (excluding archive/)
3. Ask what the user wants to plan, or if they want to continue an existing plan

---

## Planning Workflow (8 Stages)

### Stage 1: PRD Creation (Interactive, Main Thread)

**Goal:** Hash out all product requirements through conversation.

**Reference:** Follow `prd-guide.md` for the full process.

**Summary:**

1. **Check Learnings** - Read `learnings.md`, surface relevant past learnings
2. **Interview (Bidirectional)** - Ask questions, then state assumptions back for confirmation
3. **Write PRD** - Create `main.md` using the 16-section template in `prd-guide.md`
4. **Quality Check** - Run through checklist before proceeding
5. **Initialize ADR** - Create `adr.md` with initial technical decisions

### Stage 2: Architecture Review (Subagent)

**Goal:** Get expert review of PRD before implementation planning.

1. **Spawn architect-reviewer agent**
   - Prompt: "Review the PRD at [main.md]. Write findings to [reviews/prd-review.md]"
   - Agent writes review directly to `reviews/` folder

2. **Present findings** to user in main thread

3. **Interactive resolution** - Discuss issues, make decisions

4. **Update artifacts** - Modify PRD and ADR based on decisions

### Stage 3: Implementation Planning (Subagents)

**Goal:** Create detailed implementation plans for each phase.

**Reference:** Agents follow `impl-guide.md` for the full process.

**Summary:**

0. **Check Learnings** - Review `learnings.md` for subagent usage patterns and technical gotchas

1. **Spawn general-purpose agents** (one per phase, in parallel)
   - Prompt includes: PRD path, phase number, and instruction to follow `impl-guide.md`
   - Agent has write access, creates `impl/phaseN-impl.md` directly
   - **Important:** Use `general-purpose` agent (not `Plan`) because it can write files

2. **Agents execute the impl-guide.md process:**
   - Phase A: Codebase intelligence gathering (patterns, dependencies, integration points)
   - Phase B: External research (docs, gotchas, best practices)
   - Phase C: Strategic thinking (architecture fit, risks, design decisions)
   - Phase D: Write implementation plan with full context

3. **Quality Gates:**
   - Must pass quality criteria checklists in impl-guide.md
   - Must achieve 10/10 confidence score (or escalate gaps)
   - Must pass "No Prior Knowledge Test" - plan is self-contained

4. **Report back** when all agents complete

### Stage 3b: Cross-Plan Alignment Check (Subagent)

**Goal:** Verify all implementation plans work together before architect review.

**Why this matters:** Each phase plan is created in isolation. When Phase 2 expects to call a function from Phase 1, we need to verify Phase 1 actually creates that function with the expected signature.

1. **Spawn alignment-checker agent** (reads ALL impl plans together)
   - Agent reads all `impl/phaseN-impl.md` files in one context
   - Scans for cross-plan dependencies and validates alignment

2. **Check for misalignments:**
   - **Wrong signatures** - Function/method called with different args than defined
   - **Missing exports** - Code expects to import something not exported
   - **Missing functions** - Code calls a function that no plan creates
   - **Type mismatches** - Return types don't match expected usage
   - **Naming inconsistencies** - Same concept with different names across plans
   - **Order dependencies** - Phase N uses something Phase N+1 creates

3. **Write alignment report** to `reviews/alignment-check.md`
   - List each misalignment with: source plan, target plan, issue, suggested fix
   - Categorize as BLOCKING (must fix) or WARNING (should fix)

4. **Fix misalignments** before proceeding
   - Update impl plans to resolve BLOCKING issues
   - Document WARNINGs for architect review

5. **Proceed to Stage 4** only when no BLOCKING misalignments remain

### Stage 4: Implementation Review (Subagents)

**Goal:** Final validation before build.

1. **Spawn architect-reviewer agents** (one per impl plan, in parallel)
   - Review implementation plans for gaps, risks, inconsistencies
   - Check confidence score and escalation notes
   - **Review alignment report** for any WARNINGs

2. **Surface concerns** to user
   - **Escalate to user** if architect cannot resolve escalation notes
   - **Escalate to user** if confidence cannot reach 10/10

3. **Update impl plans** if needed - iterate until 10/10 confidence

### Stage 5: Ready for Build

**Goal:** Plan is fully validated and ready to build.

1. **Update state** to `ready`
2. **Document clear next steps**
3. **Ready for Stage 6 build**

### Stage 6: Build (Task-by-Task, Isolated Context)

**Goal:** Implement the plan task by task, with validation and review after each.

**Why Task Isolation:** Each task runs in its own context window (Ralph pattern). Fresh context prevents hallucination accumulation. State lives in files, not context.

> **CRITICAL: Reviews are AUTOMATIC.** After implementation agents complete, Claude MUST immediately spawn code-reviewer and security-reviewer agents without waiting for user prompt. This entire loop is a single unit of work - the user should only need to say "build phase X" and everything from implementation through commit happens automatically.

**Parallel Task Execution:** When multiple tasks in a phase have no dependencies on each other (all `blockedBy` satisfied), they CAN be implemented in parallel by spawning multiple task-builder agents simultaneously. However, the review→fix→commit cycle for each task should complete before marking the task done. The pattern is:
1. Spawn N implementation agents in parallel (for independent tasks)
2. When each completes, IMMEDIATELY spawn code-reviewer + security-reviewer in parallel for that task
3. Apply fixes, re-validate, commit
4. Move to next batch of eligible tasks

**Build Loop (per task):**

```
For each phase:
  For each task (respecting dependencies):
    1. Check dependencies satisfied
    2. Spawn task-builder agent (isolated context)
    3. Agent implements task
    4. Run task validation commands
    5. AUTOMATICALLY spawn code-reviewer agent (no user prompt)
    6. AUTOMATICALLY apply review fixes if CRITICAL/IMPORTANT found
    7. Re-validate after fixes
    8. AUTOMATICALLY spawn security-reviewer agent (no user prompt)
    9. Fix security issues if needed, re-validate
    10. AUTOMATICALLY spawn test-runner agent (full test suite)
    11. If tests fail: block commit, escalate
    12. Update state.yaml
    13. Commit changes
    14. Agent exits (context discarded)

  After all tasks in phase:
    15. Run phase validation commands
    16. Provide Phase Completion Report
    17. Update state to phase-complete
```

**Detailed Steps:**

1. **Check Dependencies**
   - Read state.yaml for task status
   - If any `blockedBy` tasks are not `complete`, skip to next eligible task
   - If no eligible tasks, phase is blocked (escalate)

2. **Spawn task-builder agent** (Sonnet, isolated context)
   - Pass: impl plan path + specific task ID
   - Agent reads plan, builds ONLY that task
   - Agent has no memory of previous tasks (fresh context)

3. **Run Task Validation**
   - Run validation commands from task definition
   - **Each task should create its own unit test** (unbiased verification)
   - ALL must pass for task to be complete
   - If validation fails: task stays `in_progress`, escalate

4. **Run Code Review** (AUTOMATICALLY, per task, not per phase)
   - AUTOMATICALLY spawn code-reviewer agent for uncommitted changes (no user prompt)
   - Review for: quality, security, performance, maintainability
   - Findings written to `reviews/task-[id]-review.md`
   - Categorizes issues as CRITICAL / IMPORTANT / SUGGESTION

5. **Apply Review Fixes**
   - If CRITICAL or IMPORTANT findings exist, spawn general-purpose fixer agent
   - Agent reads review file and applies fixes for:
     - All CRITICAL issues (required before commit)
     - All IMPORTANT issues (if straightforward)
     - SUGGESTION items noted but not fixed unless trivial
   - If a fix requires architectural changes or is unclear:
     - Do NOT attempt the fix
     - Add to `reviews/task-[id]-review.md`: `Deferred: [issue] - requires human decision`
     - Set `escalated: true` in state.yaml for the task
   - After fixes complete, proceed to re-validation

6. **Re-Validate After Fixes**
   - Run task validation commands again
   - Ensures fixes didn't break anything
   - If validation fails: escalate to developer, do not commit

7. **Run Security Review** (AUTOMATICALLY spawn security-reviewer agent)
   - AUTOMATICALLY spawn security-reviewer agent for uncommitted changes (no user prompt)
   - Agent reviews for HIGH-CONFIDENCE security vulnerabilities
   - Findings written to `reviews/task-[id]-security.md`
   - If CRITICAL security issues found:
     - Attempt fix via fixer agent (same pattern as code review fixes)
     - If fix unclear or risky: escalate to developer, set `escalated: true`
     - Re-run validation after security fixes
   - Security review must pass before commit (no unresolved CRITICAL issues)

8. **Run Full Test Suite** (AUTOMATICALLY spawn test-runner agent)
   - AUTOMATICALLY spawn test-runner agent to run ALL tests (full regression check)
   - Agent auto-detects test framework (pytest, jest, vitest)
   - Runs complete test suite, not just tests for changed files
   - If tests fail:
     - Do NOT attempt to fix (tests are the source of truth)
     - Block commit immediately
     - Set `escalated: true` in state.yaml
     - Report failing tests for developer review
   - Test suite must pass before commit (no failing tests)
   - **If fixes are applied after test failure** (by developer or fixer agent):
     - Re-run security review (any code change after security review requires re-scan)
     - Re-run test suite
     - Loop until both pass or escalate

9. **Update state.yaml**
   ```yaml
   tasks:
     phase1-task1:
       status: complete  # pending | in_progress | complete | blocked
       validation: passed
       reviewed: true
       security_reviewed: true  # security review passed
       tests_passed: true       # full test suite passed
       escalated: false  # true if issues deferred to developer
       commit: abc1234
   ```

10. **Commit changes**
    - Create commit: `feat(<project>): [task description]`
    - Record hash in state.yaml
    - Push if configured

11. **Phase Validation** (after all tasks in phase complete)
    - Run phase validation commands
    - Verify integrated behavior
    - Update phase status in state.yaml

12. **Phase Completion Report** (after each phase)
    Provide a brief (3-5 line) summary:
    - Number of tasks completed
    - Code review: X issues found/fixed (list HIGH severity only by name)
    - Security review: X issues found/fixed (or "No issues")
    - Any escalated items requiring attention

    Example: "Phase 3 complete (3 tasks). Code review: 1 HIGH fixed (hardcoded ID → useId hook). Security: No issues. Ready to commit."

13. **Update state** to `building-complete` when all phases pass

### Stage 7: Final Review & Aggregation

**Goal:** Aggregate all task reviews, verify completeness, surface any systemic issues.

> Note: Individual code reviews happen per-task in Stage 6. This stage aggregates and does final verification.

1. **Aggregate task reviews**
   - Collect all `reviews/task-*-review.md` files
   - Categorize findings: Critical / Important / Suggestion
   - Identify patterns across tasks (repeated issues = systemic problem)

2. **Verify all tasks complete**
   - Check state.yaml: all tasks `status: complete`
   - Check state.yaml: all tasks `reviewed: true`
   - Check state.yaml: all tasks `security_reviewed: true`
   - Check state.yaml: all tasks `tests_passed: true`
   - Check state.yaml: all tasks `validation: passed`
   - Note any tasks with `escalated: true` (deferred issues need human review)

3. **Final integration review** (optional, for complex projects)
   - Spawn architect-reviewer for cross-cutting concerns
   - Review: Does the whole hang together? Any architectural drift?

4. **Surface findings to user**
   - Summary of all issues found during build
   - **Escalated items requiring human decision** (from deferred fixes)
   - Any patterns that suggest process improvements
   - Recommendations for future phases

5. **Update state** to `complete` when verified

### Stage 8: Post-Implementation

**Goal:** Ensure decisions travel with the code.

1. **Copy ADR** to project folder (e.g., `/apps/myproject/docs/adr.md`)
2. **Plan folder remains** in `plans/` as historical record
3. **Optionally archive** the plan folder

---

## State File (state.yaml)

Tracks plan progress and artifacts:

```yaml
name: plan-name
created: 2026-01-17
current_stage: prd  # prd | arch-review | impl-planning | impl-review | ready | building | final-review | complete
completed_steps:
  - prd_drafted
  - arch_review_complete
open_questions:
  - "Question still to resolve"
decisions:
  - date: 2026-01-17
    decision: "Use SQLite for storage"
    rationale: "Simplicity, local-first"
assumptions:
  - assumption: "Using existing auth system"
    validated: false
  - assumption: "SQLite sufficient for scale"
    validated: true

# Task-level tracking (updated after each task completes)
tasks:
  phase1-task1:
    status: complete      # pending | in_progress | complete | blocked
    blockedBy: []         # task IDs that must complete first
    validation: passed    # passed | failed | pending
    reviewed: true        # code review passed
    security_reviewed: true  # security review passed
    tests_passed: true    # full test suite passed
    escalated: false      # true if issues deferred to developer
    commit: abc1234       # git commit hash
  phase1-task2:
    status: complete
    blockedBy: [phase1-task1]
    validation: passed
    reviewed: true
    security_reviewed: true
    tests_passed: true
    escalated: false
    commit: def5678
  phase2-task1:
    status: in_progress
    blockedBy: [phase1-task2]
    validation: pending
    reviewed: false
    security_reviewed: false
    tests_passed: false
    escalated: false
    commit: null

# Phase-level tracking
phases:
  phase1:
    status: complete      # pending | in_progress | complete
    validation: passed    # phase-level validation result
  phase2:
    status: in_progress
    validation: pending

artifacts:
  prd: main.md
  adr: adr.md
  impl_plans:
    - impl/phase1-impl.md
    - impl/phase2-impl.md
  reviews:
    - reviews/prd-review.md
    - reviews/impl-review-phase1.md
    - reviews/task-phase1-task1-review.md
    - reviews/task-phase1-task2-review.md
target_project_path: null  # Set when ready to implement (e.g., /apps/myproject)
```

---

## Architecture Decision Record (adr.md)

Captures all significant decisions during planning:

```markdown
# Architecture Decision Record: [Project Name]

## Overview
Brief description of the project and its purpose.

## Decisions

### [Date] - [Decision Title]
**Context:** Why this decision was needed
**Decision:** What was decided
**Rationale:** Why this choice over alternatives
**Consequences:** What this enables/constrains

### [Date] - [Another Decision]
...

## Open Questions
Questions deferred or still being investigated.

## References
Links to PRDs, reviews, external docs.
```

**When to update:**
- After PRD creation (initial decisions)
- After architect review (decisions from review)
- After implementation review (any changes)

**When implementation completes:**
- Copy `adr.md` to target project folder
- This ensures decisions stay with the code they affect

---

## Commands

| Command | Action |
|---------|--------|
| `*help` | Show all available commands |
| `*new [name]` | Create new plan folder with state.yaml, main.md template, and adr.md |
| `*status` | Show current stage, task progress, and any blocked tasks from state.yaml |
| `*review` | Spawn architect-reviewer agent(s) for current PRDs |
| `*impl` | Spawn general-purpose agent(s) to create implementation plans |
| `*align` | Spawn alignment-checker to verify cross-plan consistency (Stage 3b) |
| `*review-impl` | Spawn architect-reviewer agent(s) for implementation plans |
| `*build [task-id]` | Build a specific task (spawn task-builder, validate, review, commit) |
| `*build-next` | Build the next eligible task (unblocked, pending) |
| `*build-phase [N]` | Build all tasks in phase N sequentially |
| `*ralph [mode] [max]` | Run automated Ralph loop (see ralph-exec.sh) |
| `*aggregate` | Run Stage 7 aggregation and final review |
| `*finalize [path]` | Copy ADR to project folder, mark plan complete |
| `*save` | Save current state (update state.yaml) |
| `*partial [name]` | Save incomplete plan with context for easy resumption |
| `*one` | Toggle one-question-at-a-time mode (for low-energy sessions) |
| `*check` | Validate PRD against quality checklist before Stage 2 |
| `*deps` | Show task dependency graph |

### `*new [name]` Workflow

Create a new plan folder:

1. **Create folder** - `.claude/plans/[name]/`
2. **Initialize files:**
   ```
   plans/[name]/
   ├── state.yaml    # Initialized with name, created date, stage: prd
   ├── main.md       # PRD template from prd-guide.md
   └── adr.md        # Empty ADR template
   ```
3. **Create subfolders:**
   - `impl/` - For implementation plans
   - `reviews/` - For review outputs
4. **Report** - "Created plan folder: plans/[name]/"

### `*build [task-id]` Workflow

Build a single task in isolated context:

1. **Check dependencies** - Verify all `blockedBy` tasks are `complete`
2. **Update state** - Set task to `in_progress`
3. **Spawn task-builder** - Isolated context, implements only this task
4. **Run task validation** - Run task's validation commands
5. **AUTOMATICALLY run code review** - Spawn code-reviewer for uncommitted changes (no user prompt)
6. **Fix review findings** - If CRITICAL/IMPORTANT issues, spawn fixer agent
7. **Re-validate** - Run validation again after fixes
8. **AUTOMATICALLY run security review** - Spawn security-reviewer for uncommitted changes (no user prompt)
9. **Fix security findings** - If CRITICAL security issues, spawn fixer or escalate
10. **AUTOMATICALLY run full test suite** - Spawn test-runner agent (no user prompt)
11. **If tests fail** - Block commit, escalate, do not attempt fix
12. **Commit & update state** - Record commit hash, set `complete`, `reviewed: true`, `security_reviewed: true`, `tests_passed: true`, `escalated: <bool>`
13. **Report** - Show task completion status, note any deferred/escalated items

### `*build-next` Workflow

Find and build the next eligible task:

1. **Read state.yaml** - Find tasks where:
   - `status: pending`
   - All `blockedBy` tasks are `complete`
2. **If none eligible** - Report blocked state (which tasks are blocking)
3. **If eligible found** - Run `*build [task-id]` for first eligible

### `*deps` Workflow

Display the task dependency graph:

```
Phase 1:
  [x] phase1-task1 (complete)
  [x] phase1-task2 (complete) ← depends on: phase1-task1
  [ ] phase1-task3 (pending) ← depends on: phase1-task2

Phase 2:
  [~] phase2-task1 (blocked) ← depends on: phase1-task3
  [ ] phase2-task2 (pending) ← depends on: phase2-task1
```

### `*ralph` Workflow (Automated Loop)

Run the Ralph build loop via `ralph-exec.sh`:

```bash
# From skill directory
./ralph-exec.sh <plan-dir> [mode] [max-iterations]

# Examples
./ralph-exec.sh .claude/plans/my-feature
./ralph-exec.sh plans/my-feature implementation 20
./ralph-exec.sh plans/spike exploration 10
```

**Modes:**
- `implementation` (default) - High planning, watch closely, stop if off track
- `exploration` - Low planning, walk away, for research/MVPs
- `brute-force` - Testing mode, run overnight in sandbox

**Output signals the script watches for:**
- `RALPH_COMPLETE` - All tasks done, loop exits successfully
- `RALPH_BLOCKED` - Tasks exist but dependencies not met
- `RALPH_TASK_COMPLETE <id>` - One task finished
- `RALPH_TASK_FAILED <id>` - Task validation failed

**Safety features:**
- Max iterations limit (default 50)
- Stops after 3 consecutive failures
- 2-second delay between iterations (rate limiting)

**For Docker builds** (recommended for unattended runs):
```bash
docker run --rm -it \
  -v "$(pwd):/workspace" \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  docker/sandbox-templates:claude-code \
  /workspace/.claude/skills/builder/ralph-exec.sh /workspace/plans/my-feature
```

---

## Subagent Usage Patterns

### For PRD Review (Stage 2)

```
Spawn architect-reviewer agent:
- Prompt: "Review the PRD at [plan-folder/main.md]. Write your findings to [plan-folder/reviews/prd-review.md].
  Focus on: architectural risks, missing requirements, scalability concerns, and implementation gaps."
```

### For Implementation Planning (Stage 3)

```
Spawn general-purpose agent (one per phase, in parallel):
- Prompt: "Create a detailed implementation plan for Phase N from [plan-folder/main.md].
  Write the plan to [plan-folder/impl/phaseN-impl.md].

  Include:
  - Task breakdown with unique IDs (e.g., phase1-task1)
  - Dependencies between tasks (blockedBy field)
  - Validation commands for each task
  - Phase-level validation commands
  - Risk areas and testing strategy

  End with a Confidence Score (N/10). If score < 10/10:
  1. Ask yourself: 'What would make this 10/10?'
  2. Address the gaps if you can, OR
  3. Add an '## Escalation Notes' section listing unresolved concerns for architect review."
- IMPORTANT: Use general-purpose agent, not Plan agent (Plan cannot write files)
```

### For Cross-Plan Alignment Check (Stage 3b)

```
Spawn general-purpose agent (single agent reads ALL impl plans):
- Prompt: "Check cross-plan alignment for all implementation plans in [plan-folder/impl/].

  Read ALL phaseN-impl.md files together. Look for misalignments between plans:

  **Check for:**
  1. **Wrong signatures** - Function/method called with args different than defined
     - Example: Phase 2 calls `create_user(name, email)` but Phase 1 defines `create_user(user_data: dict)`
  2. **Missing exports** - Code expects to import something not exported
     - Example: Phase 3 imports `UserService` from Phase 1, but Phase 1 doesn't export it
  3. **Missing functions** - Code calls a function no plan creates
     - Example: Phase 2 calls `validate_input()` but no phase defines it
  4. **Type mismatches** - Return types don't match expected usage
     - Example: Phase 1 returns `User | None`, Phase 2 assumes `User` without null check
  5. **Naming inconsistencies** - Same concept with different names
     - Example: Phase 1 uses `user_id`, Phase 2 uses `userId`, Phase 3 uses `uid`
  6. **Order dependencies** - Phase N uses something Phase N+1 creates
     - Example: Phase 2 imports from a module Phase 3 creates

  Write findings to [plan-folder/reviews/alignment-check.md] with format:

  ## Alignment Check Results

  ### BLOCKING (must fix before build)
  - [Issue]: Phase X expects Y but Phase Z provides W
    - Source: phaseX-impl.md, Task X.N
    - Target: phaseZ-impl.md, Task Z.M
    - Fix: [specific fix]

  ### WARNING (review with architect)
  - [Issue]: ...

  ### OK
  - Cross-plan function calls: X checked, all aligned
  - Shared types: Y checked, all consistent

  If BLOCKING issues found, list specific fixes needed.
  If no issues found, write 'All plans aligned. Ready for architect review.'"
- IMPORTANT: Single agent must read ALL plans together (not parallel agents)
- Run AFTER all impl plans created, BEFORE architect review
```

### For Implementation Review (Stage 4)

```
Spawn architect-reviewer agent (one per impl plan, in parallel):
- Prompt: "Review the implementation plan at [plan-folder/impl/phaseN-impl.md].
  Write findings to [plan-folder/reviews/impl-review-phaseN.md].

  Focus on:
  - Task IDs and dependencies are correct
  - Validation commands are specific and complete
  - Consistency with PRD
  - Technical feasibility
  - Missing edge cases

  Check the Confidence Score and Escalation Notes section.
  If you cannot resolve escalation notes or cannot get confidence to 10/10,
  flag for escalation to user in your review."
```

### For Task Build (Stage 6)

```
Spawn task-builder agent (SEQUENTIALLY, one task at a time):
- Prompt: "Build task [task-id] from the implementation plan at [impl/phaseN-impl.md].

  Read the full plan for context, then implement ONLY task [task-id].

  After implementation, run these validation commands:
  [paste task's validation commands here]

  Report results:
  - Files created/modified
  - Validation output (pass/fail for each command)
  - Any blockers or concerns

  If validation fails or you encounter blockers, report and exit (do not continue)."
- Model: Sonnet (pinned for cost efficiency)
- One agent per task (isolated context window)
- Wait for completion before spawning code review
```

### For Task Code Review (Stage 6)

```
Spawn code-reviewer agent (after each task):
- Prompt: "Review the uncommitted changes for task [task-id].

  Use `git diff` to see changes (not yet committed).

  Write findings to [plan-folder/reviews/task-[task-id]-review.md].

  Focus on:
  - Code quality and readability
  - Security vulnerabilities (OWASP top 10)
  - Performance issues
  - Maintainability

  Categorize findings as CRITICAL / IMPORTANT / SUGGESTION.

  If CRITICAL issues found, they must be fixed before commit."
- Run after task validation passes
- Must complete before commit
```

### For Code Review Fixes (Stage 6)

```
Spawn general-purpose agent (if code review has CRITICAL or IMPORTANT findings):
- Prompt: "Fix the code review findings for task [task-id].

  Read the review at [plan-folder/reviews/task-[task-id]-review.md].

  Fix all CRITICAL issues (required before commit).
  Fix IMPORTANT issues if straightforward.
  Note SUGGESTION items but don't fix unless trivial.

  After fixing:
  1. Re-run the task's validation commands to ensure nothing broke
  2. Report what was fixed and what was deferred

  If a fix requires architectural changes or is unclear, do NOT attempt it.
  Instead:
  - Add to review file: 'Deferred: [issue] - requires human decision'
  - Report that escalated should be set to true in state.yaml"
- Run only if review contains CRITICAL or IMPORTANT findings
- Re-run validation after fixes
- Report deferred items for human review
- If any items deferred: set escalated: true in state.yaml for this task
```

### For Security Review (Stage 6)

```
Spawn security-reviewer agent (after code review fixes applied):
- Prompt: "Review the uncommitted changes for task [task-id] for security vulnerabilities.

  Use `git diff` to see changes (not yet committed).

  Write findings to [plan-folder/reviews/task-[task-id]-security.md].

  Focus on HIGH-CONFIDENCE security vulnerabilities:
  - Injection flaws (SQL, command, XSS)
  - Authentication/authorization issues
  - Sensitive data exposure
  - Security misconfiguration
  - Known vulnerable dependencies

  Categorize findings as CRITICAL / IMPORTANT / INFO.

  CRITICAL = must fix before commit (exploitable vulnerability)
  IMPORTANT = should fix (security weakness)
  INFO = noted for awareness (hardening opportunity)"
- Run after code review fixes are applied
- Must complete before commit
- CRITICAL issues block commit until resolved or escalated
```

### For Security Fix (Stage 6)

```
Spawn general-purpose agent (if security review has CRITICAL findings):
- Prompt: "Fix the CRITICAL security findings for task [task-id].

  Read the security review at [plan-folder/reviews/task-[task-id]-security.md].

  Fix all CRITICAL issues. These are exploitable vulnerabilities that must not ship.

  For each fix:
  - Apply the minimal change needed to resolve the vulnerability
  - Do NOT refactor or change unrelated code
  - Add a comment if the fix is non-obvious

  After fixing:
  1. Re-run the task's validation commands
  2. Report what was fixed

  If a fix is unclear, risky, or requires architectural changes:
  - Do NOT attempt it
  - Add to security review file: 'Escalated: [issue] - requires human decision'
  - Report that escalated should be set to true in state.yaml"
- Run only if security review contains CRITICAL findings
- Re-run validation after fixes
- If any items escalated: set escalated: true in state.yaml
```

### For Full Test Suite (Stage 6)

```
Spawn test-runner agent (AUTOMATICALLY, after security review/fixes):
- Prompt: "Run the full test suite to catch any regressions for task [task-id].

  Working directory: [repo root]

  Auto-detect test framework(s) and run ALL tests:
  - Python: pytest (via uv run pytest or .venv/bin/pytest)
  - JavaScript/TypeScript: jest or vitest (via npm test)

  Report results in structured format:
  - Framework detected
  - PASSED or FAILED status
  - Summary: X passed, Y failed, Z skipped
  - List of failing tests with error messages (if any)

  Return TESTS_PASSED or TESTS_FAILED signal."
- AUTOMATICALLY spawn after security review/fixes (no user prompt)
- If tests fail: do NOT attempt fix, block commit, set escalated: true
- Test suite must pass before commit
```

### For Phase Validation (Stage 6)

```
After all tasks in a phase complete:
- Run phase validation commands from impl plan
- Verify integrated behavior works as expected
- Update phase status in state.yaml
```

### For Final Review & Aggregation (Stage 7)

```
Spawn general-purpose agent for aggregation:
- Prompt: "Aggregate all task reviews from [plan-folder/reviews/].

  Include both code reviews (task-*-review.md) and security reviews (task-*-security.md).

  Create a summary at [plan-folder/reviews/final-summary.md] that includes:
  1. Total tasks reviewed
  2. Code review issues by severity (Critical/Important/Suggestion)
  3. Security issues by severity (Critical/Important/Info)
  4. Patterns observed (repeated issues across tasks)
  5. **Escalated items** - List all deferred issues requiring human decision
  6. Recommendations for future work

  Also verify in state.yaml:
  - All tasks have status: complete
  - All tasks have reviewed: true
  - All tasks have security_reviewed: true
  - All tasks have validation: passed
  - List any tasks with escalated: true

  Report any discrepancies."
```

### For Cross-Cutting Architecture Review (Stage 7, optional)

```
Spawn architect-reviewer agent (for complex projects):
- Prompt: "Review the complete implementation across all phases.

  Read all commits since plan started: git log --oneline [start-hash]..HEAD

  Check for:
  - Architectural consistency across phases
  - Patterns that diverged from plan
  - Technical debt accumulated
  - Integration points working correctly

  Write findings to [plan-folder/reviews/architecture-review.md]."
```

---

## PRD Template & Quality Checklist

See `prd-guide.md` for:
- Complete 16-section PRD template
- Interview questions and discovery process
- Quality checklist before Stage 2
- Style guidelines

Run `*check` to validate PRD completeness before proceeding.

---

## Implementation Plan Template & Quality Checklist

See `impl-guide.md` for:
- Complete implementation plan template
- Codebase intelligence gathering process
- External research process
- Strategic thinking checklist
- Task structure with PATTERN/IMPORTS/GOTCHA fields
- Validation commands by level
- Quality criteria checklists
- Success metrics (One-Pass, No Prior Knowledge Test)

---

## One-Question Mode

When the user runs `*one`, toggle a mode where:
- **On:** Ask only ONE question at a time, wait for answer, then ask next
- **Off:** Normal mode - can ask multiple questions together
- Confirm current state when toggled: "One-question mode: ON" or "One-question mode: OFF"

This is for low-energy planning sessions where simplicity matters.

---

## Build Modes

Three ways to run Stage 6 build, depending on planning intensity and risk tolerance:

### Implementation Mode (Default)

- High planning intensity required
- Watch first few iterations closely
- If loop goes off track: **stop, edit spec/impl plan, restart**
- Best for: real features, production code
- Use `*build-next` manually or with close monitoring

### Exploration Mode

- Minimal planning - brain dump into spec is acceptable
- Launch and walk away
- Best for: research, MVPs, feature spikes, back-burner projects
- Lower risk, lower quality expectations
- Good for consuming API tokens before reset

### Brute Force Testing Mode

- Give Claude access to test runner + browser (sandboxed)
- Let it systematically find bugs and edge cases
- Run overnight unattended
- Best for: security testing, UI regression, edge case discovery
- **Requires sandboxed environment** (Docker container)
- **UI testing:** Use `/agent-browser` skill for visual validation, screenshots, and interactive element testing

---

## Anti-Patterns to Avoid

- **Don't batch multiple tasks in one context** - One task per context window. Fresh context prevents hallucination accumulation. This is the core Ralph principle.
- **Don't run loops in same session** - Anthropic's Ralph plugin causes context rot by using Stop hooks within one session. Use isolated subagents (fresh context per task) instead.
- **Don't let spec+plan exceed ~50k tokens** - Even the initial load can hit the "dumb zone" (~100k tokens). Keep specs concise.
- **Don't skip task validation** - Every task must pass its validation commands before code review. Validation is backpressure that rejects invalid work.
- **Don't skip code review before commit** - Review catches issues when they're cheap to fix. Never commit unreviewed code.
- **Don't build blocked tasks** - Respect dependencies. If `blockedBy` tasks aren't complete, the task cannot run.
- **Don't include time estimates** - Implementation timelines are unpredictable. Focus on phases, dependencies, and scope instead.
- **Don't dump implementation details unless asked** - Keep explanations conceptual by default. Only provide code examples when explicitly requested.
- **Don't use Plan agent for file-writing tasks** - Plan agent is read-only. Use `general-purpose` agent when you need to write files (like implementation plans).
- **Don't let subagents output to main thread** - Subagents should write to files, not return large outputs that bloat main thread context.
- **Don't wait for user to trigger reviews** - Reviews (code + security + tests) are AUTOMATIC after implementation completes. The user says "build phase X" once, and implementation→validation→review→fix→commit all happen without additional prompts.
- **Don't skip full test suite before commit** - Tests are the source of truth for regressions. If tests fail, block and escalate - never commit with failing tests.
- **Don't skip re-scanning after fixes** - Any code change after security review requires re-running security review. If test failures lead to code fixes, re-run security → tests loop until both pass.

---

## Tone & Style

- **Excited collaborator** - Be genuinely enthusiastic about what we're building
- Always include 1-2 brief suggestions to make the plan better (keep these concise)
- Collaborative and exploratory
- Ask good questions
- Think systematically about dependencies
- Be pragmatic about scope and constraints
- Questions first, understand before planning
- Iterative refinement - plans evolve through conversation
- Always end with clear next steps
