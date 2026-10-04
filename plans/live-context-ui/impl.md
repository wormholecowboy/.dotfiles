# ernie — Implementation Plan

**Status:** ready to build · **Updated:** 2026-10-03

`plan.md` is the spec (what ernie is and why). This doc is the build order: the task list, file layout, APIs, tests and "done when" checks for each phase. §0 records the changes made to the spec while planning, and why. All of them are decided and folded into `plan.md`.

Every phase ends with a **review stop**. Nothing in a later phase starts until you've reviewed the earlier one.

---

## 0. Spec amendments

Gaps found while turning the spec into tasks. All decided 2026-10-03 and folded into `plan.md`.

| # | Change | Why | Status |
|---|--------|-----|--------|
| A1 | **Global hooks, gated by the log existing.** Hooks live in `claude/.claude/settings.json`. A branch is "on" only when `ernie init` has created its log. Add `ernie off` (writes a `<branch>.off` marker so hooks and CLI writes do nothing) and `ernie where` (prints key, path, on/off, server URL) | Resolves the open hooks question in `queue.md` with the option it recommends. One config for every repo, nothing to add per repo, and repos without a log are unaffected | accepted |
| A2 | **CLI writes need an existing log.** `ernie plan add` with no log exits 1 and prints a hint to run `ernie init`. Claude never runs `init` unless you ask | Otherwise the skill could quietly turn ernie on in every repo Claude touches | accepted |
| A3 | **Repo key comes from `git rev-parse --git-common-dir`**, not `--show-toplevel` | Worktrees of the same repo share one key. The branch already tells their logs apart, and git won't check out one branch in two worktrees | accepted |
| A4 | **Repo slug is the readable basename** (`dotfiles`), and becomes `dotfiles-3f2a1c` only if a different repo already uses that name. A `.root` file in each repo dir records which repo owns it | Markers in `queue.md` stay readable: `(ernie:dotfiles/main#p5)` | accepted |
| A5 | **Rebase and bisect branch detection:** if HEAD is detached, read `<git-dir>/rebase-merge/head-name`, then `rebase-apply/head-name`. Fall back to the short SHA only if neither exists | Otherwise a mid-rebase session writes to a throwaway `<sha>.jsonl` log | accepted |
| A6 | **Read, change and append under one lock.** Next-id lookup + append, inbox + turn mark, and the Stop check + `stop remind` each run inside one `flock` | Without this, two parallel `ernie plan add` calls (e.g. subagents) can both get `p4`, and a page POST that lands between reading the inbox and appending the turn mark gets lost | accepted |
| A7 | **The Stop hook only nags when files were edited** (`file touch`), not when only commands ran | A turn that only runs `ls`/`grep`/tests shouldn't be told to log anything | accepted |
| A8 | **`SessionStart` also matches `startup`** (still only when a log exists) | D4 says state survives new sessions. It's also how Claude learns ernie is on for this branch | accepted |
| A9 | **`mem sync` stores a byte-offset cursor (`upto`) instead of `at`.** `ernie mem delta` prints `cursor=<n>`, and `ernie mem synced <n>` records it | `*um` takes a while. Hook events appended between `delta` and `synced` would be skipped (if `synced` uses "now") or would depend on timestamps being unique. Offsets in an append-only file are exact | accepted |
| A10 | **PostToolUse skips Bash calls that run `ernie`** | Otherwise every log write also logs a `cmd run` about itself | accepted |
| A11 | **Host header allowlist on every request** (`127.0.0.1:<port>`, `localhost:<port>`) | Blocks DNS rebinding. Without it, a rebinding page can `GET /` and read the token out of the served HTML. The Origin check only protects POSTs | accepted |
| A12 | **State carries `pending` and `inboxText`**: your events since the last turn mark, plus the exact text the hook will inject | The page's outbox and preview come from the server (D3), using the same Go function the hook uses. The mock's client-side outbox goes away | accepted |
| A13 | **State caps `activity` at the last 200 entries** | Each SSE frame sends the full state, and the log gains a line on every tool call | changed: cap at 350 |
| A14 | **New `meta init` event** (`root`, `name`) as the first line of every log | The page shows paths relative to the repo root, and the index page can show the repo name | accepted |
| A15 | **New CLI commands `ernie answer <id> <text>` and `ernie fact dismiss <id>`** | When you answer in the terminal, Claude needs a way to close the question. Without it, it stays open forever | accepted |
| A16 | **Flags can go anywhere.** Use a small hand-written parser, since stdlib `flag` stops at the first positional arg | `ernie decide "x" --why "y"` from the spec doesn't parse with plain `flag` | changed: use cobra (pflag interspersed flags, subcommands, help, zsh completion); drops stdlib-only for this one dep |
| A17 | **`ts` has millisecond precision** (`2026-10-02T14:03:11.042Z`) | Keeps the activity feed in a stable order when several events land in the same second | accepted |
| A18 | **Add `"Bash(ernie:*)"` to the settings.json `allow` list** | Otherwise every log write prompts for permission | accepted |
| A19 | **Log files are `0600` and the state dir is `0700`** | `cmd run` events can contain secrets typed on the command line | accepted |
| A20 | **Redact `cmd run` text before writing.** A pure `Redact(cmd)` masks `*_TOKEN/KEY/SECRET/PASSWORD=…` assignments, `Bearer …`, values after `--password`/`--token`-style flags, and known key prefixes (`ghp_`, `sk-`, `AKIA`, `xox`) as `‹redacted›`. Best-effort; logs stay out of git and `mem delta` never carries `cmd` events | Secrets typed on the command line would otherwise sit in the log and show on the page | accepted |

