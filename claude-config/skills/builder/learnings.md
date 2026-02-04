# Planning & Building Learnings

Principles from real implementation experiences. Check during Stage 1 (PRD) and Stage 3 (Implementation Planning).

*Archive old learnings to `learnings-archive.md` after 6 months. Consolidate similar learnings quarterly.*

---

## Subagent Usage

- **Use general-purpose agents for file-writing tasks** (2026-01-17): Plan agent is read-only. Use `general-purpose` when task requires writing files like implementation plans.

## Architecture & Design

- **Scheduled jobs need concurrency protection** (2026-01-24): When duration may exceed interval, use lock files (`fcntl.flock`). Symptom: duplicate outputs, race conditions.

## Testing & Validation

*(No entries yet)*

## Dependencies & Integration

- **Verify installed API against documentation** (2026-01-18): Docs may lag behind installed version. Check actual version before implementing.

## Performance & Optimization

*(No entries yet)*

## Error Handling & Edge Cases

- **In queue/pipeline processing, always advance state even on failure** (2026-01-24): "Advance + log error" not "advance only on success". Failed items → dead-letter queue. Symptom: infinite loops, runaway processing.

## Process & Workflow

- **Search for errors first, don't just tail logs** (2026-01-18): Run `grep -i "error\|exception"` before reading sequentially.
- **In distributed systems, trace requests through all components** (2026-01-18): Verify request reached each hop. Bug often at different layer than symptoms.
- **When iterating doesn't work, start with a clean slate** (2026-01-18): After 2-3 failed iterations, reset completely: kill processes (`pkill -9 -f`), use fresh identifiers, clear cached state.
