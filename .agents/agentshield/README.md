# AgentShield - AI Configuration Security

**Version**: 1.0.0 (Simplified)  
**Origin**: [everything-claude-code AgentShield](https://github.com/affaan-m/everything-claude-code)  
**Adapted for**: OpenCode

## Overview

AgentShield provides security guardrails for AI agent operations, preventing configuration vulnerabilities and ensuring safe AI-assisted development.

## What is AgentShield?

AgentShield is a security layer that:
- **Prevents unsafe AI actions** (e.g., deleting production data)
- **Enforces security policies** (e.g., no secrets in code)
- **Validates AI decisions** (e.g., confirming destructive operations)
- **Provides audit trails** (logging AI actions)

## Core Security Rules (Simplified Implementation)

### Category 1: File Operations (Critical)

**Rule**: Never delete or overwrite files without explicit confirmation

```typescript
// ❌ BLOCKED: AI cannot do this without user confirmation
await fs.unlink('/path/to/important/file')
await fs.rm('/directory', { recursive: true })

// ✅ ALLOWED: After user confirms
User: "Delete the test files"
AI: "I will delete 3 files in tests/. Confirm? (yes/no)"
User: "yes"
AI: [Proceeds with deletion]
```

### Category 2: Command Execution (Critical)

**Rule**: Never execute destructive shell commands without confirmation

```bash
# ❌ BLOCKED: Requires confirmation
rm -rf /
DROP DATABASE production
git push --force origin main

# ✅ ALLOWED: Safe read-only commands
ls
cat file.txt
git status
npm test
```

### Category 3: External Services (High)

**Rule**: Never call external APIs with user credentials without confirmation

```typescript
// ❌ BLOCKED: Requires explicit permission
await fetch('https://api.example.com/charge', {
  method: 'POST',
  body: JSON.stringify({ amount: 1000, card: userCard })
})

// ✅ ALLOWED: After user authorizes
User: "Charge $10 to my card"
AI: "I will charge $10.00 to card ending in 1234. Confirm? (yes/no)"
```

### Category 4: Code Modification (Medium)

**Rule**: Never modify code that handles authentication or payments without review

```typescript
// ⚠️ REQUIRES REVIEW: Security-sensitive code
function hashPassword(password: string) {
  // AI must flag this for human review
}

function processPayment(amount: number, card: CreditCard) {
  // AI must flag this for human review
}
```

### Category 5: Data Access (Medium)

**Rule**: Never read sensitive files without explicit permission

```bash
# ⚠️ REQUIRES PERMISSION
cat ~/.ssh/id_rsa
cat .env.production
cat /etc/passwd
```

## Implementation

### 1. Pre-Action Validation

Before executing any action, AI checks AgentShield rules:

```typescript
interface Action {
  type: 'file' | 'command' | 'api' | 'code' | 'data'
  operation: string
  target: string
  severity: 'critical' | 'high' | 'medium' | 'low'
}

function validateAction(action: Action): ValidationResult {
  // Check against AgentShield rules
  if (action.severity === 'critical') {
    return { allowed: false, requiresConfirmation: true }
  }
  
  if (action.severity === 'high' && !userConfirmed) {
    return { allowed: false, requiresConfirmation: true }
  }
  
  return { allowed: true }
}
```

### 2. Confirmation Protocol

For blocked actions, AI must request explicit confirmation:

```
AI: "⚠️ Security Warning: This action requires confirmation.

Action: Delete file 'database.db'
Severity: CRITICAL
Impact: Irreversible data loss

Type 'CONFIRM' to proceed, or 'CANCEL' to abort."

User: "CONFIRM"

AI: [Executes action]
```

### 3. Audit Logging

All actions are logged for accountability:

```json
{
  "timestamp": "2025-03-12T14:00:00Z",
  "action": "file_delete",
  "target": "database.db",
  "severity": "critical",
  "confirmed": true,
  "user": "user@example.com"
}
```

## Security Checklist (AI Must Verify)

### Before File Operations
- [ ] Not deleting production files
- [ ] Not overwriting configuration
- [ ] Not modifying .git/ directory
- [ ] User confirmed destructive actions

### Before Command Execution
- [ ] Command is safe (read-only or approved)
- [ ] Not executing as root/sudo
- [ ] Not modifying system files
- [ ] User confirmed if destructive

### Before External API Calls
- [ ] User authorized API access
- [ ] Credentials are properly secured
- [ ] Rate limits respected
- [ ] Error handling present

### Before Code Modification
- [ ] Not modifying authentication logic (without review)
- [ ] Not modifying payment processing (without review)
- [ ] Not removing security checks
- [ ] Tests exist for changes

### Before Data Access
- [ ] Not accessing sensitive credentials
- [ ] Not exposing private keys
- [ ] Not reading production secrets
- [ ] User authorized access

## Quick Reference: Action Severity

| Action | Severity | Confirmation Required? |
|--------|----------|------------------------|
| Read file | LOW | No |
| Write new file | LOW | No |
| Modify existing file | MEDIUM | If security-sensitive |
| Delete file | CRITICAL | Yes |
| Execute read command | LOW | No |
| Execute write command | HIGH | Yes |
| Execute destructive command | CRITICAL | Yes (CONFIRM) |
| Call external API | MEDIUM | If using credentials |
| Modify auth code | HIGH | Yes (review required) |
| Access secrets | CRITICAL | Yes |

## Integration with Existing Systems

### With Security Rules

AgentShield complements `.agents/rules/security-rules.md`:
- **Rules**: Define what secure code looks like
- **AgentShield**: Prevents AI from creating insecure code

### With Commands

AgentShield validates command execution:
- `security-scan` → Uses AgentShield rules
- `code-review` → Flags AgentShield violations

## Extending AgentShield

To add custom security rules:

1. Identify risky operations in your domain
2. Define severity level (CRITICAL/HIGH/MEDIUM/LOW)
3. Specify confirmation requirements
4. Add to validation logic

## References

- **Source**: https://github.com/affaan-m/everything-claude-code
- **Original AgentShield**: 102 rules across multiple categories
- **This Implementation**: Simplified 5-category framework

---

**Note**: This is a simplified implementation of AgentShield focused on core security concerns. For the full 102-rule system, refer to the original everything-claude-code repository.

**Status**: Phase 1.5 Complete ✅