---

## 1. Repo layout (`~/things/myc/ernie`)

```
ernie/
  go.mod                        module ernie (rename if you ever publish it)
  cmd/ernie/main.go             sets version, calls cli.Execute()
  internal/logfile/             knows bytes and files, nothing about events
    key.go                      Resolve(cwd) → Key{Slug, Name, Branch, Root}
    path.go                     StateDir(), Path(Key), OffPath(Key)
    lock.go                     Create(path, line), Update(path, fn), AppendExisting(path, lines)
    tail.go                     Tailer{offset, fileInfo}.Read()
  internal/state/               pure: no I/O
    event.go                    Event, type/op constants, UserOps allowlist
    state.go                    State, (*State).Apply(Event), Fold([]Event)
    ids.go                      NextID(state, prefix)
    inbox.go                    Inbox(state) → []Event, InboxText(...)
    dump.go                     Dump(state) → string
    delta.go                    MemDelta(before, after, window) (phase 4)
  internal/cli/                 cobra: root.go + one file per command group
  internal/hook/                phase 2; redact.go is pure (A20)
  internal/server/              phase 3; page/index.html via go:embed
  testdata/                     golden files, real hook payload fixtures
  install.sh
  README.md
```

Why this split: `logfile` can be tested with plain bytes, `state` is pure and tested from event slices, and `hook`/`server` stay thin layers over both. Stdlib only, except `spf13/cobra` (and its `pflag`) for the CLI (A16). Only `internal/cli` imports it.

