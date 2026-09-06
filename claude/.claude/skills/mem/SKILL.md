---
name: mem
description: >
  Persistent memory at `.mem/` (git root). Triggers: `*um` (update), `*mr <topic>` (read by topic), `*op` (update repo operating instructions), `*ar` (create artifact), `/mem` (resume; init from convo if missing), or "update/read memory".
---

# Memory System

Persistent file-based memory at `.mem/` (git root). Terse, machine-targeted.
Replaces the older `.state/` system.

## Layout

```
.mem/
  long.md              durable: ops/goals/learnings/gotchas/arch/reference. Slow churn.
  queue.md             standing backlog: next + qs. Single source of truth for open items.
  tags.md              tag index: one line per tag, one-line meaning.
  daily_mem/
    YYYY-MM-DD.md      per-session deltas: wip/files/done only.
  artifacts/
    plan_<topic>.md    a plan to execute; archive when executed
    spec_<topic>.md    decisions made that other work must conform to; keep current
    ref_<topic>.md     facts captured from the world; snapshot, may go stale
    archive/           superseded artifacts
```

**Legacy layout** (flat `????-??-??.md` dailies + topic files at `.mem/` root):
offer a one-time migration — dailies → `daily_mem/`, topic files → `artifacts/`
with prefix, extract `queue.md` from latest daily's next/qs, build `tags.md`,
rewrite pointers. Never silently mix layouts.

## Artifacts (don't lossy-compress deliverables)

- When the session produces a concrete, agreed/"locked" enumerated artifact
  (numbered list, schema, spec, decision table, plan), persist it IN FULL to
  `.mem/artifacts/<prefix>_<topic>.md` **proactively** during `*um` and `/mem`
  init — do not compress it to a one-liner in the daily and do not wait to be
  asked.
- Every artifact takes exactly one prefix: `plan_` / `spec_` / `ref_`. If
  nothing fits, it's `ref_`. No new prefixes until two real artifacts demand
  one.
- Daily/long/queue get only a pointer: `[topic] <name> → .mem/artifacts/<file>.md`.
- Artifact files are exempt from the fragment-only style rules below — preserve
  enough to reconstruct the deliverable without re-deriving it.
- **Drift rule:** when a locked artifact goes stale, update the artifact file
  itself — never log the drift as a learning or daily note.

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
## reference
- [topic] <name> → .mem/artifacts/<file>.md
```

Skip empty sections.

`## ops` = standing operating instructions for this repo/worktree — carry them
out EVERY session here, unprompted. Numbered when order matters, bullets when
not. Whenever `long.md` is loaded (`/mem`, `*mr`, or any read), apply ops
immediately as active instructions, not background context.

## `queue.md` format

```
---
updated: YYYY-MM-DD
---
## next
- [topic] item
## qs
- [topic] question (asked YYYY-MM-DD)
```

Single source of truth for open items — dailies NEVER carry next/qs. Items die
only when explicitly resolved or dropped, never by date rolling over.

**Resolution discipline:** when an item resolves (answered, shipped, dropped),
delete it from queue.md in the same pass — everywhere, same `*um`. If the
resolution is durable, add ONE compressed line to long.md (fact + commit/ref),
not the narrative. A resolved entry left in place is a bug.

## Daily format (`daily_mem/YYYY-MM-DD.md`)

```
---
branch: <git branch>
focus: <one-line>
blocked: <reason>
---
## wip
- [topic] item
## files
- /abs/path:line
## done
- [topic] item
```

Skip empty sections. `blocked` key present ONLY when blocked (absence = not
blocked); it must name the blocker.

## Tags

Prefix entries `[topic]` (e.g. `[auth]`, `[db]`, `[ci]`). One entry, one
primary tag. Enables grep retrieval across all files.

`tags.md` = controlled vocabulary, maintained mechanically by `*um`:

```
# tags
- [tag] one-line meaning
```

- Before minting a new tag, check tags.md — reuse if one fits; if minting, add
  it with a one-line meaning in the same pass.
- One tag per concern; split a tag when its entries stop answering the same
  question.
- Flat: no hierarchy, no counts — both rot.

## Delegation

Offload the file mechanics to the `mem-ops` subagent to keep the main
thread clean:

- `*mr` → delegate wholesale (READ mode). Pure retrieval; pass the topic,
  get back matched entries.
- `*um` → main thread decides WHAT to remember (fact + why + `[topic]`
  tags + focus + resolutions). Hand that distilled payload to `mem-ops`
  (WRITE mode); it runs the procedure below. Never make the subagent infer
  memory from the conversation — it can't see it.
- `/mem` full resume → stays in the main thread (conversational, needs
  live context). Do NOT delegate.

