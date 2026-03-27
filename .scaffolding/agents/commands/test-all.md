---
description: Run all tests (unit, integration, E2E) with coverage report
agent: tdd-guide
subtask: true
---

# Test All Command

Run comprehensive test suite for the project: $ARGUMENTS

## Your Task

1. **Identify test frameworks** - Detect Jest, Vitest, Playwright, Pytest, etc.
2. **Run all test types** - Unit, integration, E2E in sequence
3. **Generate coverage report** - Show coverage metrics
4. **Report failures** - List failing tests with context

## Test Execution Order

### 1. Unit Tests (Fast Layer)

```bash
# Node.js projects
npm test || npm run test:unit || yarn test

# Python projects
pytest tests/unit/ || python -m pytest tests/unit/

# Go projects
go test ./... -short
```

**Expected**: < 10 seconds execution time

### 2. Integration Tests (Medium Layer)

```bash
# Node.js
npm run test:integration

# Python
pytest tests/integration/

# Go
go test ./... -run Integration
```

**Expected**: < 60 seconds execution time

### 3. E2E Tests (Slow Layer)

```bash
# Playwright
npx playwright test

# Cypress
npx cypress run

# Selenium
pytest tests/e2e/
```

**Expected**: < 5 minutes execution time

## Coverage Report Format

```
Test Summary:
  Unit Tests:        142 passed, 0 failed (100%)
  Integration Tests:  38 passed, 2 failed (95%)
  E2E Tests:          15 passed, 0 failed (100%)
  
Coverage:
  Statements:   87.3% (1234/1413)
  Branches:     82.1% (456/556)
  Functions:    91.2% (234/257)
  Lines:        86.8% (1198/1378)
  
Below Threshold (< 80%):
  src/utils/parser.ts:     67.4%
  src/services/api.ts:     74.2%
```

## Failure Reporting

For each failing test:

```
FAIL src/auth/login.test.ts
  ● User Login › should reject invalid credentials

    expect(received).toBe(expected)
    
    Expected: 401
    Received: 500
    
    at Object.<anonymous> (src/auth/login.test.ts:42:23)
```

## Actions After Test Run

- **All tests pass + coverage > 80%**: ✅ Ready to commit
- **Some tests fail**: 🔴 Fix failures before proceeding
- **Coverage < 80%**: ⚠️ Add tests for uncovered code

## Quick Test Commands

```bash
# Run only failing tests
npm test -- --onlyFailures

# Run tests for specific file
npm test -- path/to/file.test.ts

# Run tests in watch mode
npm test -- --watch

# Update snapshots
npm test -- -u
```

---

**IMPORTANT**: Never skip failing tests. Fix or update them.
