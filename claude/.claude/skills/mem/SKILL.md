---
name: mem
description: >
  Persistent memory at `.mem/` (git root). Triggers: `*um` (update), `*mr <topic>` (read by topic), `/mem-read` (resume), or "update/read memory".
---

# Memory System

Persistent file-based memory at `.mem/` (git root). Terse, machine-targeted.
Replaces the older `.state/` system.

## Files

- `.mem/long.md` — durable: goals, learnings, gotchas, arch. Slow churn.
- `.mem/YYYY-MM-DD.md` — daily: per-session work state.

## `long.md` format

```
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

## Triggers

### `*um` — update memory

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

1. Read `[root]/.mem/long.md` if present.
2. `grep -rn "\[<topic>\]" [root]/.mem/*.md` — load matching chunks only.
3. Present matched entries grouped by source file. Cheaper than full read.

### `/mem-read` or "read memory" — full resume

1. Read `[root]/.mem/long.md` if present.
2. Find most recent daily: glob `[root]/.mem/????-??-??.md`, sort desc, pick
   top. Read it.
3. Args handling:
   - `list` → list all dailies with focus line, let user pick.
   - `<YYYY-MM-DD>` → load that specific daily.
   - `<topic>` → also pull tagged chunks from older dailies via grep.
4. Present terse summary:
   - focus + status (from frontmatter)
   - open qs
   - next
   - wip
   - key files
5. Ask: "Resume on [top next item], or different focus?"

If `.mem/` missing, say no memory yet — suggest `*um` to start.

## Discovery

Older `.mem/YYYY-MM-DD.md` files loadable on demand when prior-day context
needed. Sort by filename desc. Don't auto-load all — only what's relevant.

## Style rules

- Entries are fragments not sentences.
- One bullet = one item. No prose paragraphs.
- File refs as absolute paths with line numbers: `/abs/path:line`.
- Drop articles, hedging, filler.