### Dev loop and `install.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
go vet ./... && go test -race ./...
bin_dir="${ERNIE_BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$bin_dir"
tmp_bin="$(mktemp "$bin_dir/.ernie.XXXXXX")"
trap 'rm -f "$tmp_bin"' EXIT
go build -trimpath -ldflags "-s -w -X main.version=$(git describe --always --dirty)" -o "$tmp_bin" ./cmd/ernie
chmod 0755 "$tmp_bin"
mv -f "$tmp_bin" "$bin_dir/ernie"
```

- **Why the temp file + `mv`:** hooks exec `ernie` on every tool call. `go build -o ~/.local/bin/ernie` writes the binary in place, so a hook can exec a half-written file. On macOS, overwriting a signed binary in place also gets the next exec SIGKILLed, because the kernel caches the signature per inode. `mv` swaps in a new inode in one atomic step.
- **Dev without touching the real logs:** `ERNIE_HOME=$(mktemp -d) go run ./cmd/ernie …`. Every path goes through `StateDir()`, which reads `ERNIE_HOME`, then `$XDG_STATE_HOME/ernie`, then `~/.local/state/ernie`.
- **After `install.sh`:** restart the `ernie serve` pane (Ctrl-C, ↑, Enter). The page reconnects by itself.
- `ernie version` prints the `git describe` string, so you can tell which build the hooks are running.

---

## Phase 1 — Core

**Goal:** a working CLI that writes and folds logs. No hooks, no server.

### Tasks

| # | Task | Notes |
|---|------|-------|
| 1.1 | Bootstrap the repo: `git init`, `go mod init ernie`, `install.sh`, README stub, `.gitignore` (binary). Move `plans/live-context-ui/*` into `docs/` (D10): `git rm` them from dotfiles and point the `.mem/long.md` reference line at the new path. Run `/mem` in the new repo to start its `.mem/`, and move the `[ernie]` items from dotfiles `queue.md` into it | Commit: `chore: bootstrap` |
| 1.2 | `logfile.Resolve(cwd)` | One `git -C <cwd> rev-parse --path-format=absolute --git-common-dir --git-dir --show-toplevel` call (git 2.50 supports it; checked). Branch comes from reading `<git-dir>/HEAD` directly (`ref: refs/heads/x` → `x`), so no second subprocess. Detached → A5 → short SHA. Not a repo → slug `cwd-<sha1(cwd)[:8]>`, branch `_`. Run git with a context deadline the caller passes: 300ms from hooks, 800ms from the CLI |
| 1.3 | Slug + `.root` collision check (A4), and branch file escaping | Escape `%` → `%25` and `/` → `%2F` in the file name. The URL and markers use the raw branch. `Resolve` reads `.root` on every call (one small file read, microseconds). It must: the basename folder may belong to a different repo, and skipping the check on the hook path would append to that repo's log |
| 1.4 | `logfile.Create(path, line)`, `Update(path, fn)` and `AppendExisting(path, lines)` | `Create` (only `ernie init` calls it): `MkdirAll` the dir at `0700`, open `O_WRONLY\|O_CREATE\|O_EXCL` at `0600` (A19), write the `meta init` line (A14). `EEXIST` → report "already on", not an error. `Update`: open `O_RDWR\|O_APPEND`, `flock(LOCK_EX\|LOCK_NB)` retried every 5ms up to the deadline (CLI 2s, hooks 300ms), read the whole file, `fn(existing) → newLines`, then write all new lines in **one** `Write`. `AppendExisting` never uses `O_CREATE`, so a missing log means a no-op. That *is* the A1 gate, with no stat-then-open race. It also takes `flock(LOCK_EX\|LOCK_NB)` with the caller's deadline (hooks 300ms), so every writer locks the same way. Each line is capped at 1 MiB |
| 1.5 | `state.Event` | One flat struct with typed `omitempty` fields (`Text, Why, Status, Tag, Choices, Name, Mermaid, Path, Tool, Cmd, Exit *int, N, Upto, Ref, Agent, Root`). Marshal with `json.Encoder` + `SetEscapeHTML(false)` so `<br/>` in mermaid survives. Unknown fields are dropped on read, which is fine because the log is never rewritten |
| 1.6 | `State`, `(*State).Apply`, `Fold` | Applies events in place, with no I/O (the spec's "pure" holds in practice). Unexported id→index maps. Behavior follows the spec's case table, plus A12/A13/A14. Turn-scoped fields live directly on `State`: `TurnFileTouched`, `TurnClaudeLogged`, `TurnReminded` (bools) and `pending`. `Apply` resets all four and bumps `Turn` on each `turn mark`. `activity` (last 350 entries) is display-only; nothing reads it for logic |
| 1.7 | `NextID(state, prefix)` | Max numeric suffix seen for that prefix across **all** events (including dropped items and warnings) + 1, so ids are never reused |
| 1.8 | `Dump(state)` | Format from the spec, plus a header line `ernie · dotfiles/main · turn 12 · log with ernie (see ernie skill)`. Caps: every open item in full, the last 5 done/answered with a `+N more`, diagram names only. Target ≤ 1.5 KB, hard cap 4 KB |
| 1.9 | `Inbox` / `InboxText` | `Inbox(state)` returns `state.pending`: `by:user` events after the last turn mark, limited to the user ops (`question answer`, `plan set`, `note add`, `fact dismiss`). `meta` events are excluded even though `ernie init` writes them as `by:user`. `InboxText` renders them with context (`answered q3 "Where does the source live?" → ~/things/myc/ernie`) so Claude doesn't need to look anything up |
| 1.10 | Cobra root (`cli/root.go`) | `go get github.com/spf13/cobra`. Root sets `SilenceUsage` and `SilenceErrors` (main prints the error and exits 1). pflag gives interspersed flags, `--k v`, `--k=v`, `StringArray` for repeatable `--choice` (not `StringSlice`, which splits on commas), and `--` to end flags. Unknown flag → error. Positional counts via `cobra.ExactArgs` etc. `ernie completion zsh` comes free; add it to the zsh config in 4.6. Root's `Version` is set from `main.version` |
| 1.11 | Commands: `init`, `off`, `where`, `version`, `plan add/set`, `decide`, `ask`, `answer`, `fact` / `fact dismiss`, `diagram <name>` (stdin; error if stdin is a TTY), `dump`, `inbox` | `init` creates the log via `Create` and removes any `.off` marker, so it also turns a branch back on. Write commands print only the new id on stdout. Errors go to stderr with exit 1. `--tag` works on plan/decide/ask/fact (moved here from phase 4; it's just a field) |

### Tests (each with expected / edge / failure, per your rule)

| Unit | Expected | Edge | Failure |
|---|---|---|---|
| `Resolve` | repo + branch | worktree shares the main repo's slug; `feature/x`; rebase in progress (write `rebase-merge/head-name` by hand) | not a repo → cwd-hash fallback |
| slug collision | first repo gets `dotfiles` | second repo with the same basename → `dotfiles-<hash>` | unreadable `.root` → hashed slug, no crash |
| `Update` | line written under the lock | 20 goroutines × separate fds, each `plan add` → 20 unique ids, every line parses | lock held past the deadline → timeout error |
| `AppendExisting` | appends to an existing log | quotes/newlines/`<br/>` round-trip | missing log → no-op, no file created |
| `Fold` | add → set → done | set before add; duplicate add; a turn with >350 events still reports `TurnFileTouched` and `pending` correctly | malformed line → skipped + warning |
| `NextID` | `p3` after p1, p2 | gap (p1, p7) → `p8` | no events → `p1` |
| `Dump` | golden file (`-update` flag rewrites it) | empty state | over the cap → truncated with `+N more` |
| `Inbox` | user events after the last mark | no mark yet → all user events | empty log |
| CLI flags (cobra wiring) | flags after positionals; two `--choice` flags → two choices | `--why=a=b`; `--choice "a, b"` stays one choice; text starting with `-` after `--` | missing value → error |
| CLI `init` | creates the log `0600` (dir `0700`) with `meta init` first | already on → "already on", exit 0; `.off` present → removed | not writable state dir → exit 1 |
| CLI `plan add` | prints `p1`, line on disk | `.off` marker → no write + notice | no log → exit 1 + `ernie init` hint |

Real files under `t.TempDir()` with `ERNIE_HOME` set. Real `git init` repos for `Resolve`. No mocks.

**Benchmark:** `BenchmarkFold50k` (50k mixed lines). Budget: under 50ms. If it's over, add a reverse scan from EOF for the turn-scoped reads before phase 2.

### Done when

- `go vet` passes, `go test -race ./...` passes, and `gofmt -l .` prints nothing.
- In a scratch repo, `ernie init && ernie plan add x && ernie plan set p1 done && ernie dump` works.
- `install.sh` installs the binary.
- 50 runs of `ernie version` average under 10ms.
- **Review stop.**

---

## Phase 2 — Hooks

### 2.0 Spike: capture real payloads first (throwaway, never committed)

Use the `validate-assumptions` skill. In a scratch repo, write `.claude/settings.local.json` with one hook per event that copies stdin into `$SCRATCH/hooks/<event>-XXXX.json`. Then trigger:

- Edit, Write, NotebookEdit, and MultiEdit if it still exists
- Bash that succeeds, Bash that fails (`false`), and Bash you interrupt
- one tool call from inside a subagent (does it include `agent_id`/`agent_type`? does PostToolUse fire?)
- UserPromptSubmit
- SessionStart via startup, `/clear`, `/compact`, `--resume`, and a fork (does `source: fork` exist? The docs disagree)
- Stop, then Stop again after a block (is `stop_hook_active` present?)

Also check live:
1. Does a top-level `{"decision":"block","reason":…}` on Stop make Claude continue?
2. Does plain SessionStart stdout show up in context?
3. Does PostToolUse fire for a failed Bash, or does that go to a separate failure event?

Output:
- Sanitized fixtures in `ernie/testdata/hooks/*.json`. These become the test inputs, so the parser is written against real payloads.
- Results added to `.mem/long.md` (`[claude-hooks]`) and to `plan.md` → Hooks.
- The throwaway settings file deleted.

The spike decides three things: where `exit` comes from (or whether `cmd` events record no exit), the notebook path field, and whether `fork` goes in the matcher.

### Tasks

| # | Task | Notes |
|---|------|-------|
| 2.1 | `hook.Run(name, stdin, stdout) int` | `defer recover()` → returns 0. `main` checks `os.Args[1] == "hook"` and calls `hook.Run` directly before building the cobra tree, so cobra never runs on the hook hot path. Cobra still registers `hook` (a single command with `DisableFlagParsing` and `cobra.ArbitraryArgs`, the hook name as a positional) for help and completion only; an unknown name → no-op. Reads stdin through `io.LimitReader` (16 MiB; Write payloads carry file contents) and gives up quietly if it's bigger. Whole-handler deadline 800ms: the handler runs in a goroutine with its own `defer recover()` (a goroutine panic isn't caught by the caller's `recover`). Pipeline: parse → return early if `StateDir()` doesn't exist or is empty (hooks fire on every tool call in every repo) → `Resolve(cwd)` (git deadline 300ms) → gate (log exists, no `.off`) → handler. Any error → silent exit 0. A Go panic exits 2, which Claude Code treats as a blocking error |
| 2.2 | `post-tool-use` | Edit/Write/MultiEdit/NotebookEdit → `file touch {path, tool}`. Bash → `cmd run {cmd: first line, ≤300 chars, exit?}`, with `cmd` passed through `Redact` before truncating (A20). Skip `ernie …` (A10). Add `agent` from `agent_type` when the call comes from a subagent. Anything else → no-op. Uses `AppendExisting`, no fold |
| 2.3 | `user-prompt-submit` | Inside one `Update`: fold, compute the inbox, append `turn mark {n: Turn+1}`. After unlocking, print `InboxText` only if it's non-empty (an empty inbox costs no tokens) |
| 2.4 | `session-start` | Print `Dump` when the gate passes. Writes nothing |
| 2.5 | `stop` | `stop_hook_active` → allow. Inside one `Update`: fold, then `TurnFileTouched && !TurnClaudeLogged && !TurnReminded` → append `stop remind` and print `{"decision":"block","reason":…}`. Reason: *"ernie: files changed this turn but nothing was logged. If plan status, decisions or open questions changed, record them with `ernie plan set` / `decide` / `ask`. If nothing changed, just stop."* The "just stop" option keeps Claude from logging noise |
| 2.6 | Wire into dotfiles `claude/.claude/settings.json` | See below. Add `Bash(ernie:*)` to `allow` (A18), `Bash(ernie init:*)` to `ask` (Claude can't silently turn ernie on; `ask`/`deny` override `allow`), and `Bash(ernie serve:*)` to `deny` (long-running, would hang a Bash call; you run it in a pane). Check `git status` on settings.json first; if anything else is uncommitted, stage only the ernie hunks with `git add -p` |
| 2.7 | Minimal skill `claude/.claude/skills/ernie/SKILL.md` | Lands with the hooks so Claude knows what the SessionStart header and Stop nag mean. Covers: when ernie is on (SessionStart header / `ernie where`); the write commands; what's worth logging (plan items are user-visible steps, not micro-steps; decisions that have a why; questions through `ernie ask`, while still asking in the terminal with Qx/total; `ernie answer` when you answer in the terminal); answering the Stop nag ("just stop" if nothing changed). Never `init`. Never read the log file; use `ernie dump`. Phase 4 extends it (4.3) |

```jsonc
// Each command is guarded: a missing binary or any failure → exit 0
"PostToolUse": [{ "matcher": "Edit|Write|MultiEdit|NotebookEdit|Bash",
  "hooks": [{ "type": "command", "timeout": 5,
    "command": "[ -x \"$HOME/.local/bin/ernie\" ] && \"$HOME/.local/bin/ernie\" hook post-tool-use || true" }] }],
"UserPromptSubmit": [{ "hooks": [{ "type": "command", "timeout": 5, "command": "… hook user-prompt-submit || true" }] }],
"SessionStart": [ /* existing herdr entry stays */,
  { "matcher": "startup|resume|clear|compact|fork", "hooks": [{ "type": "command", "timeout": 5, "command": "… hook session-start || true" }] }],
