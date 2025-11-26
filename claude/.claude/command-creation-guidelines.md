# Command Structure: The Agent Perspective Framework

## The INPUT → PROCESS → OUTPUT Framework

Every effective slash command follows a simple structure that answers three questions from the agent's perspective:

### 1. **INPUT**: What does the agent NEED to see?

The agent needs context to succeed. Without it, the agent makes assumptions or provides generic responses.

**What to include:**
- Context for the task (tech stack, patterns, standards)
- Domain knowledge required for the task
- References to documentation or files
- Any constraints or requirements

**Example from `command-example.md`:**
```markdown
## Context (INPUT)

You are reviewing code for a FastAPI application using:
- Python 3.12 with strict type hints
- Pydantic for validation
- pytest for testing
```

---

### 2. **PROCESS**: What should the agent DO?

Clear, step-by-step instructions guide the agent through the workflow.

**What to include:**
- Specific steps to follow
- Analysis criteria or evaluation points
- Tools or methods to use
- Order of operations

**Example from `command-example.md`:**
```markdown
## Process (PROCESS)

Analyze the code for:
1. Type safety issues (missing hints, incorrect types)
2. Pydantic validation errors (missing validators)
3. Testing gaps (uncovered edge cases)
4. FastAPI patterns (proper dependency injection, route structure)
```

---

### 3. **OUTPUT**: What do you WANT back?

Specify the format and structure of the response to get consistent, actionable results.

**What to include:**
- Format specification (structured vs conversational)
- Required sections or fields
- Level of detail needed
- Who will consume this output (you or another agent)

**Example from `command-example.md`:**
```markdown
## Output Format (OUTPUT)

For each issue found:
- **File:Line**: Specific location
- **Issue**: What's wrong
- **Suggestion**: Concrete fix with code example
- **Priority**: Critical/High/Medium/Low
```

---

## Why This Structure Works

**Without structure:**
```markdown
Review this code
```
→ Vague, generic response with no project context

**With INPUT/PROCESS/OUTPUT:**
```markdown
## Context (INPUT)
[Project-specific context]

## Process (PROCESS)
[Clear steps to follow]

## Output Format (OUTPUT)
[Structured format specification]
```
→ Precise, actionable, consistent results

---

## Designing for Agent Consumption vs Human Reading

### For Humans (You)
- Conversational tone is fine
- Can be more implicit
- Focus on readability

### For Agents (Chaining Commands)
- Be explicit and structured
- No ambiguity
- Include file paths, commands, exact specifications
- Think: "Can another agent execute this without seeing my conversation?"

---

## Chaining Workflows: A Preview

The most powerful pattern is when one command's OUTPUT becomes another command's INPUT:

```
Command 1: /planning feature-name
OUTPUT → Creates: plans/feature-name.md

Command 2: /execute feature-name
INPUT ← Reads: plans/feature-name.md
OUTPUT → Implements the feature

Command 3: /commit
OUTPUT → Creates git commit
```

Each command is reusable. Together, they form systematic workflows.

**This is just a preview - we'll explore command patterns and chaining in detail in the next module!**

---

## The Example Command

See `command-example.md` for a complete example showing:
- Clear INPUT context (FastAPI project specifics)
- Explicit PROCESS steps (4 analysis points)
- Structured OUTPUT format (issue format with priority)

This structure ensures the agent knows exactly what you need and delivers consistent results every time.
