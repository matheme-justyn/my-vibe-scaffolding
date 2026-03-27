---
name: security-review
version: 2.0.0
description: Security review with Iron Laws enforcement - authentication, user input handling, secrets management, API security, and comprehensive vulnerability prevention for production systems.
origin: ECC (everything-claude-code)
adapted_for: OpenCode
transformation: Superpowers Iron Laws integration
---

# Security Review v2.0

## Iron Laws (Superpowers Style)

### 1. NO SECRETS IN CODE OR LOGS

**❌ BAD**:
```typescript
// Hardcoded secrets
const apiKey = "sk-proj-xxxxx"
const dbPassword = "password123"
const jwtSecret = "my-secret-key"

// Logging secrets
console.log('User login:', { email, password })
console.log('Payment:', { cardNumber, cvv })
console.log('API call:', { Authorization: apiKey })
```

**✅ GOOD**:
```typescript
// Environment variables only
const apiKey = process.env.OPENAI_API_KEY
const dbUrl = process.env.DATABASE_URL
const jwtSecret = process.env.JWT_SECRET

// Verify secrets exist
if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}

// Redacted logging
console.log('User login:', { email, userId })
console.log('Payment:', { last4: card.last4, userId })
console.log('API call:', { endpoint: '/api/data', status: 200 })
```

**Violation Handling**: Rotate compromised secrets immediately, revert commits, scan git history

**No Excuses**:
- ❌ "It's just for testing"
- ❌ "No one will see the logs"
- ❌ "I'll move it to .env later"

**Enforcement**: Pre-commit hooks (detect-secrets, git-secrets), CI/CD secret scanning (Trufflehog), code review

---

### 2. NO SQL CONCATENATION (PARAMETERIZED QUERIES ONLY)

**❌ BAD**:
```typescript
// SQL Injection vulnerability
const query = `SELECT * FROM users WHERE email = '${userEmail}'`
await db.query(query)

// Still vulnerable with template literals
const query = `
  SELECT * FROM orders 
  WHERE user_id = ${userId} 
  AND status = '${status}'
`
```

**✅ GOOD**:
```typescript
// Parameterized query (Supabase)
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('email', userEmail)

// Parameterized query (raw SQL)
await db.query(
  'SELECT * FROM orders WHERE user_id = $1 AND status = $2',
  [userId, status]
)

// ORM (Prisma)
await prisma.user.findUnique({
  where: { email: userEmail }
})
```

**Violation Handling**: Replace ALL string concatenation in SQL with parameterized queries

**No Excuses**:
- ❌ "I sanitized the input"
- ❌ "It's only internal data"
- ❌ "The ORM handles it"

**Enforcement**: Static analysis (SQLMap, semgrep), code review blocking, database query logging

---

### 3. NO EVAL OR UNSAFE DYNAMIC CODE

**❌ BAD**:
```typescript
// Direct eval
const result = eval(userInput)

// Indirect eval
const fn = new Function(userInput)
fn()

// Unsafe deserialization
const obj = JSON.parse(untrustedInput)
obj.constructor('return process')().exit()

// Dynamic require
const module = require(userProvidedPath)
```

**✅ GOOD**:
```typescript
// Use safe parsing
const schema = z.object({
  action: z.enum(['add', 'subtract', 'multiply']),
  value: z.number()
})

const validated = schema.parse(JSON.parse(userInput))

// Whitelist approach
const allowedActions = {
  add: (x: number) => x + 1,
  subtract: (x: number) => x - 1
}

const action = allowedActions[validated.action]
if (action) {
  return action(validated.value)
}
```

**Violation Handling**: Rewrite logic without eval, use sandboxed execution (VM2, isolated-vm) if absolutely necessary

**No Excuses**:
- ❌ "I need dynamic behavior"
- ❌ "Input is validated"
- ❌ "It's from trusted source"

**Enforcement**: ESLint rule `no-eval`, security linter (Semgrep, Bandit for Python)

---

### 4. NO AUTHENTICATION IN LOCALSTORAGE (HTTPONLY COOKIES ONLY)