"Stop": [{ "hooks": [{ "type": "command", "timeout": 5, "command": "… hook stop || true" }] }]
```

Notes on the config:
- `|| true` also catches failures `recover` can't (a fatal runtime error, or the binary being SIGKILLed).
- The Stop block decision is sent as JSON on stdout with exit 0, so `|| true` doesn't interfere with it.
- Set `timeout` explicitly. The default may be as long as 10 minutes (unverified; the 2.0 spike confirms).

### Tests

| Unit | Expected | Edge | Failure |
|---|---|---|---|
| `post-tool-use` | Edit fixture → `file touch` | unknown tool → no-op; `ernie plan …` Bash → no-op | bad stdin JSON → exit 0, nothing written |
| `user-prompt-submit` | user events printed + mark appended | empty inbox → no output, mark still appended | no log → no output, no file created |
| `session-start` | dump printed | `.off` marker → nothing | bad JSON → nothing |
| `stop` | edits, no claude events → block JSON | already reminded this turn → allow; `stop_hook_active` → allow | no log → allow |
| `Redact` | `GH_TOKEN=abc make` → `GH_TOKEN=‹redacted› make`; `-H "Authorization: Bearer x"` masked | `--password=x` and `--password x`; `sk-…` / `ghp_…` / `AKIA…` inside a longer command; `PATH=/usr/bin` left alone | plain command with no secrets → unchanged |
| `Run` | — | — | handler panics → returns 0 |

**Latency check:** 50 runs of `ernie hook post-tool-use < testdata/hooks/edit.json`, aiming for p50 < 10ms including the git call. If it's over, skip the subprocess by reading `.git` / `commondir` directly. Optimize only if the measurement shows it's needed.

### Done when

- Tests pass.
- The ernie skill (2.7) is in place before hooks are wired.
- Dogfood: `ernie init` in `~/things/myc/ernie`, then build phase 3 with hooks on.
- `/clear` brings the dump back.
- The Stop nag fires at most once per turn.
- **Kill-switch check:** `mv ~/.local/bin/ernie{,.bak}` → a session shows no hook errors → move it back.
- **Review stop.**

---

## Phase 3 — Server + page

### Tasks

| # | Task | Notes |
|---|------|-------|
| 3.1 | `ernie serve [--port N]` | Bind `127.0.0.1:${ERNIE_PORT:-7477}` (pick another port if you like; it just needs to avoid the 3000/5173/8000/8080 set). Port in use → exit 1 with `lsof -i :<port>` in the message. `ReadHeaderTimeout: 5s`, no `WriteTimeout` (SSE connections stay open). Logs requests to stdout so they show in the pane |
| 3.2 | Middleware on **every** route | Host allowlist (A11) → 403. Responses set `Cache-Control: no-store`. No CORS headers anywhere |
| 3.3 | `GET /` | Without `?log` → an index of logs (name, branch, last change, on/off), newest first. With `?log=<slug>/<branch>` → the page, served as-is (no token in the HTML). The token is 32 random bytes per server start and reaches the page only through the `hello` frame on `/stream` (3.6), so an `EventSource` reconnect after a restart picks up the new one. Safe because a cross-origin page can't read the SSE response (no CORS headers) and the Host allowlist blocks DNS rebinding |
| 3.4 | Log lookup | Check `log` against `^[A-Za-z0-9._-]+/[^\x00]+$`, reject slug `.` and `..` explicitly, escape the branch, `filepath.Join`, then confirm the result is still inside `StateDir()` and exists. Anything else → 404 |
| 3.5 | Hub + watcher | One goroutine per log that has subscribers. It owns a `Tailer` + `State`. A 250ms ticker or a `poke` channel triggers `Tailer.Read()`: complete lines only; `size < offset` **or** a different file (`!os.SameFile`) → reset and refold. File missing → send `event: gone` to subscribers once and keep polling; if the log reappears (`ernie init`), refold and resume sending `state`. On change: marshal once, then fan out without blocking (each subscriber channel holds 1 frame and a newer frame replaces an unsent one, since only the latest full state matters). One hub mutex owns the subscriber map and starts/stops watchers, so a subscriber joining while a watcher shuts down can't be lost. The watcher stops when the last subscriber leaves |
| 3.6 | `GET /stream` | SSE headers. Every connection starts with `event: hello` (`data: {"token":"…","version":"…"}`), then `event: state` right away, then on each change, plus a `: ping` every 15s so dead clients get noticed. Flushes via `http.NewResponseController`. Unsubscribes on `r.Context().Done()` |
| 3.7 | `GET /state`, `GET /healthz` | `/healthz` returns `{"version":…}` and is used by `ernie open` |
| 3.8 | `POST /events?log=…` | Checks in order: Host → `Origin == "http://" + r.Host` (Host is already allowlisted) (403) → `X-Ernie-Token`, compared in constant time (403) → `Content-Type: application/json` (415) → body ≤ 64 KB (413) → decode into a narrow `userEvent` struct with `DisallowUnknownFields` (400) → op allowlist (400) → field checks: status enum, text 1–4000 chars. Then one `Update` with a 1s deadline; inside its callback, fold and check the id exists (409). The **server** sets `by:user` and `ts`; client values are never trusted. Notes get a `n<k>` id inside the same `Update`. Then poke the watcher and return 204 |
| 3.9 | `ernie open` | Resolve the key, call `GET /healthz` with a 300ms timeout. Down → print `start it: ernie serve` (D8). Up → macOS `open` (v1 is macOS-only) with the `log` query value URL-escaped (`url.QueryEscape`; branches can contain `/`, `%`, `#`) |
| 3.10 | Page: copy `mock.html` to `internal/server/page/index.html` | Swap the mock state for `new EventSource('/stream?log=…')`. `queueUserEvent` → `fetch POST` with the token from the latest `hello` frame. Outbox and preview come from `state.pending` / `state.inboxText` (A12). **Delete the mock's "deliver" button and its simulated Claude reply.** Map `by:user` → "you" in the feed |
| 3.11 | Page render rules | Redraw each panel in full on every frame. Before redrawing questions, save every `[data-answer-input]` value plus the focused element and its selection, then restore them afterwards. Re-render Mermaid only when `name + source` changed. `onerror` → "reconnecting…" banner with the last state still shown; `onopen` hides it. `gone` → "log not found" banner, cleared by the next `state`. Disable a control after a click until the next frame arrives, with no optimistic update (the server is the only source of state, D3) |
| 3.12 | Page hardening | Every bit of text goes through `esc()`, including ids in `data-*`. **Fix the mock bug at `mock.html:593`**: the Mermaid error message goes into `innerHTML` unescaped. Keep `securityLevel: 'strict'`. Pin an exact Mermaid version instead of `@11` |

