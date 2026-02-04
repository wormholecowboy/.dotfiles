# PRD Creation Guide

Guide for Stage 1 of the builder skill. Combines interactive discovery with comprehensive documentation.

---

## Phase A: Discovery (Interactive)

Before writing anything, gather requirements through conversation.

### 0. Check Learnings

Read `learnings.md` and surface any relevant past learnings based on:
- Project type (API, CLI, web app, agent, etc.)
- Technologies mentioned
- Patterns being discussed

### 1. Interview (Bidirectional)

Ask questions to understand the full picture:

**Phase 1: Understand the Goal**

| Question | Why It Matters |
|----------|----------------|
| What problem are we solving? | The "why" - ensures we're building the right thing |
| What does success look like? | Clear goals, measurable outcomes |
| Who are the users? | Personas, technical comfort, pain points |

**Phase 2: Explore the Codebase (REQUIRED)**

Once you understand the basics of what we're building, **you MUST explore the codebase** before continuing:

> "Now that I understand the goal, let me explore the codebase to understand what's already in place. Where should I look? Is there a specific directory or existing feature this will build on?"

Use the **Explore agent** to:
- Understand project structure and conventions
- Find existing patterns to follow (naming, error handling, logging)
- Identify integration points for the new feature
- Discover related implementations that inform the design
- Note the actual tech stack and versions in use

Report back what you found:
> "I explored the codebase and found: [summary]. This informs the design because: [insights]"

**Why this matters:** PRD decisions grounded in actual code context are far more accurate than decisions based on conversation alone. Patterns, constraints, and integration points are often implicit in the code.

**Phase 3: Constraints & Scope**

| Question | Why It Matters |
|----------|----------------|
| What constraints exist? | Time, resources, dependencies, budget |
| What risks should we consider? | Blockers, unknowns, dependencies |
| What's explicitly NOT in scope? | Prevents scope creep |

**Bidirectional speccing:** After gathering requirements, state your assumptions back to the user. Ask them to confirm or correct. This surfaces implicit assumptions that cause bugs.

Continue until both sides are aligned on exactly what's being built.

### 2. Synthesize

Before writing:
- Identify explicit requirements AND implicit needs
- Note technical constraints and preferences
- Capture user goals and success criteria
- Fill in reasonable assumptions (flag them as assumptions)

---

## Phase B: Write PRD

Create `main.md` with the following structure. Adapt depth based on project type:
- **Technical projects:** Emphasize Architecture, Tech Stack, API Spec
- **User-facing projects:** Emphasize User Stories, Target Users, Success Criteria
- **Hybrid:** Balance both

### Required Sections

#### 1. Executive Summary
- Concise overview (2-3 paragraphs)
- Core value proposition
- MVP goal statement

#### 2. Mission & Principles
- Product mission statement (one sentence)
- Core principles (3-5 key principles guiding decisions)

#### 3. Target Users
- Primary user personas
- Technical comfort level (Low / Medium / High)
- Key pain points this solves

#### 4. MVP Scope

**In Scope:**
- Core feature 1
- Core feature 2

**Documentation (Required):**
- Update README.md Platform Features (if user-visible)
- Update architecture.md (if architectural components added)

**Out of Scope (Future):**
- Deferred feature 1
- Nice-to-have 2

Group by category if helpful: Core Functionality, Technical, Integration, Deployment, Documentation

#### 5. User Stories

Format: "As a [user], I want to [action], so that [benefit]"

1. **[Story name]** - As a [user], I want to [action], so that [benefit]
   - Example: [Concrete scenario]

Include 5-8 stories for MVP. Add technical user stories if relevant.

#### 6. Core Architecture & Patterns
- High-level architecture approach
- Directory structure (if applicable)
- Key design patterns
- Technology-specific patterns to follow

#### 7. Features/Tools Specification

Detailed breakdown of each feature:

**Feature: [Name]**
- Purpose: What it does
- Operations: Key actions/methods
- Key details: Important implementation notes

Adapt based on project type (agent tools vs app features vs API endpoints).

#### 8. Technology Stack

| Layer | Choice | Version | Rationale |
|-------|--------|---------|-----------|
| Backend | Python | 3.11+ | Team expertise |
| Database | SQLite | - | Local-first, simple |

Include:
- Core technologies with versions
- Key dependencies
- Optional dependencies
- Third-party integrations

#### 9. Security & Configuration

**Authentication:** Approach (if applicable)
**Configuration:** Environment variables, settings files
**Security scope:**
- In scope: What security measures are included
- Out of scope: What's deferred

#### 10. API Specification (if applicable)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| /api/resource | GET | Fetch resources |

Include request/response formats and example payloads for key endpoints.

#### 11. Success Criteria

**MVP is successful when:**
- Criterion 1 (measurable)
- Criterion 2 (measurable)

**Quality indicators:**
- Performance targets
- User experience goals

#### 12. Implementation Phases

### Phase 1: [Name]
- **Goal:** What this phase achieves
- **Deliverables:**
  - Specific output 1
  - Specific output 2
- **Validation:** How we know it's done

### Phase 2: [Name]
...

Break into 2-4 phases. Each phase should be independently valuable.

#### 13. Future Considerations
- Post-MVP enhancements
- Integration opportunities
- Advanced features for later

#### 14. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Description] | Low/Med/High | Low/Med/High | [Strategy] |

Include 3-5 key risks.

#### 15. Assumptions

> Decisions made without full information - flag for validation

- Assumed X because Y
- Assumed Z (needs verification)

#### 16. Open Questions
- Things still to figure out
- Decisions deferred

---

## Phase C: Quality Checks

Before moving to Stage 2, verify:

- [ ] **Scope clarity** - In/Out scope sections are explicit
- [ ] **User stories have benefits** - Each story explains "so that [why]"
- [ ] **Success criteria are measurable** - Can objectively verify completion
- [ ] **Technical choices are justified** - Rationale provided
- [ ] **Phases are actionable** - Each has clear deliverables
- [ ] **Assumptions documented** - Unknowns flagged for validation
- [ ] **Consistent terminology** - Same terms used throughout
- [ ] **Target users defined** - Know who we're building for
- [ ] **Risks identified** - At least 3 risks with mitigations

---

## Style Guidelines

- **Tone:** Professional, clear, action-oriented
- **Format:** Markdown (headings, lists, tables, code blocks)
- **Checkboxes:** Use checkmarks for in-scope, X for out-of-scope
- **Specificity:** Concrete examples over abstract descriptions
- **Assumptions:** Always flag with "Assumed:" or in Assumptions section

---

## After PRD Creation

1. **Initialize ADR** - Create `adr.md` with initial technical decisions
2. **Confirm with user** - Summarize what was captured, highlight assumptions
3. **Ready for Stage 2** - Architecture review
