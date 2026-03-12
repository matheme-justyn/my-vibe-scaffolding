# Skills System

**Version**: 1.0.0  
**Origin**: [everything-claude-code](https://github.com/affaan-m/everything-claude-code) (Anthropic Hackathon Winner)  
**Adapted for**: OpenCode

## Overview

This directory contains **15 core skills** adapted from the everything-claude-code project, organized by domain expertise. Skills provide specialized knowledge and step-by-step guidance for specific tasks.

## Directory Structure

```
.agents/skills/
├── universal/         # 5 universal skills (all projects)
├── backend/           # 3 backend-specific skills
├── frontend/          # 3 frontend-specific skills
├── testing/           # 2 testing skills
└── other/             # 2 specialized skills
```

## Available Skills

### Universal Skills (5)

| Skill | Description | When to Use |
|-------|-------------|-------------|
| **api-design** | REST API design patterns | Designing API endpoints, versioning, pagination |
| **security-review** | Comprehensive security checklist | Authentication, user input, sensitive data |
| **tdd-workflow** | Test-driven development | New features, bug fixes, refactoring |
| **coding-standards** | Code style and conventions | Code reviews, new projects, onboarding |
| **verification-loop** | Systematic verification | Before completing tasks, pre-deployment |

### Backend Skills (3)

| Skill | Description | When to Use |
|-------|-------------|-------------|
| **backend-patterns** | Node.js backend patterns | Async patterns, middleware, microservices |
| **database-optimization** | Database query optimization | Slow queries, N+1 problems, indexing |
| **error-handling** | Error handling patterns | API error middleware, logging, recovery |

### Frontend Skills (3)

| Skill | Description | When to Use |
|-------|-------------|-------------|
| **frontend-patterns** | React/Next.js patterns | Component architecture, state management |
| **react-hooks** | React Hooks patterns | useState, useEffect, custom hooks |
| **component-design** | Component design patterns | Reusable components, composition |

### Testing Skills (2)

| Skill | Description | When to Use |
|-------|-------------|-------------|
| **e2e-testing** | Playwright E2E testing | User flows, critical workflows |
| **unit-testing** | Jest/Vitest unit testing | Functions, components, utilities |

### Other Skills (2)

| Skill | Description | When to Use |
|-------|-------------|-------------|
| **content-engine** | Content creation workflows | Documentation, articles, marketing |
| **market-research** | Market analysis patterns | Competitive research, market sizing |

## Usage Patterns

### Automatic Loading (Recommended)

Skills are automatically loaded when AGENTS.md detects relevant keywords:

```typescript
User: "Design a REST API for user management"
// Auto-loads: api-design, security-review, backend-patterns
```

### Manual Loading

```typescript
// Load single skill
@use api-design
User: "Design API endpoints"

// Load multiple skills
@use tdd-workflow
@use e2e-testing
User: "Implement login with tests"
```

### Skill Combinations

**Backend API Development**:
- `api-design` + `security-review` + `backend-patterns` + `tdd-workflow`

**Frontend Component Development**:
- `frontend-patterns` + `react-hooks` + `component-design` + `unit-testing`

**Full-stack Feature**:
- `api-design` + `frontend-patterns` + `tdd-workflow` + `e2e-testing`

**Production Deployment**:
- `security-review` + `verification-loop` + `e2e-testing`

## Skill Format

Each skill file follows this structure:

```markdown
---
name: skill-name
description: Brief description
origin: ECC (everything-claude-code)
adapted_for: OpenCode
---

# Skill Title

## OpenCode Integration

**When to Use**: Scenarios and triggers

**Usage Pattern**: How to invoke

**Combines well with**: Related skills

---

## Overview

Skill content and instructions
```

## Integration with Superpowers

These skills complement your existing superpowers skills:

| ECC Skill | Superpowers Equivalent | Recommendation |
|-----------|------------------------|----------------|
| `tdd-workflow` | `superpowers/test-driven-development` | Use both together |
| `verification-loop` | `superpowers/verification-before-completion` | Use both together |
| `security-review` | — | New capability |
| `api-design` | — | New capability |

**Strategy**: ECC skills provide implementation patterns, superpowers provide workflow guidance.

## Skill Discovery

AGENTS.md automatically detects and loads skills based on:

1. **Keywords**: "API", "security", "TDD", "React", etc.
2. **Task Type**: Backend, frontend, testing, deployment
3. **Context**: File paths, existing codebase patterns

## Benefits of This Organization

✅ **Domain Expertise**: Skills grouped by specialization  
✅ **Easy Discovery**: Clear categories and descriptions  
✅ **Interoperability**: Works with existing superpowers skills  
✅ **Scalability**: Easy to add new skills  
✅ **Hackathon-Proven**: From Claude Code hackathon winner

## Adding New Skills

1. Determine category (universal, backend, frontend, testing, other)
2. Create `{category}/{skill-name}.md`
3. Follow skill format template
4. Add to this README
5. Update AGENTS.md if needed

## References

- **Source**: https://github.com/affaan-m/everything-claude-code
- **Article**: https://www.blocktempo.com/hackathon-winner-claude-code-setup-revealed/
- **PRD**: `docs/PRD-claude-code-inspired-upgrades.md`
- **ADR**: `docs/adr/0009-reference-claude-code-architecture.md`

---

**Total Skills**: 15  
**Last Updated**: 2025-03-12  
**Status**: Phase 1.2 Complete ✅
