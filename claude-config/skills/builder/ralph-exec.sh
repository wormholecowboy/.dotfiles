#!/bin/bash
# ralph-exec.sh - Run Ralph build loop for builder skill
#
# Usage: ./ralph-exec.sh <plan-dir> [mode] [max-iterations]
#
# Modes:
#   implementation - High planning, watch closely (default)
#   exploration    - Low planning, walk away
#   brute-force    - Testing mode, run overnight
#
# Example:
#   ./ralph-exec.sh .claude/plans/my-feature implementation 20
#
# Logs are saved to <plan-dir>/logs/

set -euo pipefail

PLAN_DIR="${1:?Usage: ralph-exec.sh <plan-dir> [mode] [max-iterations]}"
MODE="${2:-implementation}"
MAX_ITERATIONS="${3:-50}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Token warning threshold (stay below "dumb zone")
TOKEN_WARNING_THRESHOLD=100000

# Check dependencies
if ! command -v jq &>/dev/null; then
  echo -e "${RED}Error: jq is required but not installed${NC}"
  echo "  Install with: brew install jq"
  exit 1
fi

# Validate plan directory
if [[ ! -f "$PLAN_DIR/state.yaml" ]]; then
  echo -e "${RED}Error: No state.yaml found in $PLAN_DIR${NC}"
  exit 1
fi

# Check for implementation plans
if ! ls "$PLAN_DIR/impl/"*.md &>/dev/null; then
  echo -e "${RED}Error: No implementation plans found in $PLAN_DIR/impl/${NC}"
  exit 1
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
Mode: $MODE
Max iterations: $MAX_ITERATIONS

## Iterations

| # | Task | Status | Input Tokens | Output Tokens | Cost |
|---|------|--------|--------------|---------------|------|
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

Mode: $MODE

### Issues & Workarounds

EOF

echo -e "${GREEN}Ralph loop starting${NC}"
echo "  Plan: $PLAN_DIR"
echo "  Mode: $MODE"
echo "  Max iterations: $MAX_ITERATIONS"
echo "  Logs: $LOG_DIR"
echo ""

# Running totals
TOTAL_INPUT_TOKENS=0
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
- **Total input tokens:** $TOTAL_INPUT_TOKENS
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
  echo "  Total tokens: $TOTAL_INPUT_TOKENS in / $TOTAL_OUTPUT_TOKENS out"
  echo "  Total cost: \$$TOTAL_COST"
  echo "  Summary: $SUMMARY_FILE"
  echo "  Findings: $FINDINGS_FILE"
}

# Build the prompt for task building
TASK_PROMPT="You are a task builder for the builder skill running in $MODE mode.

## Your Mission
Build ONE task from the implementation plan, validate it, and exit.

