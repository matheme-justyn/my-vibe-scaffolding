---
name: sdd-archive
version: 1.0.0
description: Spec-Driven Development (SDD) archival phase - Archive completed changes and update specs after successful PR merge.
workflow: brainstorming → sdd-propose → sdd-apply → sdd-archive
integration: OpenSpec
---

# SDD Archive - Complete Workflow

## Purpose

Archive completed implementation changes and mark specifications as done after PR merge.

## When to Use

**Trigger phrases**:
- "Archive this change"
- "PR has been merged"
- "Mark spec as complete"
- "Finalize this feature"

**Prerequisites**:
- PR merged to main branch
- All tests passing in production
- Implementation verified working
- No critical bugs reported

## Workflow

```
Input: .openspec/changes/{change-id}/ (completed implementation)
Process: Move to archive, update spec status
Output: .openspec/changes/archive/{change-id}/
```

## Archive Structure

```
.openspec/
├── specs/
│   └── {feature}/
│       ├── proposal.md
│       ├── design.md
│       ├── tasks.md
│       └── STATUS.md          # NEW: Completion status
├── changes/
│   ├── (active changes)
│   └── archive/                # ARCHIVED
│       └── {change-id}/
│           ├── spec-reference.md
│           ├── implementation.md
│           ├── tests.md
│           ├── decisions.md
│           ├── files-changed.md
│           └── COMPLETION.md   # NEW: Final summary
```

## Archive Process

### Step 1: Create STATUS.md

```markdown
# User Authentication - Status

**Status**: ✅ Completed
**Completed**: 2026-03-27
**PR**: #123 (https://github.com/org/repo/pull/123)
**Change ID**: 20260327-1400-user-auth

## Implementation Summary
- User registration with email/password
- JWT token authentication
- Password hashing with bcrypt
- Refresh token mechanism

## Metrics
- Development time: 8 days (as estimated)
- Tests added: 15 unit + 3 integration
- Code coverage: 92%
- Files changed: 6 files, 452 lines

## Known Issues
None

## Future Improvements
- Add OAuth providers (Google, GitHub)
- Add 2FA support
- Add password reset flow
```

### Step 2: Create COMPLETION.md

```markdown
# Completion Summary

**Feature**: User Authentication
**Change ID**: 20260327-1400-user-auth
**Merged**: 2026-03-27
**PR**: #123

## What Was Delivered
✅ All proposed tasks completed
✅ Tests passing (100%)
✅ Documentation updated
✅ Code reviewed and approved
✅ Deployed to production

## Actual vs Estimated
- Estimated: 8 days
- Actual: 8 days
- Variance: 0% ✅

## Lessons Learned
### What Went Well
- TDD approach prevented bugs
- Clear spec helped avoid scope creep
- Regular code reviews caught issues early

### What Could Improve
- Could have parallelized some tasks
- Initial database schema needed one revision

### Action Items
- [ ] Document authentication patterns in wiki
- [ ] Create reusable auth components library
```

### Step 3: Move to Archive

```bash
# Move change directory to archive
mv .openspec/changes/20260327-1400-user-auth/ \
   .openspec/changes/archive/20260327-1400-user-auth/
```

### Step 4: Update Spec Tasks

```markdown
# tasks.md (updated)

## ✅ All Phases Complete

### Phase 1: Foundation
- [x] Task 1: Database schema
- [x] Task 2: API endpoints
- [x] Task 3: Integration tests

### Phase 2: Core Features
- [x] Task 4: Business logic
- [x] Task 5: Error handling
- [x] Task 6: Unit tests

### Phase 3: UI/UX
- [x] Task 7: React components
- [x] Task 8: Wire up to API
- [x] Task 9: Loading/error states

### Phase 4: Polish
- [x] Task 10: E2E tests
- [x] Task 11: Performance optimization
- [x] Task 12: Documentation

**Completed**: 2026-03-27
**Change ID**: 20260327-1400-user-auth
```

## Archive Index

Maintain an index of all archived changes:

```markdown
# .openspec/changes/archive/INDEX.md

## Completed Features

| Feature | Completed | Change ID | PR | Developer |
|---------|-----------|-----------|-----|-----------|
| User Auth | 2026-03-27 | 20260327-1400 | #123 | @dev1 |
| Payment | 2026-03-20 | 20260320-0900 | #115 | @dev2 |
| Notifications | 2026-03-15 | 20260315-1500 | #110 | @dev1 |

## Metrics

- Total features: 3
- Average dev time: 7.3 days
- Average coverage: 89%
- Success rate: 100% (no rollbacks)
```

## Commands

```
@use sdd-archive
User: "PR #123 has been merged, archive the auth feature"
```

## Cleanup Tasks

After archiving:
- ✅ Changes moved to archive/
- ✅ STATUS.md created in specs/
- ✅ COMPLETION.md added to archive/
- ✅ INDEX.md updated
- ✅ All tasks marked complete

## Benefits

**Traceability**:
- Every feature has complete implementation history
- Easy to find "why" decisions were made

**Metrics**:
- Track actual vs estimated effort
- Identify improvement opportunities

**Knowledge Base**:
- Lessons learned documented
- Patterns for future features

## Next Steps

After archiving:
1. Celebrate! 🎉
2. Retrospective meeting (optional)
3. Plan next feature
4. Start new brainstorming → sdd-propose cycle

## References

- OpenSpec: https://kaochenlong.com/openspec
- Workflow: brainstorming → sdd-propose → sdd-apply → **sdd-archive**
