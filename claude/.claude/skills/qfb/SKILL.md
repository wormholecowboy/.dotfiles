---
name: qfb
description: Question feedback. Rate the questions Claude asked the user (this session, or old ernie questions in batches) so a question policy can be written later. Use when the user runs /qfb, or says yes to the end-of-task qfb reminder.
argument-hint: "[old [n]]"
disable-model-invocation: true
---

# qfb

Collect evidence on which questions need the user and which Claude can handle alone. This skill is temporary. When the evidence is enough, it becomes a spec, and this skill is removed.

## Ratings

Rate each question with one rating:

- `needed`: only the user could answer it (taste, scope, priority, an action only the user can do).
- `decide-tell`: Claude could pick the obvious option, do it, and tell the user in one line. The user can still overrule.
- `no-ask`: Claude should not have raised it at all (a fact Claude can check, a choice an existing rule covers).

Add one reason tag:

- `irreversible`: one option cannot be undone.
- `taste`: style, naming, look or wording that the user prefers.
- `scope`: what to build, what to cut, the order of work.
- `user-only`: only the user can do the action (a login, a blocked permission, a machine Claude cannot reach).
- `checkable`: Claude could find the answer with a command or a read.
- `covered`: a rule in CLAUDE.md, a skill or memory already answers it.
- `cheap-undo`: both options are cheap to undo.
- `design`: two valid designs with different trade-offs.

A new reason tag needs a one-line meaning. Add it to this list in the same pass.

## Modes

- `/qfb`: rate the questions of this session.
- `/qfb old [n]`: rate the next `n` old ernie questions of this worktree (default 10). Run the script, from this skill's folder:
  `python3 -I ~/.claude/skills/qfb/old_questions.py <items.jsonl> <ratings.jsonl> <repo-key> <n>`
  Get `<items.jsonl>` and `<repo-key>` from `ernie where` (the `items` and `key` lines). The script skips questions that are already rated.

## Flow

0. If `~/.dotfiles/claude/.claude/question-feedback/pending.md` exists, show its table first and rate it. Delete the file after its ratings are saved.
1. Build one table. One row per question, handles `R1`, `R2`, … Columns: handle, the question (≤15 words), the user's answer, `rec` (✓ if the user picked Claude's recommendation), the proposed rating + reason tag.
2. Ask the user for exceptions only: "Reply with the rows to change (e.g. `R2 needed`), or `ok`." A short note on a row is welcome.
3. Ask at most one question back, and only when a pattern is unclear. Keep it to one line.
4. Append one line per row to the ratings file (below). Show nothing more than "Saved n ratings (total N)."
5. Stop point: at 50 ratings or more, offer once per run to write the question policy (`spec_question_policy.md` in ernie memory, or in the repo's memory).

Keep the whole exchange short. The user is in the middle of other work.

## Ratings file

`~/.dotfiles/claude/.claude/question-feedback/ratings.jsonl`. One JSON object per line:

```json
{"ts":"2026-11-25T10:00:00Z","repo":"ernie/main","source":"ernie","ref":"q110","question":"…","choices":["…"],"recommended":"…","answer":"…","followed_rec":true,"proposed":"decide-tell","rating":"decide-tell","reason":"irreversible","note":""}
```

- `source`: `ernie` (with `ref` = the ernie id) or `session` (with `ref` = the Q handle, and `repo` = the git toplevel name and branch).
- `proposed` is Claude's rating; `rating` is the final one. They differ when the user changed the row.
- Create the folder and file if missing. Never edit old lines; a fix is a new line with the same `repo` + `ref`, and the last line wins.
