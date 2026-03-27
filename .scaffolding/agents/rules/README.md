# Rules System

**Version**: 1.0.0  
**Origin**: [everything-claude-code](https://github.com/affaan-m/everything-claude-code) (Anthropic Hackathon Winner)  
**Adapted for**: OpenCode

## Overview

Rules provide behavioral constraints and guardrails for AI agents and developers. They enforce best practices and prevent common mistakes.

## Available Rules (4 Categories)

| Rule Category | File | Purpose | Severity Levels |
|---------------|------|---------|-----------------|
| **Git Rules** | `git-rules.md` | Safe Git operations, commit conventions | 🔴 CRITICAL, 🟠 HIGH, 🟡 MEDIUM, 🟢 LOW |
| **Testing Rules** | `testing-rules.md` | Test coverage, TDD workflow, test quality | 🔴 CRITICAL, 🟠 HIGH, 🟡 MEDIUM, 🟢 LOW |
| **Security Rules** | `security-rules.md` | Prevent vulnerabilities, secure coding | 🔴 CRITICAL, 🟠 HIGH, 🟡 MEDIUM |
| **Code Style Rules** | `code-style-rules.md` | Code consistency, readability, maintainability | 🟠 HIGH, 🟡 MEDIUM, 🟢 LOW |

## Rule Categories

### Git Rules (11 Rules)

**Critical Rules**:
- Never commit secrets (API keys, passwords, tokens)
- Never force push to main/master
- Never commit directly to main

**High Priority**:
- Write meaningful commit messages (Angular convention)
- Always pull before push
- Resolve conflicts carefully

**Medium/Low**:
- Use meaningful branch names
- Commit frequently, push daily
- Delete merged branches

### Testing Rules (16 Rules)

**Critical Rules**:
- Tests must be deterministic (no flaky tests)
- Never skip failing tests

**High Priority**:
- Write tests BEFORE code (TDD)
- Minimum 80% coverage
- Test behavior, not implementation
- Mock external dependencies
- Test edge cases
- Test API contracts
- Clean up after tests

**Medium/Low**:
- One assertion per test (preferred)
- Test critical user flows only (E2E)
- Use page object pattern
- Descriptive test names
- Tests must run fast

### Security Rules (13 Rules)

**Critical Rules** (🔴 Never Violate):
- Never hardcode secrets
- Always use parameterized queries (prevent SQL injection)
- Validate ALL user input
- Use httpOnly cookies for tokens
- Hash passwords with bcrypt

**High Priority**:
- Sanitize HTML before rendering (prevent XSS)
- Implement rate limiting
- Enable CSRF protection
- Set security headers
- Implement Row Level Security (RLS)

**Medium Priority**:
- Keep dependencies updated
- Don't expose stack traces in production
- Use HTTPS in production

### Code Style Rules (20 Rules)

**Naming & Organization**:
- Use meaningful names
- Follow language conventions (camelCase, PascalCase, etc.)
- Limit file size (< 800 lines)
- Group related code

**Function Rules**:
- Keep functions small (< 50 lines)
- One thing per function
- Limit parameters (max 3)

**Code Quality**:
- Avoid nesting > 4 levels
- Remove dead code
- No magic numbers

**TypeScript Specific**:
- Use strict TypeScript
- Never use `any`
- Prefer interfaces over types

**Formatting & Comments**:
- Use Prettier/auto-formatter
- Write comments for WHY, not WHAT
- Keep comments up to date

## Usage in AGENTS.md

Rules are automatically enforced by AI agents when working on code. Agents check rules before:

- Committing code (Git Rules)
- Writing tests (Testing Rules)
- Implementing security-sensitive features (Security Rules)
- Reviewing code (Code Style Rules)

## Severity Levels

| Level | Symbol | Meaning | Action |
|-------|--------|---------|--------|
| **CRITICAL** | 🔴 | Blocks deployment | Stop immediately, fix before proceeding |
| **HIGH** | 🟠 | Requires fix | Fix before merging to main |
| **MEDIUM** | 🟡 | Should fix | Fix before production deployment |
| **LOW** | 🟢 | Optional | Improve when convenient |

## Rule Enforcement

### Pre-Commit Checks

```bash
# Git Rules
- No secrets in code
- Tests pass
- Lint passes
- Commit message format

# Testing Rules
- Coverage ≥ 80%
- No skipped tests

# Security Rules
- No hardcoded credentials
- Input validation present

# Code Style Rules
- Prettier formatting
- No dead code
- No magic numbers
```

### Pre-Push Checks

```bash
# Git Rules
- Pulled latest changes
- No conflicts
- Pushing to correct branch

# Testing Rules
- All tests pass
- Build succeeds
```

### Pre-Deployment Checks

```bash
# Security Rules (CRITICAL)
- Security scan passes
- No vulnerabilities
- HTTPS enforced
- Security headers configured

# Testing Rules
- E2E tests pass
- Coverage ≥ 80%
```

## Integration with Commands

Rules are referenced by commands:

| Command | Primary Rules |
|---------|---------------|
| code-review | Code Style Rules, Security Rules |
| test-all | Testing Rules |
| security-scan | Security Rules |
| refactor | Code Style Rules, Testing Rules |
| plan | Git Rules (branching strategy) |

## Customizing Rules

To add project-specific rules:

1. Create new rule file in `.agents/rules/`
2. Follow existing format (severity levels, examples)
3. Add to this README
4. Reference in relevant commands

## Example Rule File Structure

```markdown
# Rule Category Name

**Purpose**: Brief description

## Rule 1: Descriptive Name

**Severity**: CRITICAL/HIGH/MEDIUM/LOW

**Description**:
[What the rule enforces]

**Examples**:
\`\`\`typescript
// ❌ BAD
[bad example]

// ✅ GOOD
[good example]
\`\`\`

## Checklist

- [ ] Check item 1
- [ ] Check item 2
```

## Quick Reference

**Most Important Rules**:
1. 🔴 Never commit secrets (Git)
2. 🔴 Never use string concatenation in SQL (Security)
3. 🔴 Validate ALL user input (Security)
4. 🔴 Never skip failing tests (Testing)
5. 🟠 Write tests BEFORE code (Testing)
6. 🟠 Minimum 80% coverage (Testing)
7. 🟠 Use httpOnly cookies for tokens (Security)
8. 🟠 Functions < 50 lines (Code Style)

## References

- **Source**: https://github.com/affaan-m/everything-claude-code
- **PRD**: `docs/PRD-claude-code-inspired-upgrades.md`
- **ADR**: `docs/adr/0009-reference-claude-code-architecture.md`
- **Commands**: `.agents/commands/README.md`
- **Skills**: `.agents/skills/README.md`

---

**Total Rules**: 60 (11 Git + 16 Testing + 13 Security + 20 Code Style)  
**Last Updated**: 2025-03-12  
**Status**: Phase 1.4 Complete ✅