### Tests

| Unit | Expected | Edge | Failure |
|---|---|---|---|
| `Tailer.Read` | new complete lines, offset advanced | half-written trailing line held until the next read; file removed → `gone`, recreated → `state` again | file shrank or was replaced → reset, refold |
| `GET /stream` | new subscriber gets a `hello` frame carrying the token, then the current state immediately | append → every subscriber gets the new state | unknown log → 404 |
| `POST /events` | valid answer appended with `by:user` | client-sent `by:claude` ignored/overwritten | bad or missing token → 403; disallowed op → 400 |
| security | — | `?log=../../etc/passwd` → 404 | wrong Host → 403 on `GET /`; wrong Origin → 403 on POST |
| state JSON | golden `testdata/state.golden.json` (the page's contract) | empty log | — |

Use `httptest.NewServer`. Read SSE with `bufio.Scanner` under a 2s deadline. No browser in `go test`.

**Manual / agent-browser smoke test (not committed):**
1. Load the page and check every panel renders.
2. Click a plan box and check a `plan set` line is added to the log.
3. Run `ernie plan add` in the terminal and check the page updates within ~250ms.
4. Type into an answer box while an update arrives and check the text survives.
5. Restart the server and check you see "reconnecting…", then recovery, and that **a POST from the page still works** (new token via `hello`).

### Done when

- Tests pass and the smoke test passes.
- You've used the page for one real session.
- **Review stop.**

---

## Phase 4 — `.mem` integration + adoption

| # | Task | Notes |
|---|------|-------|
| 4.1 | `ernie mem delta` | Find the last `mem sync`'s `upto` (0 if none, or if it's past EOF after a reset). `before := Fold(lines[:upto])`, `after := Fold(all)`. Diffing the two folds gives exactly what changed, including **resolved** items (mirrorable in `before`, closed in `after`). Files come from `file touch` events in the window, deduped. Print in the spec's format with a header ending `cursor=<n>`, where `<n>` comes from the same read as the fold: the offset just past the last `\n`. "Nothing new" = the two folds have no item differences **and** the window has no `file touch` events (turn marks, `cmd run`s and `mem sync`s alone don't count; the prompt that runs `*um` always adds a turn mark) → print `nothing new`. No log → exit 0 and print `no ernie log` (so `*um` falls back) |
| 4.2 | `ernie mem synced <cursor>` | Append `mem sync {upto}` (A9). If the cursor equals the last `upto` → no-op. No log → exit 0 |
| 4.3 | Extend the ernie skill (from 2.7) | Add only the phase-4 parts: `--tag` from `.mem/tags.md`; `ernie mem delta` / `ernie mem synced` and how they relate to `*um` (`*um` runs `delta`, `synced` only after `mem-ops` confirms) |
| 4.4 | `mem` skill edits | `*um` step 0 runs `ernie mem delta` and passes the cursor through to `synced` after `mem-ops` confirms. `mem-ops` rules for `(ernie:…)` markers: match on the marker, overwrite the mirror, delete it when resolved. `/mem` resume appends `ernie dump` |
| 4.5 | `gtg` / `handoff` edits | As in the spec's "Other skills" table |
| 4.6 | Dotfiles bookkeeping | `decisions.md` entry. `install.txt`: `GO / ernie: git clone <remote> ~/things/myc/ernie && ~/things/myc/ernie/install.sh`. zsh completion: cache `ernie completion zsh` the same way zoxide's init is cached (regenerate after upgrades). `CLAUDE.md` structure: no change |