**❌ BAD**:
```typescript
// localStorage (vulnerable to XSS)
localStorage.setItem('token', jwtToken)
localStorage.setItem('refreshToken', refreshToken)

// sessionStorage (still vulnerable)
sessionStorage.setItem('auth', JSON.stringify({ token, user }))

// Regular cookie (no HttpOnly)
document.cookie = `token=${jwtToken}`
```

**✅ GOOD**:
```typescript
// HttpOnly, Secure, SameSite cookies (server-side only)
res.setHeader('Set-Cookie', [
  `token=${jwtToken}; HttpOnly; Secure; SameSite=Strict; Max-Age=3600; Path=/`,
  `refreshToken=${refreshToken}; HttpOnly; Secure; SameSite=Strict; Max-Age=604800; Path=/api/auth/refresh`
])

// For SPAs needing auth state (public user info only)
localStorage.setItem('user', JSON.stringify({
  id: user.id,
  email: user.email,
  role: user.role
  // NO tokens here
}))
```

**Violation Handling**: Migrate to httpOnly cookies, invalidate all existing localStorage tokens

**No Excuses**:
- ❌ "My SPA needs to access the token"
- ❌ "localStorage is convenient"
- ❌ "We don't have XSS vulnerabilities"

**Enforcement**: Security audit, CSP headers, automated XSS testing

---

### 5. NO MISSING INPUT VALIDATION (WHITELIST SCHEMA REQUIRED)

**❌ BAD**:
```typescript
// No validation
async function createUser(req, res) {
  const user = await db.users.create(req.body)
  res.json(user)
}

// Blacklist validation (incomplete)
if (email.includes('admin') || email.includes('root')) {
  throw new Error('Invalid email')
}

// Type checking only
if (typeof age === 'number') {
  // Still accepts NaN, negative, etc.
}
```

**✅ GOOD**:
```typescript
// Whitelist schema validation (Zod)
const CreateUserSchema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150),
  role: z.enum(['user', 'admin'])
})

async function createUser(req, res) {
  try {
    const validated = CreateUserSchema.parse(req.body)
    const user = await db.users.create(validated)
    res.status(201).json({ data: user })
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          details: error.errors
        }
      })
    }
  }
}
```

**Violation Handling**: Add schema validation to ALL endpoints accepting user input

**No Excuses**:
- ❌ "Frontend already validates"
- ❌ "Database has constraints"
- ❌ "It's just internal API"

**Enforcement**: API integration tests, OpenAPI schema validation, security testing (OWASP ZAP)

---

## Implementation Details (Original ECC)

### Secrets Management

#### Environment Variables

```typescript
// ✅ ALWAYS use environment variables
const config = {
  openaiKey: process.env.OPENAI_API_KEY,
  dbUrl: process.env.DATABASE_URL,
  jwtSecret: process.env.JWT_SECRET,
  stripeKey: process.env.STRIPE_SECRET_KEY
}

// Verify all required secrets exist
const requiredEnvVars = ['OPENAI_API_KEY', 'DATABASE_URL', 'JWT_SECRET']
for (const varName of requiredEnvVars) {
  if (!process.env[varName]) {
    throw new Error(`Missing required environment variable: ${varName}`)
  }
}

// .env.local in .gitignore
OPENAI_API_KEY=sk-proj-xxxxx
DATABASE_URL=postgresql://...
JWT_SECRET=random-secure-string-min-32-chars
```

### Input Validation

#### Schema Validation with Zod

```typescript
import { z } from 'zod'

// Define strict schemas
const CreateUserSchema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(1).max(100).regex(/^[a-zA-Z\s]+$/),
  age: z.number().int().min(0).max(150),
  role: z.enum(['user', 'admin', 'moderator'])
})

// File upload validation
const FileUploadSchema = z.object({
  name: z.string().max(255),
  size: z.number().max(5 * 1024 * 1024), // 5MB
  type: z.enum(['image/jpeg', 'image/png', 'image/gif'])
})

function validateFileUpload(file: File) {
  try {
    FileUploadSchema.parse({
      name: file.name,
      size: file.size,
      type: file.type
    })
    
    // Extension check
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif']
    const extension = file.name.toLowerCase().match(/\.[^.]+$/)?.[0]
    if (!extension || !allowedExtensions.includes(extension)) {
      throw new Error('Invalid file extension')
    }
    
    return true
  } catch (error) {
    throw new Error('File validation failed')
  }
}
```

