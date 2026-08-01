---
name: mem
description: >
  Persistent memory at `.mem/` (git root). Triggers: `*um` (update), `*mr <topic>` (read by topic), `*op` (update repo operating instructions), `/mem` (resume; init from convo if missing), or "update/read memory".
---

# Memory System

Persistent file-based memory at `.mem/` (git root). Terse, machine-targeted.
Replaces the older `.state/` system.

## Files

- `.mem/long.md` — durable: goals, learnings, gotchas, arch. Slow churn.
- `.mem/YYYY-MM-DD.md` — daily: per-session work state.
- `.mem/<topic>.md` — standalone artifact: a substantive enumerated deliverable the session locked (spec, schema, numbered list, decision table). Full content, not fragments. Pointed to from daily/long.

## Artifacts (don't lossy-compress deliverables)

- When the session produces a concrete, agreed/"locked" enumerated artifact (numbered list, schema, spec, decision table), persist it IN FULL to `.mem/<topic>.md` **proactively** during `*um` and `/mem` init — do not compress it to a one-liner in the daily and do not wait to be asked.
- Daily/long get only a pointer: `[topic] <name> → .mem/<topic>.md`.
- Artifact files are exempt from the fragment-only style rule below — preserve enough to reconstruct the deliverable without re-deriving it.

## `long.md` format

```
## ops
1. [topic] instruction
- [topic] instruction
## goals
- [topic] item
## learnings
- [topic] item
## gotchas
- [topic] item
## arch
- [topic] item
```

Skip empty sections.

`## ops` = standing operating instructions for this repo/worktree — carry them
out EVERY session here, unprompted. Numbered when order matters, bullets when
not. Whenever `long.md` is loaded (`/mem`, `*mr`, or any read), apply ops
immediately as active instructions, not background context.

## Daily format

```
---
branch: <git branch>
focus: <one-line>
status: wip|blocked|done
---
## wip
- [topic] item
## next
- [topic] item
## qs
- [topic] question
## files
- /abs/path:line
## done
- [topic] item
```

Skip empty sections.

## Tags

Prefix entries `[topic]` (e.g. `[auth]`, `[db]`, `[ci]`, `[ui]`). Enables grep
retrieval across daily files. One entry, one primary tag.

## Delegation

Offload the file mechanics to the `mem-ops` subagent to keep the main
thread clean:

- `*mr` → delegate wholesale (READ mode). Pure retrieval; pass the topic,
  get back matched entries.
- `*um` → main thread decides WHAT to remember (fact + why + `[topic]`
  tags + status/focus). Hand that distilled payload to `mem-ops` (WRITE
  mode); it runs the procedure below. Never make the subagent infer
  memory from the conversation — it can't see it.
- `/mem` full resume → stays in the main thread (conversational, needs
  live context). Do NOT delegate.

## Triggers

### `*um` — update memory

Main thread distills the payload, then `mem-ops` (WRITE mode) executes:

1. `git rev-parse --show-toplevel` → `[root]`
2. `mkdir -p [root]/.mem` if missing
3. Today's daily: `[root]/.mem/$(date +%Y-%m-%d).md`
4. **Carry forward unresolved items.** If today's daily doesn't exist yet,
   find most recent prior daily (glob `????-??-??.md`, sort desc, skip today).
   Copy any unresolved `## qs` and `## wip` entries into today's file. These
   die only when explicitly resolved or dropped — never by date rolling over.
5. Read existing today's daily if present. Merge new info into sections — don't
   blindly append duplicates.
6. Update frontmatter `branch`, `focus`, `status` to current state.
7. Promote to `long.md` ONLY when item is globally durable: new learning,
   gotcha, goal change, arch decision. Never duplicate between daily and long.
8. Be ruthless on `## done`: drop completed items not worth remembering. Skip
   empty sections.
9. Tag every entry: `[topic] item`.
10. Confirm to user: file path written, what carried forward, what promoted to
    `long.md` (if anything).

### `*mr <topic>` — read memory by topic

Delegate to `mem-ops` (READ mode) with the topic; it runs:

1. Read `[root]/.mem/long.md` if present.
2. `grep -rn "\[<topic>\]" [root]/.mem/*.md` — load matching chunks only.
3. Present matched entries grouped by source file. Cheaper than full read.

### `*op` — update/create operating instructions

Main thread distills the instruction(s) — imperative, `[topic]`-tagged,
numbered if user implies order — then `mem-ops` (WRITE mode) executes:

1. `git rev-parse --show-toplevel` → `[root]`; `mkdir -p [root]/.mem` if missing.
2. Read `[root]/.mem/long.md` if present; create if not.
3. Merge into `## ops` (create section at TOP of long.md if missing):
   update/replace an existing instruction it supersedes rather than append a
   duplicate; preserve numbering order, renumber if inserting.
4. Confirm to user: final `## ops` content as written.

Ops live ONLY in long.md — never in dailies.

1. `git rev-parse --show-toplevel` → `[root]`
2. **If `[root]/.mem/` does not exist** — initialize from current conversation:
   a. `mkdir -p [root]/.mem`
   b. Write `long.md` populated from convo (goals/learnings/gotchas/arch).
      Skip empty sections. Tag every entry `[topic]`.
   c. Write `[root]/.mem/$(date +%Y-%m-%d).md` populated from convo, with
      frontmatter (`branch`, `focus`, `status`) and sections (wip/next/qs/
      files/done). Skip empty sections. Tag every entry `[topic]`.
   d. Confirm to user: paths written + one-line summary of what was captured.
3. **Else** — resume from existing memory:
   a. Read `[root]/.mem/long.md` if present.
   b. Find most recent daily: glob `[root]/.mem/????-??-??.md`, sort desc,
      pick top. Read it.
   c. If `long.md` has `## ops`: adopt as active standing instructions for the
      session and list them in the summary.
   d. Present terse summary: focus + status, open qs, next, wip, key files.
   e. Ask: "Resume on [top next item], or different focus?"
4. If user passed an argument, treat as additional context to scope the
   resume summary or seed the initial `focus`.

### `*ar` - create artifact

- Create an artifact file for what we are discussing and put reference in long.md for when it is needed

## Discovery

Older `.mem/YYYY-MM-DD.md` files loadable on demand when prior-day context
needed. Sort by filename desc. Don't auto-load all — only what's relevant.

## Style rules

- Entries are fragments not sentences.
- One bullet = one item. No prose paragraphs.
- File refs as absolute paths with line numbers: `/abs/path:line`.
- Drop articles, hedging, filler.