### Tests

These are the spec's two `ernie mem` rows, plus one more: an item resolved in the window → it shows up under `resolved` with its marker.

### Done when

- On this repo's real log, the first `*um` creates mirrors with markers.
- A second `*um` with no changes → nothing new.
- Answering a question on the page, then running `*um`, deletes its mirror.
- **Review stop. v1 is done.**

---

## Cross-cutting

### Performance budgets

| Path | Budget | How it's checked |
|---|---|---|
| `ernie <write cmd>` | < 10ms p50 on a typical log (< 5k lines); it folds for `NextID`, so up to the fold budget on 50k lines | 50-run loop |
| `hook post-tool-use` | < 10ms p50 (no fold) | 50-run loop on a fixture |
| hooks that fold (prompt, stop, session-start) on a 50k-line log | < 60ms | `BenchmarkFold50k` + git cost |
| write → page | ≤ 250ms (≈ immediate for page POSTs) | smoke test |
| `ernie dump` output | ≤ 1.5 KB typical, 4 KB cap | golden + cap test |

### Failure modes

| Situation | Behavior |
|---|---|
| Binary missing (other machine) | Guarded hook commands → silent exit 0 |
| Go panic / fatal error in a hook | `recover` → 0, and `|| true` behind it |
| Log deleted mid-session | `AppendExisting` no-ops. The watcher sends `event: gone` and keeps polling; page shows "log not found". If the log reappears (`ernie init`), the watcher refolds and resumes `state`, and the page recovers |
| Log truncated or replaced | Tailer reset → refold. `mem delta` cursor past EOF → full delta |
| Lock contention | Hooks give up after 300ms and drop that one event. CLI errors after 2s |
| Two sessions on one branch | Both append under the lock. Turn marks interleave, so the Stop nag scope gets fuzzier; acceptable for v1 |
| Server down | Hooks and CLI don't care. `ernie open` prints how to start it |
| Not a git repo | cwd-hash key. Works, just not branch-aware |
| Log grows large | Within budget up to ~50k lines. Beyond that, see v1.1 |

