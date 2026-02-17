#!/bin/bash
# ralph-exec.sh - Run Ralph build loop for builder skill
#
# Usage: ./ralph-exec.sh <plan-dir> [phase|max-iterations|all]
#
# Examples:
#   ./ralph-exec.sh .claude/plans/my-feature              # interactive picker
#   ./ralph-exec.sh .claude/plans/my-feature phase1       # build all pending in phase 1
#   ./ralph-exec.sh .claude/plans/my-feature 5            # build next 5 tasks
#   ./ralph-exec.sh .claude/plans/my-feature all          # build everything
#
# Logs are saved to <plan-dir>/logs/

set -euo pipefail

PLAN_DIR="${1:?Usage: ralph-exec.sh <plan-dir> [phase|max-iterations|all]}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check dependencies
for DEP in jq yq; do
  if ! command -v "$DEP" &>/dev/null; then
    echo -e "${RED}Error: $DEP is required. Install with: brew install $DEP${NC}"
    exit 1
  fi
done

# Validate plan directory
STATE_FILE="$PLAN_DIR/state.yaml"
if [[ ! -f "$STATE_FILE" ]]; then
  echo -e "${RED}Error: No state.yaml found in $PLAN_DIR${NC}"
  exit 1
fi

# Check for implementation plans (per-task directories)
if ! ls -d "$PLAN_DIR/impl/"phase*/ &>/dev/null 2>&1; then
  echo -e "${RED}Error: No implementation phase directories found in $PLAN_DIR/impl/${NC}"
  echo "  Expected: impl/phase1/, impl/phase2/, etc."
  echo "  Run split-impl.py first if you have monolithic impl files."
  exit 1
fi

# --- Task Selection Functions ---

