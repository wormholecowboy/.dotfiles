# Prompt audit — open items (2026-11-18)

Audit of the Claude Code configuration in `~/.dotfiles` against Claude Opus 5.5.
69 fixes landed in 2368d3f. These items have no patch: flags that need a decision, and report-only plugin findings.

Decisions already made:
- Q1: The global "Explain → I approve → then fix" rule is deleted, so `debugger` keeps its auto-fix.
- Q2: `syncClaudeAiSkills: false` turns off the claude.ai skill sync (77a2fe3).
- Q3: The `git-ops` agent is removed (77a2fe3).
- Q4: `/explain` keeps definitions first.
- Q5: Commits stay conventional with a directory scope.
- Q6: "One issue per message" is removed.
- The commit skills are removed (77a2fe3). The `mem-ops` agent is removed (c974ee3).

## Flags — no edit proposed

| ID | Location | Note |
|---|---|---|
| E3, E5, E6 | `skills/e2e-test/SKILL.md:113-123`, `:129-147`, `:106` | The `TaskCreate`/`TaskUpdate` tool names, agent-browser flags that drifted from `agent-browser/SKILL.md`, and `npm run dev &`. Installed-tool names cannot be checked from the repo. |
| CR3s, BR2, BR3, AS3 | `code-review/SKILL.md:86-87`; `brakes/SKILL.md:2`, `:11`; `autoskill/SKILL.md:11-17` | Style items against "not style"; a weak model-invocable description; duplicated trigger text in the body. |
| LR2, LR6, DO2, AR8/CR9 | agents | library-researcher writes to `PRPs/ai_docs/`. Typo "proactivley". A subagent cannot "ask". The reviewers have write tools they do not use. |
| K2, K3, O3, U2, V5 | skills | `skill-creator/references/` is never linked. There are 3-4 skill-creators. owasp checks hold about 4,500 lines of known patterns (on demand). ui-wireframe has a 140-line chatbot block. visual-explainer overlaps the Artifact tool for tables. |
| AGENTS.md | `opencode/.config/opencode/AGENTS.md:51` | "Don't reformat code" vs global `CLAUDE.md:13` "reformat … before committing". It loads only for files under `opencode/`. Otherwise clean. |
| X13 | session skill listing | In this repo, every user skill is listed twice (unscoped and `claude:`), because `claude/.claude/skills` is also found as a nested skills dir. Low impact. |

## Report only — plugins and synced skills

| ID | Location | Finding | Conf | What you can do |
|---|---|---|---|---|
| PL1 | `superpowers/7.0.2/skills/using-superpowers/SKILL.md:10-50` | It is injected every session: "even a 1% chance … ABSOLUTELY MUST … YOU DO NOT HAVE A CHOICE", plus a 12-row "Red Flags" table. On Opus 5.5 it makes process skills fire on simple questions. | H | File upstream, or add a `CLAUDE.md` override: "Invoke a skill only when it clearly fits." |
| PL2 | `sdd/1.4.0/skills/conventions/SKILL.md:23-57` | "Blocking requirement … If unsure whether a task is trivial, assume it is not". A one-line fix gets spec → brainstorm → plan → execute → review, with a commit at each phase. | H | Raise it with the sdd owners, or override "small fixes skip the spec workflow". |
| PL3 | `pr-review-toolkit/1.0.1/agents/code-simplifier.md:4-56` | "triggered automatically after completing a coding task … refining code immediately". It imposes another repo's rules (ES modules, the `function` keyword, React patterns) as "CLAUDE.md standards". | H | Disable this agent. |
| PL4 | `pr-review-toolkit/…/silent-failure-hunter.md:39-125` | Fossils from another codebase (`constants/errorIds.ts`, Sentry/Statsig helpers) produce false findings. | H | File upstream. |
| PL5 | `claude-md-management/…/revise-claude-md.md:20`, `:25` | It writes to `.claude.local.md`. Claude Code loads `CLAUDE.local.md`. | H | File upstream. Correct the filename when you use it. |
| PL6 | `sdd/…/conventions/SKILL.md:45`, `:82-89` | "commit after each phase", "Never sign commits with the Claude signature". These conflict with the harness commit rule and the attribution rule. | H | Decide, then state it in `CLAUDE.md`. |
| PL7 | postman hook + superpowers + sdd + TDD | "Implement this endpoint" gets four mandatory entry points, and no file sets the order. | H | Set the order in `CLAUDE.md`. |
| PL8 | session tool list | Two Snyk MCP servers are live (`mcp__Snyk__*` and the sdd-bundled `mcp__plugin_sdd_snyk__*`), so "run snyk_code_scan" is ambiguous. | M | Remove one. |
| PL9 | `commit-commands/…/commit.md:17`; `commit-push-pr.md:20` | "Do not send any other text" (an update suppressor), so you get no preview of the commit message. Your own commit skills are deleted, so this is now the only commit skill. | M | Disable it if you do not use it. |
| PL10 | `code-review/…/code-review.md`, `commit-push-pr.md`, `review-pr.md` | These are GitHub-only (`gh`). Your work PRs are on Bitbucket. | M | Use them only on GitHub forks. |
| PL11 | `pr-review-toolkit/…/code-reviewer.md:3` | "proactively after writing or modifying code". You can get two reviews, because it is in addition to your own `code-reviewer`. | M | Disable it. |
| PL12 | superpowers TDD / subagent-driven-development / finishing-a-branch | "Delete it. Start over"; "decide them … keep going"; "Merge / Push / PR". These conflict with `CLAUDE.md:7`, `:11`, `:133` and with sdd "never push". | M | Add overrides to `CLAUDE.md`. |
| PL13 | `sdd/…/analyze-context/SKILL.md:73` | "The optimized document MUST be shorter". This uses length as the goal. | M | Do not use it for model re-baselining. |
| PL15 | collisions | There are 5 code-review entry points, 2 `code-reviewer` agents, 4 skill-creators, and 2 debugging triggers (`debugger` and `systematic-debugging`). | M | Keep one of each. |

The other plugins are clean: frontend-design, skill-creator (plugin), context7, security-guidance and typescript-lsp. The other synced skills are clean too.