### Rollback

- Remove the four hook entries from `settings.json`, or just delete the binary, since the hooks are guarded.
- Logs live outside every repo. `rm -rf ~/.local/state/ernie` resets everything.
- Orphaned `queue.md` mirrors are handled as the spec's edge cases describe.

### Commits

- **ernie repo:** conventional commits per task group (`feat(log): …`, `feat(hook): …`).
- **dotfiles:** phase 2: `feat(claude): wire ernie hooks` (settings.json hunks staged on their own, 2.6) and `feat(claude): add ernie skill` (2.7). Phase 4: `feat(claude): extend ernie skill`, `docs: …`.

---

## Later (not v1)

- **v1.1:** reverse-scan reads for turn-scoped hooks and `ernie archive` (rotate old logs). Only if the benchmark or real use calls for it.
- **launchd agent** for `ernie serve` (D8, "later").
- **v2 channels:** unchanged from the spec. It reuses `Tailer` and `Update` as they are.

## Open

1. ~~Confirm or strike the amendments A1–A19~~ → all decided 2026-10-03 (A13 changed to 350, A16 changed to cobra, A20 added), and folded into `plan.md`.
2. ~~Do the plan docs move into the ernie repo?~~ → yes, at task 1.1 (D10 in `plan.md`).
3. ~~Default port?~~ → 7477, confirmed 2026-10-02. It's an arbitrary pick: not in `/etc/services`, below the ephemeral ranges on macOS (49152+) and Linux (32768+), and nothing was listening on it on 2026-10-02.
