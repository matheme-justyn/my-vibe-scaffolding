---
name: sdd-propose
version: 1.0.0
description: Spec-Driven Development (SDD) proposal phase - Transform brainstorming outputs into formal OpenSpec format with clear requirements, technical design, and implementation tasks.
workflow: brainstorming → sdd-propose → sdd-apply → sdd-archive
integration: OpenSpec
---

# SDD Propose - Formalize Specifications

## Purpose

Transform informal brainstorming discussions into formal, actionable specifications using OpenSpec format.

## When to Use

**Trigger phrases**:
- "Let's formalize this spec"
- "Create a proposal from our discussion"
- "Write up the technical spec"
- "Convert brainstorming to OpenSpec"

**Prerequisites**:
- Brainstorming session completed
- Feature requirements discussed
- User approved the approach

## Workflow

```
Input: Brainstorming output (informal notes)
Process: Formalize into OpenSpec structure
Output: .openspec/specs/{feature-name}.md
```

## OpenSpec Structure

### 1. proposal.md - Requirements

```markdown
# {Feature Name} Proposal

## Problem Statement
What problem are we solving? Why now?

## Goals
- Primary goal
- Secondary goals
- Non-goals (explicitly out of scope)

## User Stories
As a {user type}
I want {capability}
So that {benefit}

## Success Criteria
- Measurable outcome 1
- Measurable outcome 2

## Constraints
- Technical constraints
- Business constraints
- Timeline constraints

## Alternatives Considered
- Option A: [pros/cons]
- Option B: [pros/cons]
- Why we chose this approach

## Risks
- Risk 1: [mitigation strategy]
- Risk 2: [mitigation strategy]
```

### 2. design.md - Technical Design

```markdown
# {Feature Name} Design

## Architecture Overview
[High-level diagram or description]

## Components
### Component A
- Responsibility
- Interfaces
- Dependencies

## Data Models
```typescript
interface User {
  id: string;
  // ...
}
```

## API Endpoints
```
POST /api/feature
GET /api/feature/:id
```

## State Management
- What state needs to be tracked
- Where state lives (client/server)
- State update patterns

## Error Handling
- Expected error scenarios
- Error messages
- Recovery strategies

## Performance Considerations
- Expected load
- Caching strategy
- Optimization opportunities

## Security Considerations
- Authentication requirements
- Authorization rules
- Data validation
```

### 3. tasks.md - Implementation Tasks

```markdown
# {Feature Name} Tasks

## Phase 1: Foundation
- [ ] Task 1: Set up database schema
- [ ] Task 2: Create API endpoints
- [ ] Task 3: Write integration tests

## Phase 2: Core Features
- [ ] Task 4: Implement business logic
- [ ] Task 5: Add error handling
- [ ] Task 6: Write unit tests

## Phase 3: UI/UX
- [ ] Task 7: Create React components
- [ ] Task 8: Wire up to API
- [ ] Task 9: Add loading/error states

## Phase 4: Polish
- [ ] Task 10: Add E2E tests
- [ ] Task 11: Performance optimization
- [ ] Task 12: Documentation

## Dependencies
- Task 2 depends on Task 1
- Task 5 depends on Task 4

## Estimated Effort
- Phase 1: 2 days
- Phase 2: 3 days
- Phase 3: 2 days
- Phase 4: 1 day
Total: 8 days
```

## Output Location

```
.openspec/
├── specs/
│   └── {feature-name}/
│       ├── proposal.md
│       ├── design.md
│       └── tasks.md
└── changes/
    └── (created during sdd-apply)
```

## Commands

```
@use sdd-propose
User: "Formalize the user authentication spec we discussed"
```

## Integration with Brainstorming

Reads output from `brainstorming` skill and structures it into OpenSpec format.

## Next Steps

After proposal is approved:
1. User reviews proposal.md, design.md, tasks.md
2. User approves or requests changes
3. Proceed to `sdd-apply` for implementation

## References

- OpenSpec: https://kaochenlong.com/openspec
- Workflow: brainstorming → **sdd-propose** → sdd-apply → sdd-archive