select_next_task() {
  # Returns: task ID, ALL_COMPLETE, or ALL_BLOCKED
  local FILTER="${PHASE_FILTER:-}"
  yq -o json '.tasks' "$STATE_FILE" | jq -r --arg phase "$FILTER" '
    [to_entries[] | select(.value.status == "complete") | .key] as $complete |
    [to_entries[] | select(.value.status == "pending") |
     select(if $phase != "" then (.key | startswith($phase + "-")) else true end) |
     select(
       (.value.blockedBy // []) as $deps |
       ($deps | length == 0) or ($deps | all(. as $dep | $complete | any(. == $dep)))
     )] |
    if length > 0 then .[0].key
    elif [to_entries[] |
      select(if $phase != "" then (.key | startswith($phase + "-")) else true end) |
      select(.value.status != "complete")] | length == 0 then "ALL_COMPLETE"
    else "ALL_BLOCKED"
    end
  '
}

task_id_to_paths() {
  local TASK_ID="$1"
  local PHASE=$(echo "$TASK_ID" | sed 's/-task.*//')
  local TASK_NUM=$(echo "$TASK_ID" | sed 's/phase[0-9]*-task//')
  echo "$PLAN_DIR/impl/$PHASE/context.md $PLAN_DIR/impl/$PHASE/task${TASK_NUM}.md"
}

count_pending_in_phase() {
  local PHASE="$1"
  yq -o json '.tasks' "$STATE_FILE" | jq -r --arg phase "$PHASE" '
    [to_entries[] | select(.key | startswith($phase + "-")) | select(.value.status == "pending")] | length
  '
}

show_phase_status() {
  echo "Phase Status:"
  yq -o json '.tasks' "$STATE_FILE" | jq -r '
    to_entries | group_by(.key | split("-task")[0]) | .[] |
    (.[0].key | split("-task")[0]) as $phase |
    ([.[] | select(.value.status == "complete")] | length) as $done |
    (length) as $total |
    ($total - $done) as $remaining |
    "  \($phase):  \($done)/\($total) complete (\($remaining) remaining)"
  '
}

# --- Scope Argument Parsing ---

SCOPE_ARG="${2:-}"
PHASE_FILTER=""
MAX_ITERATIONS=50

if [[ -z "$SCOPE_ARG" ]]; then
  # Interactive picker
  show_phase_status
  echo ""
  read -rp "Which phase? (e.g. phase1, or a number, or 'all'): " SCOPE_ARG
fi

if [[ "$SCOPE_ARG" =~ ^phase[0-9]+$ ]]; then
  PHASE_FILTER="$SCOPE_ARG"
  PENDING=$(count_pending_in_phase "$PHASE_FILTER")
  MAX_ITERATIONS="$PENDING"
  echo -e "${CYAN}Scoped to $PHASE_FILTER ($PENDING pending tasks)${NC}"
elif [[ "$SCOPE_ARG" =~ ^[0-9]+$ ]]; then
  MAX_ITERATIONS="$SCOPE_ARG"
elif [[ "$SCOPE_ARG" == "all" ]]; then
  MAX_ITERATIONS=100
fi

# Setup logging directory
LOG_DIR="$PLAN_DIR/logs"
mkdir -p "$LOG_DIR"
SUMMARY_FILE="$LOG_DIR/run-summary.md"

# Initialize run summary
RUN_START=$(date '+%Y-%m-%d %H:%M:%S')
cat > "$SUMMARY_FILE" << EOF
# Ralph Run Summary

Started: $RUN_START
Max iterations: $MAX_ITERATIONS
Phase filter: ${PHASE_FILTER:-none}

## Iterations

| # | Task | Status | Peak Context | Output Tokens | Turns | Cost |
|---|------|--------|-------------|---------------|-------|------|
EOF

# Initialize or append to findings file
FINDINGS_FILE="$PLAN_DIR/findings.md"
if [[ ! -f "$FINDINGS_FILE" ]]; then
  cat > "$FINDINGS_FILE" << EOF
# Build Findings

Accumulated notes from Ralph build runs. Each run appends its findings.

---

EOF
fi

# Append run header to findings
cat >> "$FINDINGS_FILE" << EOF
## Run: $RUN_START

### Issues & Workarounds

EOF

echo -e "${GREEN}Ralph loop starting${NC}"
echo "  Plan: $PLAN_DIR"
echo "  Max iterations: $MAX_ITERATIONS"
echo "  Phase filter: ${PHASE_FILTER:-none}"
echo "  Logs: $LOG_DIR"
echo ""

# Running totals
MAX_PEAK_CONTEXT=0
TOTAL_OUTPUT_TOKENS=0
TOTAL_COST=0

# Finalize the summary file with totals
finalize_summary() {
  local EXIT_REASON="$1"
  local RUN_END=$(date '+%Y-%m-%d %H:%M:%S')

  cat >> "$SUMMARY_FILE" << EOF

## Summary

- **Ended:** $RUN_END
- **Exit reason:** $EXIT_REASON
- **Iterations:** $ITERATION
- **Max peak context:** $MAX_PEAK_CONTEXT
- **Total output tokens:** $TOTAL_OUTPUT_TOKENS
- **Total cost:** \$$TOTAL_COST

## Notes

Subagent token usage (code-reviewer, etc.) runs in separate context windows and is NOT included in the above totals. Each subagent has its own fresh context.
EOF

  # Finalize findings file
  cat >> "$FINDINGS_FILE" << EOF
### Run Summary

- Ended: $RUN_END
- Exit reason: $EXIT_REASON
- Iterations: $ITERATION
- Total cost: \$$TOTAL_COST

---

EOF

  echo ""
  echo -e "${CYAN}=== Run Summary ===${NC}"
  echo "  Iterations: $ITERATION"
  echo "  Max peak context: $MAX_PEAK_CONTEXT"
  echo "  Total output tokens: $TOTAL_OUTPUT_TOKENS"
  echo "  Total cost: \$$TOTAL_COST"
  echo "  Summary: $SUMMARY_FILE"
  echo "  Findings: $FINDINGS_FILE"
}

ITERATION=0
CONSECUTIVE_FAILURES=0
MAX_CONSECUTIVE_FAILURES=3

while [[ $ITERATION -lt $MAX_ITERATIONS ]]; do
  ITERATION=$((ITERATION + 1))
  echo -e "${YELLOW}--- Iteration $ITERATION of $MAX_ITERATIONS ---${NC}"

  # Pre-loop task selection (resolve before invoking Claude)
  TASK_ID=$(select_next_task)

  if [[ "$TASK_ID" == "ALL_COMPLETE" ]]; then
    echo -e "${GREEN}All tasks complete!${NC}"
    echo "| $ITERATION | all | COMPLETE | - | - | - | - |" >> "$SUMMARY_FILE"
    finalize_summary "SUCCESS"
    exit 0
  elif [[ "$TASK_ID" == "ALL_BLOCKED" ]]; then
    echo -e "${YELLOW}All remaining tasks are blocked. Check dependencies.${NC}"
    echo "| $ITERATION | blocked | BLOCKED | - | - | - | - |" >> "$SUMMARY_FILE"
    finalize_summary "BLOCKED"
    exit 2
  fi

  echo -e "  Task: ${CYAN}$TASK_ID${NC}"

  # Map task ID to file paths
  PATHS=$(task_id_to_paths "$TASK_ID")
  CONTEXT_FILE=$(echo "$PATHS" | awk '{print $1}')
  TASK_FILE=$(echo "$PATHS" | awk '{print $2}')

  # Verify files exist
  if [[ ! -f "$CONTEXT_FILE" ]]; then
    echo -e "${RED}Error: Context file not found: $CONTEXT_FILE${NC}"
    CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
    echo "| $ITERATION | $TASK_ID | MISSING_FILE | - | - | - | - |" >> "$SUMMARY_FILE"
    if [[ $CONSECUTIVE_FAILURES -ge $MAX_CONSECUTIVE_FAILURES ]]; then
      finalize_summary "FAILED (missing files)"
      exit 1
    fi
    continue
  fi
  if [[ ! -f "$TASK_FILE" ]]; then
    echo -e "${RED}Error: Task file not found: $TASK_FILE${NC}"
    CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
    echo "| $ITERATION | $TASK_ID | MISSING_FILE | - | - | - | - |" >> "$SUMMARY_FILE"
    if [[ $CONSECUTIVE_FAILURES -ge $MAX_CONSECUTIVE_FAILURES ]]; then
      finalize_summary "FAILED (missing files)"
      exit 1
    fi
    continue
  fi

  # Build the prompt for this specific task
  TASK_PROMPT="You are a task builder. Build task **$TASK_ID**.

## Files to Read
1. $PLAN_DIR/state.yaml — Task statuses (update after completion)
2. $CONTEXT_FILE — Phase context, patterns, dependencies
3. $TASK_FILE — Task specification

## Build Steps
1. Read the phase context file for patterns and conventions
2. Read the task spec file for implementation details
3. Implement ONLY task $TASK_ID
4. Create a unit test for the task (unbiased verification)
5. Run the task's validation commands
6. If validation fails: output RALPH_TASK_FAILED $TASK_ID, keep status in_progress, exit
7. Run code review on uncommitted changes
   - Write findings to $PLAN_DIR/reviews/task-${TASK_ID}-review.md
   - Categorize as CRITICAL / IMPORTANT / SUGGESTION
8. Apply code review fixes:
   - Fix all CRITICAL issues (required)
   - Fix IMPORTANT issues if straightforward
   - For issues requiring architectural changes or unclear fixes:
     - Do NOT attempt fix
     - Add to review file: 'Deferred: [issue] - requires human decision'
     - Set escalated: true in state.yaml
9. Re-validate after code review fixes (run validation commands again)
   - If re-validation fails: output RALPH_TASK_FAILED $TASK_ID, exit
10. Run security review on uncommitted changes (spawn security-reviewer)
    - Write findings to $PLAN_DIR/reviews/task-${TASK_ID}-security.md
    - Categorize as CRITICAL / IMPORTANT / INFO
11. Apply security fixes (if CRITICAL findings):
    - Fix all CRITICAL security issues (exploitable vulnerabilities)
    - For unclear or risky fixes:
      - Do NOT attempt fix
      - Add to security file: 'Escalated: [issue] - requires human decision'
      - Set escalated: true in state.yaml
12. Re-validate after security fixes (if any fixes applied)
    - If re-validation fails: output RALPH_TASK_FAILED $TASK_ID, exit
13. Commit and update state:
    - Commit changes: feat(<project>): <task description>
    - Get commit hash: git rev-parse --short HEAD
    - Update state.yaml: status=complete, validation=passed, reviewed=true, security_reviewed=true, escalated=<bool>, commit=<hash>
    - Output: RALPH_TASK_COMPLETE $TASK_ID (or RALPH_TASK_COMPLETE_ESCALATED if escalated=true)

## Output Signals (exactly one per run)
- RALPH_TASK_COMPLETE <id> - Task finished successfully
- RALPH_TASK_COMPLETE_ESCALATED <id> - Task finished but has deferred issues for developer
- RALPH_TASK_FAILED <id> - Task validation failed

## Findings (always include if any)
After your signal, include a RALPH_FINDINGS block if you encountered anything notable:
\`\`\`
RALPH_FINDINGS
- [issue/workaround/deviation/decision]
RALPH_FINDINGS_END
\`\`\`

## Rules
- Build exactly ONE task: $TASK_ID
- Never skip validation
- Always commit on success (before updating state.yaml)
- Always record commit hash in state.yaml
- Always update state.yaml after commit
- Exit cleanly after updating state
"

  # Log file for this iteration
  ITER_LOG="$LOG_DIR/iteration-$(printf '%03d' $ITERATION).log"
  STREAM_FILE="$LOG_DIR/iteration-$(printf '%03d' $ITERATION).jsonl"

  # Run Claude with isolated context, capture stream-json for accurate metrics
  if claude -p "$TASK_PROMPT" --dangerously-skip-permissions --output-format=stream-json 2>"$ITER_LOG" >"$STREAM_FILE"; then

    # Extract result text from stream
    RESULT=$(jq -r 'select(.type == "result") | .result // "No result"' "$STREAM_FILE" 2>/dev/null || echo "Parse error")

    # Peak context = max per-turn (input + cache_create + cache_read)
    PEAK_CONTEXT=$(jq -r '
      select(.type == "assistant" and .message.usage) |
      .message.usage |
      .input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens
    ' "$STREAM_FILE" 2>/dev/null | sort -n | tail -1)
    PEAK_CONTEXT=${PEAK_CONTEXT:-0}

    # Output tokens from result event
    OUTPUT_TOKENS=$(jq -r 'select(.type == "result") | .usage.output_tokens // 0' "$STREAM_FILE" 2>/dev/null || echo "0")

    # Turn count
    NUM_TURNS=$(jq -c 'select(.type == "assistant" and .message.usage)' "$STREAM_FILE" 2>/dev/null | wc -l | tr -d ' ')

    # Cost from result event
    COST=$(jq -r 'select(.type == "result") | .total_cost_usd // 0' "$STREAM_FILE" 2>/dev/null || echo "0")

    # Update running totals
    if [[ "$PEAK_CONTEXT" -gt "$MAX_PEAK_CONTEXT" ]] 2>/dev/null; then
      MAX_PEAK_CONTEXT="$PEAK_CONTEXT"
    fi
    TOTAL_OUTPUT_TOKENS=$((TOTAL_OUTPUT_TOKENS + OUTPUT_TOKENS))
    TOTAL_COST=$(echo "$TOTAL_COST + $COST" | bc)

    # Write result to log file for readability
    echo "$RESULT" >> "$ITER_LOG"

    # Display token usage
    echo -e "${CYAN}  Tokens: ${PEAK_CONTEXT} peak / ${OUTPUT_TOKENS} out / ${NUM_TURNS} turns | Cost: \$$COST${NC}"

    # Check output for signals
    if echo "$RESULT" | grep -q "RALPH_TASK_COMPLETE_ESCALATED"; then
      STATUS="escalated"
      echo -e "${YELLOW}Task $TASK_ID complete with escalations${NC}"
      echo -e "${YELLOW}  Review deferred issues in reviews/task-${TASK_ID}-review.md${NC}"
      CONSECUTIVE_FAILURES=0
    elif echo "$RESULT" | grep -q "RALPH_TASK_COMPLETE"; then
      STATUS="complete"
      echo -e "${GREEN}Task $TASK_ID complete${NC}"
      CONSECUTIVE_FAILURES=0
    elif echo "$RESULT" | grep -q "RALPH_TASK_FAILED"; then
      STATUS="FAILED"
      echo -e "${RED}Task $TASK_ID failed${NC}"
      CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))

      if [[ $CONSECUTIVE_FAILURES -ge $MAX_CONSECUTIVE_FAILURES ]]; then
        echo -e "${RED}Too many consecutive failures ($MAX_CONSECUTIVE_FAILURES). Stopping.${NC}"
        echo "| $ITERATION | $TASK_ID | $STATUS | $PEAK_CONTEXT | $OUTPUT_TOKENS | $NUM_TURNS | \$$COST |" >> "$SUMMARY_FILE"
        finalize_summary "FAILED (consecutive failures)"
        exit 1
      fi
    else
      STATUS="no-signal"
    fi

    # Add row to summary table
    echo "| $ITERATION | $TASK_ID | $STATUS | $PEAK_CONTEXT | $OUTPUT_TOKENS | $NUM_TURNS | \$$COST |" >> "$SUMMARY_FILE"

    # Extract and append findings if present
    if echo "$RESULT" | grep -q "RALPH_FINDINGS"; then
      FINDINGS=$(echo "$RESULT" | sed -n '/RALPH_FINDINGS/,/RALPH_FINDINGS_END/p' | grep -v "RALPH_FINDINGS")
      if [[ -n "$FINDINGS" ]]; then
        echo "**Iteration $ITERATION ($TASK_ID):**" >> "$FINDINGS_FILE"
        echo "$FINDINGS" >> "$FINDINGS_FILE"
        echo "" >> "$FINDINGS_FILE"
      fi
    fi

  else
    echo -e "${RED}Claude exited with error${NC}"
    echo "| $ITERATION | $TASK_ID | ERROR | - | - | - | - |" >> "$SUMMARY_FILE"
    CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))

    if [[ $CONSECUTIVE_FAILURES -ge $MAX_CONSECUTIVE_FAILURES ]]; then
      echo -e "${RED}Too many consecutive failures. Stopping.${NC}"
      finalize_summary "FAILED (claude error)"
      exit 1
    fi
  fi

  # Small delay between iterations (rate limiting)
  sleep 2
done

echo -e "${YELLOW}Max iterations ($MAX_ITERATIONS) reached${NC}"
finalize_summary "MAX_ITERATIONS"
exit 0
