Run comprehensive validation of the project to ensure all tests, type checks, linting, and local server are working correctly.

Optional extra context: $ARGUMENTS

**Note:** Adapt the commands below to your project's specific setup. Replace variables with actual values:
- `${TEST_COMMAND}`: Your test runner command
- `${TYPE_CHECK_COMMAND}`: Your type checker command(s)
- `${LINT_COMMAND}`: Your linter command
- `${SERVER_START_CMD}`: Command to start your local server
- `${PORT}`: Your server port
- `${SOURCE_DIR}`: Your source code directory
- `${HEALTH_ENDPOINT}`: Your health check or root endpoint

Execute the following validations in sequence and report results:

## 1. Test Suite

**Python example:**
```bash
uv run pytest -v
# or: pytest -v
# or: python -m pytest
```

**JavaScript/TypeScript example:**
```bash
npm test
# or: npm run test:coverage
# or: pnpm test
# or: yarn test
```

**Expected:** All tests pass with reasonable execution time

## 2. Type Checking

**Python example:**
```bash
uv run mypy ${SOURCE_DIR}
# or: mypy .
# and/or: pyright ${SOURCE_DIR}
```

**JavaScript/TypeScript example:**
```bash
npm run type-check
# or: tsc --noEmit
# or: npx tsc --noEmit
```

**Expected:** No type errors or warnings

## 3. Linting

**Python example:**
```bash
uv run ruff check .
# or: flake8 .
# or: pylint ${SOURCE_DIR}
```

**JavaScript/TypeScript example:**
```bash
npm run lint
# or: eslint .
# or: npx eslint src/
```

**Expected:** All checks passed with no errors or warnings

## 4. Local Server Validation

Start the server in background:

**Python example:**
```bash
uv run uvicorn ${MODULE_PATH} --host 0.0.0.0 --port ${PORT} &
# or: python -m flask run --port ${PORT} &
# or: gunicorn ${MODULE_PATH} -b 0.0.0.0:${PORT} &
```

**JavaScript/TypeScript example:**
```bash
npm start &
# or: node dist/index.js &
# or: npm run dev &
```

Wait a few seconds for startup, then test endpoints:

**Test health endpoint:**
```bash
curl -s http://localhost:${PORT}${HEALTH_ENDPOINT} | python3 -m json.tool
# or for non-JSON: curl -s http://localhost:${PORT}${HEALTH_ENDPOINT}
```

**Expected:** Valid response with expected data structure

**Test status code:**
```bash
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:${PORT}${HEALTH_ENDPOINT}
```

**Expected:** HTTP Status: 200

**Test headers:**
```bash
curl -s -i http://localhost:${PORT}${HEALTH_ENDPOINT} | head -10
```

**Expected:** Appropriate headers (e.g., Content-Type, custom headers) and status 200

Stop the server:

```bash
lsof -ti:${PORT} | xargs kill -9 2>/dev/null || true
# or: pkill -f "${SERVER_PROCESS_NAME}"
```

## 5. Summary Report

After all validations complete, provide a summary report with:

- ✅/❌ Test suite status (number passed/failed if available)
- ✅/❌ Type checking status (all type checkers used)
- ✅/❌ Linting status
- ✅/❌ Local server status (startup + endpoints)
- Any errors or warnings encountered
- Overall health assessment (PASS/FAIL)

**Format the report clearly with sections and status indicators (✅/❌)**