## Files to Read First
1. $PLAN_DIR/state.yaml - Current task statuses and dependencies
2. $PLAN_DIR/impl/*.md - Implementation plans with task details

## Build Steps
1. Parse state.yaml to find eligible tasks (status: pending, all blockedBy complete)
2. If no eligible tasks found:
   - If all tasks complete: output RALPH_COMPLETE
   - If tasks exist but blocked: output RALPH_BLOCKED with details
3. Select the first eligible task
4. Read its full details from the impl plan
5. Implement ONLY that task
6. Create a unit test for the task (unbiased verification)
7. Run the task's validation commands
8. If validation fails: output RALPH_TASK_FAILED <task-id>, keep status in_progress, exit
9. Run code review on uncommitted changes
   - Write findings to $PLAN_DIR/reviews/task-<task-id>-review.md
   - Categorize as CRITICAL / IMPORTANT / SUGGESTION
10. Apply code review fixes:
    - Fix all CRITICAL issues (required)
    - Fix IMPORTANT issues if straightforward
    - For issues requiring architectural changes or unclear fixes:
      - Do NOT attempt fix
      - Add to review file: 'Deferred: [issue] - requires human decision'
      - Set escalated: true in state.yaml
11. Re-validate after code review fixes (run validation commands again)
    - If re-validation fails: output RALPH_TASK_FAILED <task-id>, exit
12. Run security review on uncommitted changes (spawn security-reviewer)
    - Write findings to $PLAN_DIR/reviews/task-<task-id>-security.md
    - Categorize as CRITICAL / IMPORTANT / INFO
13. Apply security fixes (if CRITICAL findings):
    - Fix all CRITICAL security issues (exploitable vulnerabilities)
    - For unclear or risky fixes:
      - Do NOT attempt fix
      - Add to security file: 'Escalated: [issue] - requires human decision'
      - Set escalated: true in state.yaml
14. Re-validate after security fixes (if any fixes applied)
    - If re-validation fails: output RALPH_TASK_FAILED <task-id>, exit
15. Commit and update state:
    - Commit changes: feat(<project>): <task description>
    - Get commit hash: git rev-parse --short HEAD
    - Update state.yaml: status=complete, validation=passed, reviewed=true, security_reviewed=true, escalated=<bool>, commit=<hash>
    - Output: RALPH_TASK_COMPLETE <task-id> (or RALPH_TASK_COMPLETE_ESCALATED if escalated=true)

## Output Signals (exactly one per run)
- RALPH_COMPLETE - All tasks done, loop can stop
- RALPH_BLOCKED - Tasks exist but dependencies not met
- RALPH_TASK_COMPLETE <id> - Task finished successfully
- RALPH_TASK_COMPLETE_ESCALATED <id> - Task finished but has deferred issues for developer
- RALPH_TASK_FAILED <id> - Task validation failed

## Findings (always include if any)
After your signal, include a RALPH_FINDINGS block if you encountered anything notable:
\`\`\`
RALPH_FINDINGS
- [issue/workaround/deviation/decision]
- [another finding]
RALPH_FINDINGS_END
\`\`\`

Examples of findings:
- Issue: API signature changed from docs, had to use v2 method
- Workaround: Test was flaky, added retry logic
- Deviation: Split task into two files instead of one (cleaner)
- Decision: Used async/await instead of callbacks for consistency

## Rules
- Build exactly ONE task per invocation
- Never skip validation
- Always commit on success (before updating state.yaml)
- Always record commit hash in state.yaml
- Always update state.yaml after commit
- Exit cleanly after updating state
"

ITERATION=0
CONSECUTIVE_FAILURES=0
MAX_CONSECUTIVE_FAILURES=3

while [[ $ITERATION -lt $MAX_ITERATIONS ]]; do
  ITERATION=$((ITERATION + 1))
  echo -e "${YELLOW}--- Iteration $ITERATION of $MAX_ITERATIONS ---${NC}"

  # Log file for this iteration
  ITER_LOG="$LOG_DIR/iteration-$(printf '%03d' $ITERATION).log"
  JSON_OUTPUT="$LOG_DIR/iteration-$(printf '%03d' $ITERATION).json"

  # Run Claude with isolated context, capture JSON for metrics
  # Note: In Docker, this would be wrapped with container invocation
  if claude -p "$TASK_PROMPT" --dangerously-skip-permissions --output-format=json 2>"$ITER_LOG" >"$JSON_OUTPUT"; then

    # Extract metrics from JSON output
    if [[ -f "$JSON_OUTPUT" ]]; then
      RESULT=$(cat "$JSON_OUTPUT" | jq -r '.result // "No result"' 2>/dev/null || echo "Parse error")
      INPUT_TOKENS=$(cat "$JSON_OUTPUT" | jq -r '.usage.input_tokens // 0' 2>/dev/null || echo "0")
      CACHE_CREATE=$(cat "$JSON_OUTPUT" | jq -r '.usage.cache_creation_input_tokens // 0' 2>/dev/null || echo "0")
      CACHE_READ=$(cat "$JSON_OUTPUT" | jq -r '.usage.cache_read_input_tokens // 0' 2>/dev/null || echo "0")
      OUTPUT_TOKENS=$(cat "$JSON_OUTPUT" | jq -r '.usage.output_tokens // 0' 2>/dev/null || echo "0")
      COST=$(cat "$JSON_OUTPUT" | jq -r '.total_cost_usd // 0' 2>/dev/null || echo "0")

      # Calculate total context tokens (input + cache)
      CONTEXT_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))

      # Update running totals
      TOTAL_INPUT_TOKENS=$((TOTAL_INPUT_TOKENS + CONTEXT_TOKENS))
      TOTAL_OUTPUT_TOKENS=$((TOTAL_OUTPUT_TOKENS + OUTPUT_TOKENS))
      TOTAL_COST=$(echo "$TOTAL_COST + $COST" | bc)

      # Write result to log file for readability
      echo "$RESULT" >> "$ITER_LOG"

      # Check for token warning
      if [[ $CONTEXT_TOKENS -gt $TOKEN_WARNING_THRESHOLD ]]; then
        echo -e "${RED}WARNING: Context tokens ($CONTEXT_TOKENS) exceeded threshold ($TOKEN_WARNING_THRESHOLD)${NC}"
        echo -e "${RED}         Approaching 'dumb zone' - consider smaller specs${NC}"
      fi

      # Display token usage
      echo -e "${CYAN}  Tokens: $CONTEXT_TOKENS in / $OUTPUT_TOKENS out | Cost: \$$COST${NC}"
    fi

    # Check output for signals (order matters: check specific patterns before general ones)
    if echo "$RESULT" | grep -q "RALPH_COMPLETE"; then
      TASK_ID="all"
      STATUS="COMPLETE"
      echo -e "${GREEN}All tasks complete!${NC}"
      echo "| $ITERATION | $TASK_ID | $STATUS | $CONTEXT_TOKENS | $OUTPUT_TOKENS | \$$COST |" >> "$SUMMARY_FILE"
      finalize_summary "SUCCESS"
      exit 0
    elif echo "$RESULT" | grep -q "RALPH_BLOCKED"; then
      TASK_ID="blocked"
      STATUS="BLOCKED"
      echo -e "${YELLOW}Tasks blocked. Check dependencies.${NC}"
      echo "$RESULT" | grep "RALPH_BLOCKED"
      echo "| $ITERATION | $TASK_ID | $STATUS | $CONTEXT_TOKENS | $OUTPUT_TOKENS | \$$COST |" >> "$SUMMARY_FILE"
      finalize_summary "BLOCKED"
      exit 2
    elif echo "$RESULT" | grep -q "RALPH_TASK_COMPLETE_ESCALATED"; then
      TASK_ID=$(echo "$RESULT" | grep "RALPH_TASK_COMPLETE_ESCALATED" | awk '{print $2}' | head -1)
      STATUS="escalated"
      echo -e "${YELLOW}Task $TASK_ID complete with escalations${NC}"
      echo -e "${YELLOW}  Review deferred issues in reviews/task-${TASK_ID}-review.md${NC}"
      CONSECUTIVE_FAILURES=0
    elif echo "$RESULT" | grep -q "RALPH_TASK_COMPLETE"; then
      TASK_ID=$(echo "$RESULT" | grep "RALPH_TASK_COMPLETE" | awk '{print $2}' | head -1)
      STATUS="complete"
      echo -e "${GREEN}Task $TASK_ID complete${NC}"
      CONSECUTIVE_FAILURES=0
    elif echo "$RESULT" | grep -q "RALPH_TASK_FAILED"; then
      TASK_ID=$(echo "$RESULT" | grep "RALPH_TASK_FAILED" | awk '{print $2}' | head -1)
      STATUS="FAILED"
      echo -e "${RED}Task $TASK_ID failed${NC}"
      CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))

      if [[ $CONSECUTIVE_FAILURES -ge $MAX_CONSECUTIVE_FAILURES ]]; then
        echo -e "${RED}Too many consecutive failures ($MAX_CONSECUTIVE_FAILURES). Stopping.${NC}"
        echo "| $ITERATION | $TASK_ID | $STATUS | $CONTEXT_TOKENS | $OUTPUT_TOKENS | \$$COST |" >> "$SUMMARY_FILE"
        finalize_summary "FAILED (consecutive failures)"
        exit 1
      fi
    else
      TASK_ID="unknown"
      STATUS="no-signal"
    fi

    # Add row to summary table
    echo "| $ITERATION | ${TASK_ID:-unknown} | ${STATUS:-unknown} | ${CONTEXT_TOKENS:-0} | ${OUTPUT_TOKENS:-0} | \$${COST:-0} |" >> "$SUMMARY_FILE"

    # Extract and append findings if present
    if echo "$RESULT" | grep -q "RALPH_FINDINGS"; then
      FINDINGS=$(echo "$RESULT" | sed -n '/RALPH_FINDINGS/,/RALPH_FINDINGS_END/p' | grep -v "RALPH_FINDINGS")
      if [[ -n "$FINDINGS" ]]; then
        echo "**Iteration $ITERATION (${TASK_ID:-unknown}):**" >> "$FINDINGS_FILE"
        echo "$FINDINGS" >> "$FINDINGS_FILE"
        echo "" >> "$FINDINGS_FILE"
      fi
    fi

  else
    echo -e "${RED}Claude exited with error${NC}"
    echo "| $ITERATION | error | ERROR | - | - | - |" >> "$SUMMARY_FILE"
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