## Triggers

### `*um` — update memory

Main thread distills the payload, then `mem-ops` (WRITE mode) executes:

1. `git rev-parse --show-toplevel` → `[root]`
2. `mkdir -p [root]/.mem/daily_mem [root]/.mem/artifacts` if missing. If legacy
   layout detected, surface it — offer migration, don't mix.
3. Today's daily: `[root]/.mem/daily_mem/$(date +%Y-%m-%d).md`. Read if
   present; merge new wip/files/done — don't blindly append duplicates.
4. queue.md: merge new next/qs (new qs get `(asked YYYY-MM-DD)`); DELETE
   resolved items in the same pass (resolution discipline above); bump
   `updated`.
5. Update daily frontmatter `branch`, `focus`; set `blocked` only if blocked.
6. Promote to `long.md` ONLY when item is globally durable: new learning,
   gotcha, goal change, arch decision. Never duplicate between daily and long.
7. Be ruthless on `## done`: drop completed items not worth remembering. Skip
   empty sections.
8. Tag every entry `[topic]`: check tags.md, reuse or mint + index in the same
   pass.
9. Locked deliverables → full artifact file + pointer (see Artifacts).
10. Confirm to user: files written, queue delta (added/resolved), promotions to
    `long.md`, artifacts created (if any).

### `*mr <topic>` — read memory by topic

Delegate to `mem-ops` (READ mode) with the topic; it runs:

1. Read `[root]/.mem/tags.md` — resolve topic to the right tag(s).
2. Read `[root]/.mem/long.md` if present.
3. `grep -rn "\[<tag>\]" [root]/.mem/` — load matching chunks only (covers
   queue.md, dailies, artifact pointers).
4. Present matched entries grouped by source file. Cheaper than full read.

### `*op` — update/create operating instructions

Main thread distills the instruction(s) — imperative, `[topic]`-tagged,
numbered if user implies order — then `mem-ops` (WRITE mode) executes:

1. `git rev-parse --show-toplevel` → `[root]`; `mkdir -p [root]/.mem` if missing.
2. Read `[root]/.mem/long.md` if present; create if not.
3. Merge into `## ops` (create section at TOP of long.md if missing):
   update/replace an existing instruction it supersedes rather than append a
   duplicate; preserve numbering order, renumber if inserting.
4. Confirm to user: final `## ops` content as written.

Ops live ONLY in long.md — never in dailies or queue.

### `*ar` — create artifact

Create `.mem/artifacts/<prefix>_<topic>.md` (pick `plan_`/`spec_`/`ref_`; see
Artifacts) for what we are discussing; add pointer in long.md `## reference`.

### `/mem` — resume / init

1. `git rev-parse --show-toplevel` → `[root]`
2. **If `[root]/.mem/` does not exist** — initialize from current conversation:
   a. `mkdir -p [root]/.mem/daily_mem [root]/.mem/artifacts`
   b. Write `long.md` populated from convo (ops/goals/learnings/gotchas/arch).
      Skip empty sections. Tag every entry `[topic]`.
   c. Write `queue.md` (next/qs from convo) and `tags.md` (tags used).
   d. Write `daily_mem/$(date +%Y-%m-%d).md` with frontmatter (`branch`,
      `focus`) and sections (wip/files/done). Skip empty sections.
   e. Persist any locked deliverables as artifacts (see Artifacts).
   f. Confirm to user: paths written + one-line summary of what was captured.
3. **Else** — resume from existing memory:
   a. Read `[root]/.mem/long.md` and `[root]/.mem/queue.md` if present.
   b. Find most recent daily: glob `[root]/.mem/daily_mem/????-??-??.md`,
      sort desc, pick top. Read it. (Legacy layout: offer migration first.)
   c. If `long.md` has `## ops`: adopt as active standing instructions for the
      session and list them in the summary.
   d. Present terse summary: focus, blocked (if set), open qs w/ ages, top
      next items, wip, key files.
   e. Ask: "Resume on [top queue.md next item], or different focus?"
4. If user passed an argument, treat as additional context to scope the
   resume summary or seed the initial `focus`.

## Discovery

Older `daily_mem/YYYY-MM-DD.md` files loadable on demand when prior-day context
needed. Sort by filename desc. Don't auto-load all — only what's relevant.

## Style rules

- Entries are fragments not sentences.
- One bullet = one item. No prose paragraphs.
- **≤2 lines per bullet in daily/queue.** If an entry wants more, that's the
  signal it's an artifact — write `artifacts/<prefix>_<topic>.md`, leave a
  one-line pointer.
- File refs as absolute paths with line numbers: `/abs/path:line`.
- Drop articles, hedging, filler.
