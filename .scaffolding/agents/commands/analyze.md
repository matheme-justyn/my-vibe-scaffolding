---
description: Analyze codebase for quality, complexity, and maintainability metrics
agent: architect
subtask: true
---

# Analyze Command

Deep analysis of codebase quality and architecture: $ARGUMENTS

## Your Task

1. **Measure code metrics** - Complexity, coupling, cohesion
2. **Identify hotspots** - Files that need refactoring
3. **Analyze architecture** - Layer violations, circular dependencies
4. **Generate recommendations** - Prioritized improvement list

## Analysis Categories

### 1. Code Complexity

**Cyclomatic Complexity** (per function):
- 1-10: Simple (✅ good)
- 11-20: Moderate (⚠️ consider simplifying)
- 21+: Complex (🔴 needs refactoring)

```bash
# Node.js - Use complexity-report
npx complexity-report src/ --format json

# Python - Use radon
radon cc src/ -a -nb

# Go - Use gocyclo
gocyclo -over 15 .
```

### 2. Code Size Metrics

**Recommended Limits**:
- Function: < 50 lines
- File: < 800 lines
- Class: < 300 lines

```bash
# Find large files
find src -name '*.ts' -exec wc -l {} + | sort -rn | head -20

# Find large functions (requires AST parsing)
npx eslint . --rule 'max-lines-per-function: [error, 50]'
```

### 3. Coupling Analysis

**Types of Coupling** (worst to best):
- Content coupling (🔴 avoid)
- Common coupling (🔴 avoid)
- External coupling (🟡 minimize)
- Control coupling (🟡 be careful)
- Data coupling (✅ prefer)

**Check for**:
- [ ] Circular dependencies
- [ ] God objects (classes with too many dependencies)
- [ ] Tight coupling between layers

```bash
# Node.js - Use madge
npx madge --circular src/

# Visualize dependency graph
npx madge --image graph.png src/
```

### 4. Code Duplication

```bash
# Node.js - Use jscpd
npx jscpd src/

# Python - Use pylint
pylint --duplicate-code src/

# Show files with > 10% duplication
```

**Thresholds**:
- 0-5% duplication: ✅ Excellent
- 6-10% duplication: 🟡 Acceptable
- 11%+ duplication: 🔴 Needs refactoring

### 5. Test Coverage

```bash
# Run tests with coverage
npm test -- --coverage

# Find files with < 80% coverage
```

**Coverage Targets**:
- Critical paths: 100%
- Business logic: > 90%
- Utilities: > 85%
- UI components: > 80%

### 6. Architecture Violations

**Layer Architecture**:
```
Presentation (UI)
    ↓
Business Logic (Services)
    ↓
Data Access (Repositories)
    ↓
Database
```

**Check for**:
- [ ] Presentation calling Data Access directly (skip Business Logic)
- [ ] Data Access importing Presentation components
- [ ] Circular layer dependencies

### 7. Technical Debt

**Identify**:
- TODO comments
- FIXME markers
- Disabled tests
- console.log statements
- Type assertions (as any, @ts-ignore)
- Deprecated API usage

```bash
# Find technical debt markers
git grep -n "TODO\|FIXME\|HACK\|XXX" src/

# Find disabled tests
git grep -n "test.skip\|it.skip\|describe.skip" src/

# Find type assertions
git grep -n "as any\|@ts-ignore\|@ts-expect-error" src/
```

## Report Format

```
Codebase Analysis Report
========================

📊 Metrics Summary
  Total Files:        234
  Total Lines:        45,823
  Average File Size:  196 lines
  
  Functions:          1,234
  Complex Functions:  23 (> 20 complexity)
  
  Test Coverage:      87.3%
  Code Duplication:   4.2%

🔴 Critical Issues (3)
  1. src/services/UserService.ts
     - Cyclomatic complexity: 47 (function: processUser)
     - File size: 1,234 lines
     - Recommendation: Split into multiple services
     
  2. Circular dependency detected
     - src/auth/Login.tsx → src/services/AuthService.ts → src/auth/types.ts → src/auth/Login.tsx
     - Recommendation: Extract shared types to separate module
     
  3. src/utils/parser.ts
     - Test coverage: 34%
     - Recommendation: Add comprehensive tests

🟡 Warnings (8)
  4. High coupling in src/api/
     - 15 files import from same barrel export
     - Recommendation: Use dependency injection
     
  5. Code duplication: 12.3% in src/components/
     - Repeated form validation logic
     - Recommendation: Extract to shared validator
     
  ...

✅ Strengths (5)
  - Clean separation between UI and business logic
  - Comprehensive error handling
  - Good test coverage (87.3%)
  - No critical security issues
  - Modern TypeScript patterns

📈 Trends (Last 30 Days)
  Complexity:     ↓ -3.2%
  Test Coverage:  ↑ +4.1%
  Code Duplication: → 4.2% (stable)
  File Size:      ↑ +2.3%

🎯 Top Refactoring Priorities
  1. Split UserService.ts (complexity: 47)
  2. Break circular dependency in auth module
  3. Add tests for parser.ts (coverage: 34%)
  4. Extract duplicated form validation
  5. Reduce coupling in api module
```

## Recommended Tools

**Node.js/TypeScript**:
- `madge` - Dependency analysis
- `jscpd` - Duplicate code detection
- `complexity-report` - Cyclomatic complexity
- `eslint` - Code quality rules

**Python**:
- `radon` - Complexity metrics
- `pylint` - Code analysis
- `bandit` - Security analysis

**Go**:
- `gocyclo` - Cyclomatic complexity
- `golint` - Code style
- `go vet` - Suspicious code

---

**Next Steps**: Address critical issues first, then work through warnings systematically.
