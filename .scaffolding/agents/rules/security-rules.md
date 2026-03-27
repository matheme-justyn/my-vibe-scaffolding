# Security Rules

**Purpose**: Prevent security vulnerabilities and enforce secure coding practices.

## CRITICAL Security Rules (🔴 Never Violate)

### Rule 1: Never Hardcode Secrets

```typescript
// ❌ FORBIDDEN
const API_KEY = "sk-proj-xxxxxxxxxxxxx"
const DB_PASSWORD = "mypassword123"

// ✅ REQUIRED
const API_KEY = process.env.OPENAI_API_KEY
if (!API_KEY) throw new Error('API_KEY not configured')
```

### Rule 2: Always Use Parameterized Queries

```typescript
// ❌ SQL INJECTION VULNERABILITY
db.query(`SELECT * FROM users WHERE email = '${email}'`)

// ✅ SAFE
db.query('SELECT * FROM users WHERE email = $1', [email])
```

### Rule 3: Validate ALL User Input

```typescript
// ✅ REQUIRED
import { z } from 'zod'

const UserSchema = z.object({
  email: z.string().email(),
  age: z.number().min(0).max(150)
})

const validated = UserSchema.parse(input)  // Throws if invalid
```

### Rule 4: Use httpOnly Cookies for Tokens

```typescript
// ❌ VULNERABLE TO XSS
localStorage.setItem('token', token)

// ✅ SECURE
res.setHeader('Set-Cookie', `token=${token}; HttpOnly; Secure; SameSite=Strict`)
```

### Rule 5: Hash Passwords with bcrypt

```typescript
// ❌ INSECURE
const hash = crypto.createHash('sha256').update(password).digest('hex')

// ✅ SECURE
import bcrypt from 'bcrypt'
const hash = await bcrypt.hash(password, 10)
```

## HIGH Priority Security Rules (🟠)

### Rule 6: Sanitize HTML Before Rendering

```typescript
// ❌ XSS VULNERABILITY
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// ✅ SAFE
import DOMPurify from 'dompurify'
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />
```

### Rule 7: Implement Rate Limiting

```typescript
import rateLimit from 'express-rate-limit'

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 100  // 100 requests per window
})

app.use('/api/', limiter)
```

### Rule 8: Enable CSRF Protection

```typescript
import csrf from 'csurf'

app.use(csrf({ cookie: true }))

app.post('/api/users', (req, res) => {
  // CSRF token automatically verified
})
```

### Rule 9: Set Security Headers

```typescript
// In Next.js config
const securityHeaders = [
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'Strict-Transport-Security', value: 'max-age=31536000' },
  { key: 'Content-Security-Policy', value: "default-src 'self'" }
]
```

### Rule 10: Implement Row Level Security (RLS)

```sql
-- In Supabase/PostgreSQL
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);
```

## MEDIUM Priority Security Rules (🟡)

### Rule 11: Keep Dependencies Updated

```bash
npm audit
npm audit fix
npm update
```

### Rule 12: Don't Expose Stack Traces in Production

```typescript
app.use((err, req, res, next) => {
  console.error(err)  // Log internally
  
  res.status(500).json({
    error: 'Internal server error'  // Generic message to user
    // NEVER: error: err.message, stack: err.stack
  })
})
```

### Rule 13: Use HTTPS in Production

```typescript
if (process.env.NODE_ENV === 'production' && !req.secure) {
  return res.redirect('https://' + req.headers.host + req.url)
}
```

## Checklist (MUST Complete Before Production)

- [ ] No hardcoded secrets
- [ ] All queries parameterized
- [ ] Input validation on all endpoints
- [ ] Tokens in httpOnly cookies
- [ ] Passwords hashed with bcrypt
- [ ] HTML sanitized before rendering
- [ ] Rate limiting enabled
- [ ] CSRF protection enabled
- [ ] Security headers configured
- [ ] RLS enabled in database
- [ ] Dependencies up to date
- [ ] HTTPS enforced
- [ ] Error messages don't leak details
- [ ] No console.log with sensitive data
- [ ] File uploads validated (size, type)

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)
