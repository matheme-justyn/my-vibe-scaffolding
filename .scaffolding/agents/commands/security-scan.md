---
description: Security audit scanning for vulnerabilities and best practices
agent: security-reviewer
subtask: true
---

# Security Scan Command

Comprehensive security audit for: $ARGUMENTS

## Your Task

1. **Scan for secrets** - Check for hardcoded credentials
2. **Dependency audit** - Check for vulnerable packages
3. **Code analysis** - Identify security anti-patterns
4. **Configuration review** - Check security headers, CORS, etc.

## Scan Categories

### 1. Secrets Detection

```bash
# Search for common secret patterns
git grep -E "api[_-]?key|secret|password|token" -- '*.ts' '*.js' '*.env*'

# Check for AWS keys
git grep -E "AKIA[0-9A-Z]{16}" .

# Check for private keys
git grep -E "BEGIN.*PRIVATE KEY" .
```

**Check for**:
- [ ] API keys in source code
- [ ] Database passwords
- [ ] JWT secrets
- [ ] AWS/GCP credentials
- [ ] OAuth tokens
- [ ] Private keys

### 2. Dependency Vulnerabilities

```bash
# Node.js
npm audit
npm audit --production

# Python
pip-audit
safety check

# Go
go list -json -m all | nancy sleuth
```

**Actions**:
- [ ] List all vulnerabilities (HIGH/MEDIUM/LOW)
- [ ] Show CVE numbers
- [ ] Recommend fixes or updates

### 3. Code Security Patterns

**SQL Injection**:
```typescript
// ❌ DANGEROUS
db.query(`SELECT * FROM users WHERE id = '${userId}'`)

// ✅ SAFE
db.query('SELECT * FROM users WHERE id = $1', [userId])
```

**XSS Prevention**:
```typescript
// ❌ DANGEROUS
dangerouslySetInnerHTML={{ __html: userInput }}

// ✅ SAFE
import DOMPurify from 'dompurify'
dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }}
```

**Authentication**:
- [ ] Tokens stored in httpOnly cookies (not localStorage)
- [ ] Password hashing (bcrypt, not SHA256)
- [ ] Rate limiting on auth endpoints
- [ ] CSRF protection enabled

### 4. Configuration Security

```bash
# Check security headers
curl -I https://your-app.com | grep -E "X-|Strict|Content-Security"

# Expected headers:
# Strict-Transport-Security
# X-Frame-Options: DENY
# X-Content-Type-Options: nosniff
# Content-Security-Policy
```

**Check**:
- [ ] HTTPS enforced
- [ ] Security headers present
- [ ] CORS properly configured
- [ ] Rate limiting enabled
- [ ] Input validation on all endpoints

### 5. File Upload Security

- [ ] File size limits enforced
- [ ] File type validation (MIME + extension)
- [ ] No executable uploads
- [ ] Files stored outside webroot
- [ ] Virus scanning (if applicable)

## Report Format

```
Security Scan Report
====================

🔴 CRITICAL (0)
  (none found)

🟠 HIGH (2)
  1. Hardcoded API key in src/config.ts:12
     Fix: Move to environment variable
     
  2. SQL injection vulnerability in src/api/users.ts:45
     Fix: Use parameterized queries

🟡 MEDIUM (5)
  3. Missing CSRF protection on POST /api/users
  4. Weak password requirements (< 8 chars)
  5. console.log() with sensitive data in src/auth.ts:89
  6. Missing rate limiting on /api/login
  7. localStorage used for tokens (use httpOnly cookies)

🟢 LOW (3)
  8. Outdated dependency: express@4.17.1 (upgrade to 4.18.2)
  9. Missing security headers (CSP, X-Frame-Options)
  10. Error messages expose stack traces

Dependency Audit:
  Total Dependencies: 234
  Vulnerabilities: 8 (2 high, 4 medium, 2 low)
  
  Package: lodash@4.17.19
  Severity: HIGH
  CVE: CVE-2020-8203
  Fix: npm update lodash@4.17.21
```

## Recommendations Priority

1. **CRITICAL**: Stop deployment, fix immediately
2. **HIGH**: Fix before merging to main
3. **MEDIUM**: Fix before production deployment
4. **LOW**: Plan fixes in next sprint

## Quick Security Checklist

- [ ] No secrets in code or git history
- [ ] All dependencies up to date
- [ ] Input validation on all endpoints
- [ ] Authentication properly implemented
- [ ] Authorization checks before sensitive operations
- [ ] HTTPS enforced
- [ ] Security headers configured
- [ ] Rate limiting enabled
- [ ] Logs don't contain sensitive data
- [ ] Error messages don't leak internal details

---

**IMPORTANT**: Never deploy code with CRITICAL or HIGH security issues!
