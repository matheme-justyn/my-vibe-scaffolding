---
name: sdd-apply
version: 1.0.0
description: Spec-Driven Development (SDD) implementation phase - Execute specifications with mandatory TDD workflow, creating changes in .openspec/changes/ directory.
workflow: brainstorming → sdd-propose → sdd-apply → sdd-archive
integration: OpenSpec + test-driven-development (mandatory)
---

# SDD Apply - Execute Specifications

## Purpose

Execute approved specifications with mandatory TDD workflow, tracking all changes in OpenSpec format.

## When to Use

**Trigger phrases**:
- "Start implementing the spec"
- "Apply the specification"
- "Begin development"
- "Execute the proposal"

**Prerequisites**:
- Spec files exist in `.openspec/specs/{feature}/`
- proposal.md, design.md, tasks.md reviewed and approved
- User ready to start implementation

## Workflow

```
Input: .openspec/specs/{feature}/ (approved spec)
Process: TDD implementation + change tracking
Output: .openspec/changes/{change-id}/ + production code
```

## Mandatory TDD Integration

**CRITICAL**: `sdd-apply` ALWAYS invokes `test-driven-development` skill.

```typescript
// Automatic workflow
sdd-apply → calls → test-driven-development
           → Red-Green-Refactor cycle
           → All changes tracked in .openspec/changes/
```

**No exceptions**: Cannot skip TDD when using `sdd-apply`.

## Change Tracking Structure

```
.openspec/changes/
└── {YYYYMMDD-HHMM-feature-name}/
    ├── spec-reference.md      # Link to original spec
    ├── implementation.md      # What was implemented
    ├── tests.md               # Test results
    ├── decisions.md           # Design decisions made during implementation
    └── files-changed.md       # List of modified files
```

### spec-reference.md
```markdown
# Spec Reference

**Original Spec**: `.openspec/specs/user-auth/`
**Proposal**: [link]
**Design**: [link]
**Tasks**: [link]

## Tasks Completed
- [x] Task 1: Database schema
- [x] Task 2: API endpoints
- [ ] Task 3: Frontend (in progress)
```

### implementation.md
```markdown
# Implementation Log

## What Was Built
- User registration endpoint (POST /api/auth/register)
- JWT token generation
- Password hashing with bcrypt

## Code Locations
- `src/api/auth/register.ts`
- `src/services/auth-service.ts`
- `src/utils/jwt.ts`

## Dependencies Added
- bcrypt v5.1.0
- jsonwebtoken v9.0.0
```

### tests.md
```markdown
# Test Results

## Unit Tests
✅ 12/12 passing
- AuthService.register() with valid data
- AuthService.register() with duplicate email
- JWT token generation
- Password hashing

## Integration Tests
✅ 3/3 passing
- POST /api/auth/register success
- POST /api/auth/register validation
- POST /api/auth/register duplicate

## Coverage
- Lines: 92%
- Branches: 88%
- Functions: 95%
```

### decisions.md
```markdown
# Implementation Decisions

## Decision 1: Password Hashing
**Context**: Need to hash passwords securely
**Options**: bcrypt vs argon2
**Chosen**: bcrypt
**Reason**: Better Node.js support, sufficient security for our needs

## Decision 2: Token Expiry
**Context**: JWT token lifetime
**Options**: 1h, 24h, 7d
**Chosen**: 24h with refresh token (7d)
**Reason**: Balance between security and UX
```

### files-changed.md
```markdown
# Files Changed

## New Files
- `src/api/auth/register.ts` (+120 lines)
- `src/services/auth-service.ts` (+85 lines)
- `tests/unit/auth-service.test.ts` (+150 lines)
- `tests/integration/auth-api.test.ts` (+95 lines)

## Modified Files
- `src/api/index.ts` (+2 lines) - Added auth routes
- `package.json` (+2 lines) - Added bcrypt, jsonwebtoken

## Total Impact
- 452 lines added
- 2 lines modified
- 0 lines deleted
```

## TDD Workflow (Mandatory)

**Step 1: Red** - Write failing test
```typescript
// tests/unit/auth-service.test.ts
test('registers new user with valid data', async () => {
  const user = await authService.register({
    email: 'test@example.com',
    password: 'SecurePass123!'
  });
  
  expect(user.email).toBe('test@example.com');
  expect(user.password).not.toBe('SecurePass123!'); // hashed
});
// ❌ FAILS - authService.register doesn't exist
```

**Step 2: Green** - Minimal implementation
```typescript
// src/services/auth-service.ts
export async function register(data: RegisterData): Promise<User> {
  const hashedPassword = await bcrypt.hash(data.password, 10);
  const user = await db.users.create({
    email: data.email,
    password: hashedPassword
  });
  return user;
}
// ✅ PASSES
```

**Step 3: Refactor** - Improve code quality
```typescript
// Extract validation, error handling, etc.
```

**Step 4: Document** - Update change log
```bash
# Update .openspec/changes/{change-id}/tests.md
# Update files-changed.md
```

## Commands

```
@use sdd-apply
User: "Implement the user authentication spec"
```

## Integration Points

**With test-driven-development**:
```typescript
// sdd-apply automatically calls:
@use test-driven-development
// Then follows Red-Green-Refactor cycle
```

**With verification-before-completion**:
```typescript
// After implementation, verify:
- All tests passing
- Coverage > 80%
- No linter errors
- Spec tasks completed
```

## Next Steps

After implementation:
1. All tests passing
2. Change tracking complete
3. Code reviewed
4. Ready for `sdd-archive`

## References

- OpenSpec: https://kaochenlong.com/openspec
- TDD Skill: `superpowers/test-driven-development`
- Workflow: brainstorming → sdd-propose → **sdd-apply** → sdd-archive
