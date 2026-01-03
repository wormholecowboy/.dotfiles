---
description: Execute an implementation plan
argument-hint: [path-to-plan]
---

# Execute: Implement from Plan

## Plan to Execute

Read plan file: `$ARGUMENTS`

## Execution Instructions

### 1. Read and Understand

- Read the ENTIRE plan carefully
- Understand all tasks and their dependencies
- Note the validation commands to run
- Review the testing strategy

### 2. Execute Tasks in Order

For EACH task in "Step by Step Tasks":

#### a. Navigate to the task
- Identify the file and action required
- Read existing related files if modifying

#### b. Implement the task
- Follow the detailed specifications exactly
- Maintain consistency with existing code patterns
- Include proper type hints and documentation
- Add structured logging where appropriate

#### c. Verify as you go
- After each file change, check syntax
- Ensure imports are correct
- Verify types are properly defined

### 3. Implement Testing Strategy

After completing implementation tasks:

- Create all test files specified in the plan
- Implement all test cases mentioned
- Follow the testing approach outlined
- Ensure tests cover edge cases

### 4. Run Validation (Trigger Validation Agent)

**IMPORTANT**: When you reach this phase, you MUST trigger the `execute-validation-runner` agent.

Use the Task tool to launch the validation agent with this prompt:
```
Validate the implementation against plan file: $ARGUMENTS

Focus on these validation headings in the plan:
- ## VALIDATION COMMANDS
- ## TESTING STRATEGY
- ## ACCEPTANCE CRITERIA
- ## COMPLETION CHECKLIST

Execute all validation commands and verify all criteria are met.
```

Wait for the validation agent to complete and review its report.

If any validation fails:
- Fix the issue
- Re-trigger the validation agent
- Continue only when all validations pass

### 5. Final Verification

Before completing:

- ✅ All tasks from plan completed
- ✅ All tests created and passing
- ✅ Validation agent reports all checks passed
- ✅ Code follows project conventions
- ✅ Documentation added/updated as needed

## Output Report

Provide summary:

### Completed Tasks
- List of all tasks completed
- Files created (with paths)
- Files modified (with paths)

### Tests Added
- Test files created
- Test cases implemented
- Test results

### Validation Agent Results
- Summary from execute-validation-runner agent
- Pass/fail status for each validation heading
- Any fixes applied based on validation failures

### Ready for Commit
- Confirm all changes are complete
- Confirm all validations pass
- Ready for `/commit` command

## Notes

- If you encounter issues not addressed in the plan, document them
- If you need to deviate from the plan, explain why
- If tests fail, fix implementation until they pass
- Don't skip validation steps