### SQL Injection Prevention

#### Supabase (Safe by Default)

```typescript
// ✅ All queries parameterized
const { data, error } = await supabase
  .from('users')
  .select('*')
  .eq('email', userEmail)
  .single()

// ✅ Filtered queries
const { data } = await supabase
  .from('orders')
  .select('*')
  .eq('user_id', userId)
  .in('status', ['pending', 'processing'])
  .gte('created_at', startDate)
```

#### Raw SQL (Parameterized)

```typescript
// ✅ Parameterized query
await db.query(
  'SELECT * FROM users WHERE email = $1 AND role = $2',
  [userEmail, role]
)

// ✅ Named parameters (some libraries)
await db.query(
  'SELECT * FROM users WHERE email = :email AND role = :role',
  { email: userEmail, role }
)
```

### Authentication & Authorization

#### JWT Token Handling

```typescript
// ✅ HttpOnly cookies (server-side only)
export function setAuthCookies(res: Response, tokens: Tokens) {
  const isProduction = process.env.NODE_ENV === 'production'
  
  res.setHeader('Set-Cookie', [
    `accessToken=${tokens.accessToken}; HttpOnly; Secure=${isProduction}; SameSite=Strict; Max-Age=900; Path=/`,
    `refreshToken=${tokens.refreshToken}; HttpOnly; Secure=${isProduction}; SameSite=Strict; Max-Age=604800; Path=/api/auth/refresh`
  ])
}

// ✅ Authorization checks
export async function requireAuth(req: Request, res: Response, next: NextFunction) {
  const token = req.cookies.accessToken
  
  if (!token) {
    return res.status(401).json({
      error: { code: 'UNAUTHORIZED', message: 'Authentication required' }
    })
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!)
    req.user = decoded
    next()
  } catch (error) {
    return res.status(401).json({
      error: { code: 'INVALID_TOKEN', message: 'Invalid or expired token' }
    })
  }
}

// ✅ Role-based authorization
export function requireRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({
        error: { code: 'UNAUTHORIZED', message: 'Authentication required' }
      })
    }
    
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        error: { code: 'FORBIDDEN', message: 'Insufficient permissions' }
      })
    }
    
    next()
  }
}
```

#### Row Level Security (Supabase)

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Users can only view their own data
CREATE POLICY "Users view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Users can only update their own data
CREATE POLICY "Users update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Users can only view their own orders
CREATE POLICY "Users view own orders"
  ON orders FOR SELECT
  USING (auth.uid() = user_id);

-- Admins can view everything
CREATE POLICY "Admins view all"
  ON users FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### XSS Prevention

#### Content Sanitization

```typescript
import DOMPurify from 'isomorphic-dompurify'

// ✅ Sanitize user HTML
function renderUserContent(html: string) {
  const clean = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p', 'br', 'ul', 'ol', 'li'],
    ALLOWED_ATTR: ['class']
  })
  return <div dangerouslySetInnerHTML={{ __html: clean }} />
}

// ✅ Escape output
function escapeHtml(unsafe: string): string {
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;")
}
```

#### Content Security Policy

```typescript
// next.config.js
const securityHeaders = [
  {
    key: 'Content-Security-Policy',
    value: `
      default-src 'self';
      script-src 'self' 'unsafe-eval' 'unsafe-inline';
      style-src 'self' 'unsafe-inline';
      img-src 'self' data: https:;
      font-src 'self';
      connect-src 'self' https://api.example.com;
      frame-ancestors 'none';
    `.replace(/\s{2,}/g, ' ').trim()
  },
  {
    key: 'X-Frame-Options',
    value: 'DENY'
  },
  {
    key: 'X-Content-Type-Options',
    value: 'nosniff'
  },
  {
    key: 'Referrer-Policy',
    value: 'origin-when-cross-origin'
  },
  {
    key: 'Permissions-Policy',
    value: 'camera=(), microphone=(), geolocation=()'
  }
]
```

### CSRF Protection

