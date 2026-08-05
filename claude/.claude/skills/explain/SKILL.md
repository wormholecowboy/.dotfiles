---
name: explain
description: Re-explain your previous response in more depth — the user didn't fully understand it. Definitions first, then a step-by-step walkthrough of each piece.
disable-model-invocation: true
argument-hint: "[specific part to explain]"
---

The user did not fully understand what you just told them. Re-explain it at a deeper, more foundational level. Do not just rephrase — decompose.

**Arguments:** `$ARGUMENTS`

- If arguments were given, focus the explanation on that specific part of your previous response.
- If no arguments, re-explain the whole of your most recent substantive answer.

## Rules

- Assume less background knowledge than you did last time. If you leaned on a concept without explaining it, explain it now.
- Prefer concrete over abstract: show the actual command/code/value from the conversation and narrate what it does, rather than describing it generically.
- Don't introduce new jargon in the explanation without defining it inline.
- Don't pad. Deeper ≠ longer for its own sake — every sentence should remove confusion.

## Output format

### 1. Definitions

Up top, before anything else: a bullet list of every term, acronym, tool, or concept the explanation depends on, most fundamental first (so later definitions can build on earlier ones). Anchor each to how it's used here, not a generic dictionary entry.

- **TERM** (expansion, if acronym) — one- or two-sentence definition.

### 2. Step-by-step walkthrough

Number the steps. Walk through the thing in the order it happens (or the order the reader should build understanding). For each step:

- **What happens** — plain language, one idea per step.
- **What each piece is for** — if the step involves a command, config line, flag, or code fragment, break it apart and say what each part does and why it's there.

### 3. The takeaway

Two or three sentences: the whole thing restated now that the pieces are defined — what it does, why it matters here.

End by offering to go deeper on any specific step.
