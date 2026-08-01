---
name: pnotes
description: Create or update a personal cheatsheet in ~/things/pnotes for a CLI tool, language, or workflow. Use when the user runs /pnotes, or asks to save/note/write down a cheatsheet from what we just discussed.
argument-hint: "[tool-name] (optional — defaults to the tool(s) from our conversation)"
---

# pnotes

Write or update a cheatsheet in `~/things/pnotes/`.

## 1. Read the style guide first
Read `~/things/pnotes/_style_guide.md` and follow its format exactly: backticks
around every command, `//` comments where explanation helps, two trailing spaces
per line, UPPERCASE section headers, common-first ordering. Every line you write
must match it.

## 2. Pick the tool
- If `$ARGUMENTS` names a tool, that's the subject.
- Otherwise infer it from our conversation — the tool, command, or workflow we
  were just discussing. If it's genuinely ambiguous, ask which tool.

## 3. Find the target file
- Look for an existing file matching the tool in `~/things/pnotes/`, any
  extension (`<tool>.md`, `.sh`, `.py`, etc.).
- If one exists → **update** it. Add the missing commands, slot them into the
  right section, leave working content alone. Prefer `Edit` over rewriting the
  whole file. New lines follow the style guide even if the old file didn't.
- If none exists → **create** `~/things/pnotes/<tool>.md` (kebab-case name).

## 4. Keep it simple
A cheatsheet is a memory jog, not documentation.
- Cover the MOST COMMONLY used syntax and options only.
- Include short examples of common operations.
- Skip anything rarely used or easily guessed.
- With no arg, draw from our conversation — capture what we actually did.

## 5. Confirm
Report the file path, whether you created or updated it, and a one-line summary
of what you added.
