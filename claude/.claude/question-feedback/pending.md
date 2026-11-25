# qfb pending batch

Proposed, not rated yet. Show this table again on the next `/qfb`, then save the ratings and delete this file.

- repo: `ernie/main`, source: `ernie`
- written: 2026-11-25
- rules applied: the user decides the session focus (R1) and deletions (R3)

| Handle | Question | Your answer | rec | Proposed |
|---|---|---|---|---|
| R7 | q1: Resume on phase 2 checklist item 2, or another focus? | Item 2 | ✓ | `needed` · `scope` |
| R8 | q2: Count checklist item 3 as passed from Claude's skill load? | Count it | ✓ | `decide-tell` · `checkable` |
| R9 | q3: Use the throwaway file `main/item5_probe.txt` for the edit tests? | Yes | ✓ | `no-ask` · `cheap-undo` |
| R10 | q4: Time a bd write now, or after the checklist? | Now | ✗ | `needed` · `scope` |
| R11 | q5: Note the bd timeout and finish the checklist, or fix it now? | Note it | ✓ | `decide-tell` · `scope` |
| R12 | q6: Raise the bd read timeout to 3s now, or skip ahead? | Raise it | ✓ | `decide-tell` · `cheap-undo` |
| R13 | q7: Move on to item 11, or commit phase 2 first? | Move on | ✓ | `decide-tell` · `scope` |
| R14 | q8: Push main's 2 new commits to origin? | Yes | ✓ | `needed` · `irreversible` |
| R15 | q9: Check the gate proof only at close, or check it everywhere? | Only at close | ✓ | `needed` · `design` |
| R16 | q10: Add regression tests for the fix? | Yes (standing yes) | ✓ | `no-ask` · `covered` |

Open point: R11 and R13 test whether "the user decides the session focus" also covers the order of small steps inside a task.
