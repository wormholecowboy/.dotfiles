# Implementation Planning Guide

Guide for Stage 3 of the builder skill. Creates comprehensive implementation plans that enable one-pass build success.

---

## Core Philosophy

**Context is King.** The plan must contain ALL information needed for implementation - patterns, mandatory reading, documentation, validation commands - so the build agent succeeds on the first attempt.

**No Prior Knowledge Test:** Someone unfamiliar with the codebase should be able to implement using only the plan content.

**No code in this phase.** Only research, analysis, and documentation.

---

## Phase A: Codebase Intelligence Gathering

Before writing any implementation plan, gather deep context about the codebase.

### 1. Project Structure Analysis

- Detect primary language(s), frameworks, and runtime versions
- Map directory structure and architectural patterns
- Identify service/component boundaries
- Locate configuration files (pyproject.toml, package.json, etc.)
- Find environment setup and build processes

### 2. Pattern Recognition

Search for and document:

| Pattern Type | What to Find |
|--------------|--------------|
| Naming conventions | CamelCase, snake_case, kebab-case |
| File organization | How modules are structured |
| Error handling | How errors are caught, logged, propagated |
| Logging | Format, levels, where logs go |
| Testing | Framework, structure, naming conventions |

**Also check:**
- CLAUDE.md for project-specific rules
- Existing similar implementations to mirror
- Anti-patterns to avoid

### 3. Dependency Analysis

- Catalog external libraries relevant to the feature
- Check how libraries are integrated (imports, configs)
- Find relevant documentation in docs/, ai_docs/, or similar
- Note library versions and compatibility requirements

### 4. Testing Patterns

- Identify test framework (pytest, jest, etc.)
- Find similar test examples for reference
- Understand test organization (unit vs integration)
- Note coverage requirements and testing standards

### 5. Integration Points

- Identify existing files that need updates
- Determine new files to create and their locations
- Map router/API registration patterns
- Understand database/model patterns if applicable
- Identify auth/authz patterns if relevant

---

## Phase B: External Research

Use subagents for external research when beneficial.

### Documentation Gathering

- Research latest library versions and best practices
- Find official documentation with **specific section anchors**
- Locate implementation examples and tutorials
- Identify common gotchas and known issues
- Check for breaking changes and migration guides

### Compile Research References

```markdown
## Relevant Documentation

- [Library Official Docs](https://example.com/docs#specific-section)
  - Section: Authentication setup
  - Why: Required for implementing secure endpoints

- [Framework Guide](https://example.com/guide#integration)
  - Section: Database integration
  - Why: Shows proper async patterns
```

**Key:** Include specific section anchors, not just homepage links.

---

## Phase C: Strategic Thinking

Before writing tasks, answer these questions:

### Architecture Fit
- [ ] How does this feature fit into the existing architecture?
- [ ] Does it follow established patterns or introduce new ones?
- [ ] If new patterns, is that justified?

### Dependencies & Order
- [ ] What are the critical dependencies?
- [ ] What's the correct order of operations?
- [ ] Which tasks can run in parallel vs must be sequential?

### Risk Assessment
- [ ] What could go wrong? (edge cases, race conditions, errors)
- [ ] What are the failure modes?
- [ ] How will errors be handled and surfaced?

### Quality Concerns
- [ ] How will this be tested comprehensively?
- [ ] What performance implications exist?
- [ ] Are there security considerations?
- [ ] How maintainable is this approach?

### Design Decisions
- [ ] What alternative approaches exist?
- [ ] Why is the chosen approach better?
- [ ] Is backward compatibility needed?
- [ ] What are the scalability implications?

---

## Phase D: Write Implementation Plan

Create `impl/phaseN-impl.md` with the following structure.

### Plan Header

```markdown
# Phase N Implementation Plan: [Phase Name]

**PRD Reference:** `../main.md`
**Status:** Ready for Implementation

## Overview

Brief description of what this phase accomplishes.

## Feature Metadata

**Feature Type:** [New Capability | Enhancement | Refactor | Bug Fix]
**Complexity:** [Low | Medium | High]
**Primary Systems Affected:** [List components]
**Dependencies:** [External libraries or services]
```

### Context References (CRITICAL)

```markdown
## Context References

### Mandatory Reading (MUST read before implementing)

> These files contain patterns and context essential for implementation.

- `path/to/file.py` (lines 15-45)
  - Why: Contains pattern for X that we'll mirror
- `path/to/model.py` (lines 100-120)
  - Why: Database model structure to follow
- `path/to/test.py`
  - Why: Test pattern example

### Files to Create

- `path/to/new_service.py` - Service implementation for X
- `path/to/new_model.py` - Data model for Y
- `tests/path/to/test_new.py` - Unit tests

### Files to Modify

- `path/to/router.py` - Register new endpoints
- `path/to/config.py` - Add configuration

### External Documentation (SHOULD read)

- [Library Docs](https://example.com/docs#section)
  - Section: Specific feature
  - Why: Required for X functionality
```

### Patterns to Follow

```markdown
## Patterns to Follow

> Extracted from codebase - implementation must match these patterns.

**Naming:**
- Functions: snake_case
- Classes: PascalCase
- Files: kebab-case

**Error Handling:**
```python
# From path/to/errors.py:25
try:
    result = operation()
except SpecificError as e:
    logger.error(f"Operation failed: {e}")
    raise ServiceError(f"Could not complete: {e}") from e
```

**Logging:**
```python
# From path/to/service.py:42
logger.info("Processing item", extra={"item_id": item.id, "status": "started"})
```
```

### Task Breakdown

