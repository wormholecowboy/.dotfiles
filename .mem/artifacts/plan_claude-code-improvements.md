# plan: Claude Code efficiency/reliability fixes (from transcript audit 2026-10-07)

Source: audit of ~/.claude/projects — 82 main + 112 subagent sessions (2026-09-08..10-06), 4,266 tool calls, 544 prompts.
Done: #1 shell aliases/zsh opts guarded by $CLAUDECODE (f20e1ff); #3 AWS via AWS_PROFILE=saml + AWS_REGION in settings env, CLAUDE.md §6 rewritten (659f489); mem-ops/docker-cli-ops/git-ops → sonnet (659f489).

## Open (ranked)
2. [mem] Memory writes lossy, no history — mem-ops was 68/112 subagent runs (~90s, 22 tool errors); overwrote a daily (09-10), wiped a 4-session `## done` (10-02), invented decisions + fake Bitbucket links, dropped queue items; `.mem` git-excluded → unrecoverable; agents/mem-ops.md still describes pre-2026-09-02 flat layout (contradicts SKILL.md).
   Fix: git-track `.mem` (own repo or un-exclude) + Stop-hook auto-commit; main thread applies *um itself via Edit (payloads already near-verbatim); dailies append-only; mem-ops only READ/dedup; sync mem-ops.md to SKILL.md.
4. [athena] Deny rules inert — 0/116 Athena runs matched the 32 DDL deny rules (SQL passed via scratchpad athq.sh/run.sh files, 50 inside `zsh -ic`); athq.sh rebuilt in ≥6 sessions, scratch venvs in 5; glue CDIT-2631 long.md:121 says "recreate athq.sh in scratchpad".
   Fix: permanent ~/things/scripts/athq (read-only statement allowlist, wait-until-done w/ timeout, row cap); deny raw `aws athena start-query-execution`; add `.venv` to glue worktree; update that long.md line.
5. [edit] Repo files rewritten via python/sed instead of Edit — claude-fable-5-1: 0 Edit vs 98 script rewrites / 14 sessions (fable-5: 151 vs 3); 36 sessions in bypassPermissions → no diffs, no /rewind; caused self-recursive log(), half-applied sed.
   Fix: CLAUDE.md §2 "modify repo files only via Edit/Write; Bash rewrites only in scratchpad" + PreToolUse hook blocking `sed -i` / `perl -pi` / python open(...,'w') under ~/things/myc.
6. [verify] "Verified" without receipts — ~10 "typecheck clean" claims from a tsc cmd that checked nothing (2 runtime breaks shipped); IAM trim based on half-true memory note broke deploy; validations on local MySQL 9.6 vs Aurora 8.0 target.
   Fix: CLAUDE.md rule — verified/tested/root-cause claims cite env + command/QueryExecutionId + decisive output line or file:line, else label "hypothesis".
7. [scope] Unflagged scope changes — ~20 "why did you add/drop X" rounds (dropped showcase, added visits/visitors, site_key...), each cascading DDL→spec→tests.
   Fix: CLAUDE.md §1 — trace each new column/table/name to a requirement before building; end rewrites with Added / Dropped / Carried-over lines.
8. [worktree] Wrong repo/worktree/env — wrong dashboard checkout in 4 sessions (conflict markers committed unnoticed); aws worktree initialized fresh .mem ("wrong mem"); prod-vs-stage lambda logs; 3 overlapping session pairs in one worktree.
   Fix: CLAUDE.md at each bare repo root w/ checkout map; SessionStart hook printing repo/branch/env + live sessions; mem skill searches sibling worktrees `~/things/myc/*/<branch>/.mem` and asks before init; one worktree per parallel session.
9. [context] Baseline context heavy — sessions start at 40–60k tokens (median 49k) before work; `.mem` = 27% of main-thread tool output; glue CDIT-2631 long.md 33KB read whole per /mem; Superblocks + Snyk MCP at user scope load everywhere; Superblocks instructions say user is "a non-technical business user… avoid discussing code".
   Fix: move Superblocks/Snyk MCP to local/project scope in dashboard repos; /mem loads only ops/queue/latest daily; cap long.md, load learnings by tag.
10. [explain] Explanations miss — 55 `*sa` + 32 "why/don't understand" prompts; *sa replies up to 2.8k chars; ~/.claude/explain-with-data.md (2026-09-30) unreferenced + not in dotfiles; `*one`/`*ar` undefined in CLAUDE.md. (Applied then reverted 2026-10-07 — user wants to revisit.)
   Fix options: define *sa limits, *one, *ar in CLAUDE.md §4; move explain-with-data.md to dotfiles + @-import from §8.

## Runners-up
- [settings] Uncommitted `autoMode` block in global settings.json names CDIT-2627 worktree as "Trusted repo" for all repos + describes old awsl workflow → move to that repo's .claude/settings.local.json or generalize.
- [aws] Role HLV_Developer_Admin MaxSessionDuration=3600 caps saml2aws `aws_session_duration`; ask admin to raise (≤12h), then match locally.
- [ui] UI bugs debugged by theory ~19h (DevClientPicker); save agent-browser auth state past SSO; rule: get console/runtime evidence before 2nd fix attempt.
- [claude] curl denied in settings but undocumented in CLAUDE.md (4 wasted calls) → add "use WebFetch / gh api".
- [claude] claude-code-guide on Haiku returned wrong CC facts → require verbatim quote + URL per claim, or use sonnet.
- [review] code-review skill/agent doesn't load .mem decisions → redundant reviews flag locked decisions; pass long.md ## arch + spec_* as "locked".
- [settings] /model, /effort, voice rewrite git-tracked settings.json → .gitattributes clean filter (jq del .model/.effortLevel/.modelSettings/.voiceEnabled).
