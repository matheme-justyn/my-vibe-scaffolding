# Git Rules

**Purpose**: Enforce safe, consistent Git operations and prevent common mistakes.

## Commit Rules

### Rule 1: Never Commit Secrets

**Severity**: CRITICAL 🔴

**Check Before Every Commit**:
```bash
# Check for common secret patterns
git diff --cached | grep -E "api[_-]?key|secret|password|token|AKIA[0-9A-Z]{16}"
```

**Forbidden Patterns**:
- API keys: `api_key`, `apiKey`, `API_KEY`
- Passwords: `password`, `passwd`, `pwd`
- Tokens: `token`, `auth_token`, `access_token`
- AWS keys: `AKIA[0-9A-Z]{16}`
- Private keys: `BEGIN.*PRIVATE KEY`
- Database URLs with credentials: `postgres://user:pass@host`

**If Secrets Are Committed**:
```bash
# IMMEDIATELY rotate the compromised credentials
# Remove from git history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/file" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (DANGEROUS - notify team)
git push --force --all
```

---

### Rule 2: Write Meaningful Commit Messages

**Severity**: HIGH 🟠

**Format** (Angular Convention):
```
type(scope): brief description

[optional body]

[optional footer]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style (formatting)
- `refactor`: Code refactoring
- `test`: Tests
- `chore`: Maintenance

**Examples**:
```bash
# ✅ GOOD
feat(auth): add JWT authentication
fix(api): resolve memory leak in user service
docs(readme): update installation guide

# ❌ BAD
"updates"
"fix stuff"
"WIP"
```

**Commit Message Rules**:
- First line ≤ 50 characters
- Second line blank
- Body lines ≤ 72 characters
- Explain WHY, not WHAT (code shows what)

---

### Rule 3: Commit Frequently, Push Daily

**Severity**: MEDIUM 🟡

**Guidelines**:
- Commit after every logical unit of work
- Minimum 1 commit per day (if actively working)
- Maximum 500 lines per commit
- Split large changes into logical commits

**Benefits**:
- Easy to review
- Easy to revert
- Better collaboration
- Less merge conflicts

---

### Rule 4: Never Force Push to Main/Master

**Severity**: CRITICAL 🔴

```bash
# ❌ FORBIDDEN
git push --force origin main
git push -f origin master

# ✅ ALLOWED (with extreme caution)
git push --force-with-lease origin feature-branch
```

**If You Must Force Push**:
1. Notify team in advance
2. Use `--force-with-lease` (safer)
3. Only on feature branches
4. NEVER on main/master/develop

---

### Rule 5: Always Pull Before Push

**Severity**: HIGH 🟠

```bash
# ✅ CORRECT workflow
git pull --rebase origin main
git push origin feature-branch

# ❌ WRONG (causes merge conflicts)
git push  # without pulling first
```

**Why Rebase**:
- Keeps history linear
- Avoids unnecessary merge commits
- Easier to read git log

---

## Branch Rules

### Rule 6: Use Meaningful Branch Names

**Severity**: MEDIUM 🟡

**Format**: `type/short-description`

**Examples**:
```bash
# ✅ GOOD
feat/user-authentication
fix/memory-leak-in-api
docs/update-readme
refactor/simplify-user-service

# ❌ BAD
new-branch
test
fix
my-work
```

---

### Rule 7: Delete Merged Branches

**Severity**: LOW 🟢

```bash
# Delete local branch
git branch -d feature-branch

# Delete remote branch
git push origin --delete feature-branch

# Clean up stale branches
git remote prune origin
```

---

### Rule 8: Never Commit to Main Directly

**Severity**: CRITICAL 🔴

**Use Pull Requests** for all changes to main:
```bash
# ✅ CORRECT
git checkout -b feat/new-feature
git commit -m "feat: add new feature"
git push origin feat/new-feature
# Create PR on GitHub

# ❌ WRONG
git checkout main
git commit -m "changes"
git push origin main
```

---

## Merge Rules

### Rule 9: Squash Feature Branch Commits (Optional)

**Severity**: LOW 🟢

**When to Squash**:
- Many small "WIP" commits
- Want clean main branch history
- Feature is self-contained

**When NOT to Squash**:
- Commits are already well-organized
- Need detailed history
- Multiple authors

```bash
# Squash last 5 commits
git rebase -i HEAD~5

# In editor, change "pick" to "squash" for commits to merge
```

---

### Rule 10: Resolve Conflicts Carefully

**Severity**: HIGH 🟠

**Conflict Resolution Steps**:
1. **Understand both changes** - Don't blindly accept one side
2. **Test after resolving** - Run tests to ensure no breakage
3. **Ask author** - If unsure, consult original author

```bash
# During merge conflict
git status  # See conflicted files

# Edit files to resolve conflicts
# Look for: <<<<<<< HEAD, =======, >>>>>>> branch

# After resolving
git add resolved-file.ts
git commit
```

---

## Tag Rules

### Rule 11: Use Semantic Versioning for Tags

**Severity**: HIGH 🟠

**Format**: `vMAJOR.MINOR.PATCH`

```bash
# ✅ GOOD
git tag v1.0.0
git tag v1.2.3
git tag v2.0.0-beta.1

# ❌ BAD
git tag release
git tag version1
```

**When to Bump**:
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

---

## Pre-Commit Checklist

Before EVERY commit:

- [ ] No secrets in code
- [ ] Tests pass locally
- [ ] Lint passes (no errors)
- [ ] Commit message follows format
- [ ] Files staged are correct (`git status`)
- [ ] No debug code (`console.log`, `debugger`)
- [ ] No commented-out code blocks

---

## Pre-Push Checklist

Before EVERY push:

- [ ] Pulled latest changes
- [ ] Tests pass
- [ ] Build succeeds
- [ ] No merge conflicts
- [ ] Pushing to correct branch
- [ ] Commit messages are meaningful

---

## Emergency Procedures

### Committed Secret by Accident

1. **Rotate credentials immediately**
2. **Remove from git history** (see Rule 1)
3. **Force push** (with team notification)
4. **Add to .gitignore**

### Pushed to Wrong Branch

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Switch to correct branch
git checkout correct-branch

# Commit again
git add .
git commit -m "correct message"
```

### Need to Undo Last Commit

```bash
# Undo commit, keep changes
git reset --soft HEAD~1

# Undo commit, discard changes
git reset --hard HEAD~1  # CAREFUL: destroys changes
```

---

## References

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Best Practices](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project)
- [Semantic Versioning](https://semver.org/)