```markdown
## Tasks

### Task 1: [Task Name]

**ID:** `phase1-task1`
**Complexity:** S | M | L
**Blocked By:** [] (task IDs that must complete first)

**Description:**
What this task accomplishes.

**Files:**
- CREATE: `path/to/new_file.py` - Purpose
- UPDATE: `path/to/existing.py` - What changes

**Implementation Details:**
- IMPLEMENT: Specific implementation detail
- PATTERN: Reference existing pattern at `file.py:45`
- IMPORTS: `from module import X, Y`
- GOTCHA: Known issue to avoid (e.g., "Don't use sync calls here")

**Validation:**
```bash
# Must pass before task is complete
ruff check path/to/new_file.py
pytest tests/test_specific.py -v
```

**Unit Test:**
Create test that verifies this task's functionality independently.
```

### Task Format Keywords

Use these action keywords for clarity:

| Keyword | Meaning |
|---------|---------|
| CREATE | New files or components |
| UPDATE | Modify existing files |
| ADD | Insert new functionality into existing code |
| REMOVE | Delete deprecated code |
| REFACTOR | Restructure without changing behavior |
| MIRROR | Copy pattern from elsewhere in codebase |
| CONFIGURE | Set up config, env vars, or settings |
| INTEGRATE | Connect to existing systems |

### Validation Commands (Structured by Level)

```markdown
## Validation Commands

### Level 1: Syntax & Style
```bash
ruff check src/
ruff format --check src/
mypy src/
```

### Level 2: Unit Tests
```bash
pytest tests/unit/ -v
```

### Level 3: Integration Tests
```bash
pytest tests/integration/ -v
```

### Level 4: Manual Validation
```bash
# Start server and test endpoint
curl -X POST http://localhost:8000/api/feature -d '{"test": true}'
```

### Level 5: Additional (Optional)
```bash
# MCP servers, browser testing, etc.
```
```

### Phase Validation

```markdown
## Phase Validation

> Run after ALL tasks in this phase complete.

```bash
# Full test suite
pytest tests/ -v

# Integration smoke test
python -c "from module import feature; feature.smoke_test()"

# End-to-end check
curl -s http://localhost:8000/health | grep "ok"
```

**Phase Complete When:**
- All task validations passed
- All phase validation commands passed
- All tasks reviewed and committed
```

### Confidence Score

```markdown
## Confidence Score

**Score: N/10**

**What would make this 10/10?**
- [Gap 1 - addressed/unresolved]
- [Gap 2 - addressed/unresolved]

## Escalation Notes

> Remove this section if empty.

- [Concern requiring architect input]
- [Decision requiring escalation to user]
```

---

## Quality Criteria Checklists

Before marking implementation plan complete, verify:

### Context Completeness
- [ ] All necessary patterns identified with file:line references
- [ ] External library usage documented with links
- [ ] Integration points clearly mapped
- [ ] Gotchas and anti-patterns captured
- [ ] Every task has executable validation command

### Implementation Ready
- [ ] Another agent could execute without additional context
- [ ] Tasks ordered by dependency (can execute top-to-bottom)
- [ ] Each task is atomic and independently testable
- [ ] Pattern references include specific file:line numbers
- [ ] Mandatory reading files are specific and essential

### Pattern Consistency
- [ ] Tasks follow existing codebase conventions
- [ ] New patterns justified with clear rationale
- [ ] No reinvention of existing patterns or utils
- [ ] Testing approach matches project standards

### Information Density
- [ ] No generic references (all specific and actionable)
- [ ] URLs include section anchors when applicable
- [ ] Task descriptions use codebase-specific terms
- [ ] Validation commands are executable (not pseudocode)

---

## Success Metrics

### One-Pass Implementation
Build agent can complete all tasks without additional research or clarification.

### Validation Complete
Every task has at least one working validation command.

### No Prior Knowledge Test
Someone unfamiliar with the codebase can implement using only the plan content.

### Confidence Score
Target: 10/10 before build begins. If < 10, gaps must be addressed or escalated.

---

---

## Required Final Phase: Documentation

**Every implementation plan MUST include a documentation phase** as the final phase.

### Documentation Phase Template

```markdown
# Phase N: Documentation Updates

**Goal:** Update project documentation to reflect the new capabilities.

**Deliverables:**
- Updated README.md (if user-visible features added)
- Updated architecture.md (if architectural components added)
- Component documentation (if complex features warrant dedicated docs)

---

## Tasks

### Task N.1: Update README.md Platform Features
**ID:** phaseN-task1
**Dependencies:** [last integration task from previous phase]

**Implement:** Update `README.md` → "Platform Features" section.

Add entry documenting new capabilities:
**[Module Name]** (PRD #NNNN - Implemented):
- ... (existing items)
- **[New Feature]** (PRD #NNNN) - Brief description

**Validation:**
\`\`\`bash
grep -i "[feature-name]" README.md
\`\`\`

---

### Task N.2: Update architecture.md
**ID:** phaseN-task2
**Dependencies:** [last integration task from previous phase]

**Implement:** Update architecture documentation with new component architecture.

**Validation:**
\`\`\`bash
grep -i "[feature-name]" docs/architecture.md
\`\`\`
```

### When to Skip

Documentation phase can be minimal or skipped ONLY if:
- Pure refactoring with no user-visible changes
- Bug fixes with no new capabilities
- Internal tooling changes not affecting architecture

In these cases, still include a single task to verify no docs need updating.

---

## After Plan Creation

1. **Report back** with:
   - Summary of phase and approach
   - Complexity assessment
   - Key implementation risks
   - Confidence score

2. **Ready for Stage 4** - Implementation Review by architect