```typescript
import { csrf } from '@/lib/csrf'

// ✅ CSRF token validation
export async function POST(request: Request) {
  const token = request.headers.get('X-CSRF-Token')

  if (!csrf.verify(token)) {
    return NextResponse.json(
      { error: { code: 'CSRF_ERROR', message: 'Invalid CSRF token' } },
      { status: 403 }
    )
  }

  // Process request
}

// ✅ SameSite cookies
res.setHeader('Set-Cookie',
  `session=${sessionId}; HttpOnly; Secure; SameSite=Strict`)
```

### Rate Limiting

```typescript
import rateLimit from 'express-rate-limit'

// ✅ Global rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  message: 'Too many requests',
  standardHeaders: true,
  legacyHeaders: false
})

app.use('/api/', limiter)

// ✅ Aggressive rate limiting for auth
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 attempts per 15 minutes
  skipSuccessfulRequests: true
})

app.post('/api/auth/login', authLimiter, loginHandler)

// ✅ Per-user rate limiting
const perUserLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 10,
  keyGenerator: (req) => req.user?.id || req.ip
})
```

### Sensitive Data Exposure

#### Logging Best Practices

```typescript
// ❌ WRONG: Logging sensitive data
console.log('User login:', { email, password })
console.log('Payment:', { cardNumber, cvv })
console.log('API response:', fullResponse)

// ✅ CORRECT: Redacted logging
console.log('User login:', {
  email,
  userId: user.id,
  timestamp: new Date()
})

console.log('Payment processed:', {
  userId: user.id,
  amount: payment.amount,
  last4: payment.card.last4,
  status: payment.status
})

console.log('API response:', {
  status: response.status,
  dataLength: response.data.length
})
```

#### Error Messages

```typescript
// ❌ WRONG: Exposing internal details
catch (error) {
  return NextResponse.json(
    { error: error.message, stack: error.stack },
    { status: 500 }
  )
}

// ✅ CORRECT: Generic error messages
catch (error) {
  console.error('Internal error:', error)
  return NextResponse.json(
    {
      error: {
        code: 'INTERNAL_ERROR',
        message: 'An error occurred. Please try again.'
      },
      meta: {
        request_id: req.id
      }
    },
    { status: 500 }
  )
}
```

### Dependency Security

```bash
# Check for vulnerabilities
npm audit

# Fix automatically fixable issues
npm audit fix

# Update dependencies
npm update

# Check for outdated packages
npm outdated
```

### Pre-Deployment Security Checklist

Before ANY production deployment:

- [ ] **Secrets**: No hardcoded secrets, all in env vars
- [ ] **Input Validation**: All user inputs validated with schemas
- [ ] **SQL Injection**: All queries parameterized
- [ ] **XSS**: User content sanitized, CSP configured
- [ ] **CSRF**: Protection enabled on state-changing operations
- [ ] **Authentication**: Tokens in httpOnly cookies
- [ ] **Authorization**: Role checks in place, RLS enabled
- [ ] **Rate Limiting**: Enabled on all endpoints
- [ ] **HTTPS**: Enforced in production
- [ ] **Security Headers**: CSP, X-Frame-Options configured
- [ ] **Error Handling**: No sensitive data in errors
- [ ] **Logging**: No sensitive data logged
- [ ] **Dependencies**: Up to date, no vulnerabilities
- [ ] **CORS**: Properly configured
- [ ] **File Uploads**: Validated (size, type, extension)
- [ ] **No eval/unsafe code**: No dynamic code execution

---

## OpenCode Integration

**When to Use**:
- Implementing authentication or authorization
- Handling user input or file uploads
- Creating new API endpoints
- Working with secrets or credentials
- Implementing payment features
- Storing or transmitting sensitive data
- Integrating third-party APIs

**Load this skill when**:
- User mentions "security", "authentication", "API", "sensitive"
- Creating backend services handling user data
- Reviewing code for security vulnerabilities

**Usage Pattern**:
```typescript
// Automatically loaded when AGENTS.md detects security keywords
// Or manually load:
@use security-review
User: "Implement user authentication with JWT"
```

---

**Remember**: Security is not optional. One vulnerability can compromise the entire system. These Iron Laws are non-negotiable.
