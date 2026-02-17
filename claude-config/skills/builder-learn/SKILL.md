---
name: builder-learn
description: Capture learnings from implementation issues to improve future planning. Use after discussing bugs, architectural problems, or process issues to add them to the planner's knowledge base.
---

# Learn Skill

Captures insights from implementation experiences and adds them to the builder's learnings file.

## Critical: Abstraction Level

**Learnings must be globally applicable principles, NOT specific details about specific libraries.**

Ask yourself: "Would this learning help someone working on a completely different project with different technologies?"

### Good Learning (Principle)
```
#### 2026-01-18 - Verify installed API against documentation before implementing
**Context:** Building integrations where documentation/examples used outdated APIs
**Learning:** Documentation and examples may lag behind the installed library version. Before implementing, check the actual installed version and verify the API signatures match what you're planning to use.
**Why it matters:** Prevents wasted effort implementing against APIs that no longer exist.
```
This applies to ANY library integration.

### Bad Learning (Too Specific)
```
#### 2026-01-18 - LiveKit room tokens require specific claims
**Context:** Building voice agent with LiveKit
**Learning:** LiveKit access tokens need roomJoin, roomCreate, and canPublish grants...
**Why it matters:** Token generation will fail without proper claims.
```
This only helps if someone is using LiveKit. It belongs in project docs, not learnings.

### The Test
Before capturing, ask:
1. Does this apply to similar situations with **different** technologies?
2. Is the learning a **principle** or a **library-specific detail**?
3. Would this help someone who's never heard of the specific tech mentioned?

If no to any of these → don't capture it, or abstract it further.

## When to Use

Run `/builder-learn` after:
- Discussing a bug and its root cause
- Discovering an architectural issue during implementation
- Finding a better approach than what was planned
- Hitting a process or workflow problem
- Any "we should remember this for next time" moment

## How It Works

1. **Analyze** the recent conversation to identify the learning
2. **Abstract** it to a globally applicable principle (see above)
3. **Categorize** it (subagent usage, architecture, testing, dependencies, performance, error handling, process)
4. **Format** it with date, context, learning, and why it matters
5. **Append** to `.claude/skills/builder/learnings.md`
6. **Confirm** what was added

## Activation

When invoked via `/builder-learn`:

1. Analyze the conversation to extract:
   - What was the problem or issue?
   - What did we learn from it?
   - What's the **generalizable principle** for future planning?

2. **Abstract check** - Before proceeding, verify:
   - Is this a principle that applies beyond this specific library/tech?
   - If not, either abstract it further OR skip capturing (tell the user it's too specific)

3. Determine the category:
   - **Subagent Usage** - When/how to use subagents
   - **Architecture & Design** - Architectural decisions, patterns
   - **Testing & Validation** - Testing strategies, validation
   - **Dependencies & Integration** - Managing dependencies
   - **Performance & Optimization** - Performance considerations
   - **Error Handling & Edge Cases** - Error patterns, edge cases
   - **Process & Workflow** - Planning/building process itself

4. Format the learning:
   ```markdown
   #### [DATE] - [Short Title]
   **Context:** What we were building/doing
   **Learning:** The principle or insight
   **Why it matters:** How this affects future planning
   ```

5. Read the current learnings.md file

6. Append the new learning under the appropriate category heading

7. Write the updated file

8. Output confirmation:
   ```
   Learning captured:
   - Category: [category]
   - Title: [title]
   - Added to: .claude/skills/builder/learnings.md
   ```

## Learnings File Location

`.claude/skills/builder/learnings.md`

This file is referenced by the builder during PRD creation and implementation planning.

## Example

After discussing that Plan agents can't write files:

```
/builder-learn
```

Output:
```
Learning captured:
- Category: Subagent Usage
- Title: Use general-purpose agents for file-writing tasks
- Added to: .claude/skills/builder/learnings.md
```

The builder will now surface this learning when planning tasks that involve subagents writing files.
