---
name: error-handling
version: 2.0.0
description: Error handling with Iron Laws enforcement - comprehensive error types, middleware, logging, user-facing messages, and recovery strategies for production systems.
origin: ECC-derived (extracted from backend-patterns and security-review)
adapted_for: OpenCode
transformation: Superpowers Iron Laws integration
---

# Error Handling Patterns v2.0

## Iron Laws (Superpowers Style)

### 1. NO EMPTY CATCH BLOCKS

**❌ BAD**:
```typescript
// Silent failure
try {
  await sendEmail(user.email)
} catch (error) {
  // Nothing - error disappears
}

// Logging but no handling
try {
  await processPayment(order)
} catch (error) {
  console.log('Error:', error)
  // Returns undefined, caller doesn't know it failed
}
```

**✅ GOOD**:
```typescript
// Proper error propagation
try {
  await sendEmail(user.email)
} catch (error) {
  console.error('Email send failed:', error)
  throw new AppError(
    'Failed to send email notification',
    500,
    'EMAIL_SEND_FAILED'
  )
}

// Graceful degradation with fallback
try {
  await processPayment(order)
} catch (error) {
  console.error('Payment processing failed:', error)
  await saveFailedPayment(order, error)
  throw new AppError(
    'Payment processing failed. Please try again.',
    500,
    'PAYMENT_FAILED'
  )
}
```

**Violation Handling**: Add proper error handling, logging, and propagation to ALL catch blocks

**No Excuses**:
- ❌ "It's not a critical error"
- ❌ "I'll handle it later"
- ❌ "The caller doesn't need to know"

**Enforcement**: ESLint rule `no-empty-pattern`, code review, pre-commit hooks

---

### 2. NO SWALLOWED ERRORS (MUST LOG OR THROW)

**❌ BAD**:
```typescript
// Error absorbed, no trace
async function fetchUserData(id: string) {
  try {
    return await api.getUser(id)
  } catch {
    return null  // Caller thinks user doesn't exist
  }
}

// Promise rejection ignored
sendAnalytics(event)  // Fire-and-forget, failures invisible
```

**✅ GOOD**:
```typescript
// Log and rethrow
async function fetchUserData(id: string) {
  try {
    return await api.getUser(id)
  } catch (error) {
    console.error('User fetch failed:', { userId: id, error })
    throw new NotFoundError('User', id)
  }
}

// Log fire-and-forget failures
sendAnalytics(event).catch(error => {
  console.error('Analytics send failed (non-blocking):', error)
})

// Or make failure explicit
async function fetchUserDataSafe(id: string): Promise<User | null> {
  try {
    return await api.getUser(id)
  } catch (error) {
    console.warn('User fetch failed, returning null:', error)
    return null
  }
}
```

**Violation Handling**: Add explicit logging to ALL error paths, document intentional swallowing

**No Excuses**:
- ❌ "Failures are rare"
- ❌ "It's just analytics"
- ❌ "Logging is expensive"

**Enforcement**: Unhandled rejection tracking, error monitoring (Sentry), code review

---

### 3. NO STRING ERRORS (USE ERROR CLASSES)

**❌ BAD**:
```typescript
// String throw (no stack trace, no type safety)
throw 'User not found'

// Generic Error (no metadata)
throw new Error('Something went wrong')

// Object literal (not instanceof Error)
throw { message: 'Invalid input', code: 400 }
```

**✅ GOOD**:
```typescript
// Custom error class with metadata
export class NotFoundError extends AppError {
  constructor(resource: string, id?: string) {
    super(
      `${resource}${id ? ` with id ${id}` : ''} not found`,
      404,
      'NOT_FOUND'
    )
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public fields?: Record<string, string>) {
    super(message, 400, 'VALIDATION_ERROR')
  }
}

// Usage
throw new NotFoundError('User', userId)
throw new ValidationError('Invalid input', { email: 'Invalid format' })
```

**Violation Handling**: Replace all string throws with proper Error classes

**No Excuses**:
- ❌ "It's just a quick prototype"
- ❌ "Error classes are boilerplate"
- ❌ "Strings are simpler"

**Enforcement**: TypeScript strict mode, ESLint rule `no-throw-literal`, code review

---

### 4. NO 200 OK WITH ERROR IN BODY

**❌ BAD**:
```typescript
// HTTP 200 with error in body
app.get('/users/:id', (req, res) => {
  const user = getUser(req.params.id)
  if (!user) {
    res.status(200).json({
      success: false,
      error: 'User not found'
    })
  }
})

// All responses 200, client checks success field
res.status(200).json({ success: false, message: 'Unauthorized' })
```

**✅ GOOD**:
```typescript
// Proper HTTP status codes
app.get('/users/:id', (req, res) => {
  const user = getUser(req.params.id)
  if (!user) {
    res.status(404).json({
      error: {
        code: 'NOT_FOUND',
        message: 'User not found'
      }
    })
    return
  }
  
  res.status(200).json({ data: user })
})

// HTTP status reflects outcome
res.status(401).json({
  error: {
    code: 'UNAUTHORIZED',
    message: 'Authentication required'
  }
})
```

**Violation Handling**: Use proper HTTP status codes for ALL error responses

**No Excuses**:
- ❌ "Frontend expects 200 for everything"
- ❌ "It's easier to handle in JavaScript"
- ❌ "Our legacy API does this"

**Enforcement**: API contract tests, HTTP status code validation in CI/CD

---

### 5. NO UNHANDLED ASYNC REJECTIONS

**❌ BAD**:
```typescript
// Unhandled rejection (crashes in production)
app.get('/data', async (req, res) => {
  const data = await fetchData()  // If this fails, no catch
  res.json(data)
})

// Fire-and-forget without catch
async function processOrder(order: Order) {
  sendConfirmationEmail(order.email)  // Unhandled rejection
  await updateInventory(order)
}
```

**✅ GOOD**:
```typescript
// asyncHandler wrapper
export function asyncHandler(fn: Function) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next)
  }
}

app.get('/data', asyncHandler(async (req, res) => {
  const data = await fetchData()  // Errors caught by wrapper
  res.json(data)
}))

// Explicit error handling
async function processOrder(order: Order) {
  sendConfirmationEmail(order.email).catch(error => {
    console.error('Email send failed (non-blocking):', error)
  })
  
  await updateInventory(order)  // Propagates errors
}
```

**Violation Handling**: Wrap all async route handlers, add .catch() to fire-and-forget promises

**No Excuses**:
- ❌ "I'll add error handling later"
- ❌ "It rarely fails"
- ❌ "The framework handles it"

**Enforcement**: Unhandled rejection monitoring, linting rules, integration tests

---

## Implementation Details (Original ECC)

### Error Types Hierarchy

```typescript
// Base application error
export class AppError extends Error {
  constructor(
    public message: string,
    public statusCode: number,
    public code: string,
    public isOperational: boolean = true
  ) {
    super(message)
    this.name = this.constructor.name
    Error.captureStackTrace(this, this.constructor)
  }
}

// Specific error types
export class ValidationError extends AppError {
  constructor(message: string, public fields?: Record<string, string>) {
    super(message, 400, 'VALIDATION_ERROR')
  }
}

export class AuthenticationError extends AppError {
  constructor(message: string = 'Authentication required') {
    super(message, 401, 'AUTH_ERROR')
  }
}

export class AuthorizationError extends AppError {
  constructor(message: string = 'Insufficient permissions') {
    super(message, 403, 'FORBIDDEN')
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id?: string) {
    super(
      `${resource}${id ? ` with id ${id}` : ''} not found`,
      404,
      'NOT_FOUND'
    )
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(message, 409, 'CONFLICT')
  }
}

export class RateLimitError extends AppError {
  constructor(message: string = 'Too many requests') {
    super(message, 429, 'RATE_LIMIT_EXCEEDED')
  }
}
```

### Error Middleware (Express)

```typescript
import { Request, Response, NextFunction } from 'express'
import { AppError } from './errors'

// Global error handler
export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  // Default to 500 server error
  let statusCode = 500
  let message = 'Internal server error'
  let code = 'INTERNAL_ERROR'
  let details = undefined

  // Handle known application errors
  if (err instanceof AppError) {
    statusCode = err.statusCode
    message = err.message
    code = err.code
    
    if (err instanceof ValidationError) {
      details = err.fields
    }
  }

  // Log the error
  console.error('Error:', {
    code,
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userId: req.user?.id
  })

  // Send error response
  res.status(statusCode).json({
    error: {
      code,
      message,
      ...(details && { details }),
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    },
    meta: {
      request_id: req.id,
      timestamp: new Date().toISOString()
    }
  })
}

// 404 handler
export function notFoundHandler(req: Request, res: Response) {
  res.status(404).json({
    error: {
      code: 'NOT_FOUND',
      message: `Route ${req.method} ${req.url} not found`
    },
    meta: {
      request_id: req.id,
      timestamp: new Date().toISOString()
    }
  })
}

// Async handler wrapper (prevents try-catch in every route)
export function asyncHandler(fn: Function) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next)
  }
}
```

### Error Handling in Routes

```typescript
import { asyncHandler } from './middleware/errorHandler'
import { NotFoundError, ValidationError } from './errors'

// ✅ GOOD: Using asyncHandler and proper errors
app.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await db.users.findUnique({ where: { id: req.params.id } })
  
  if (!user) {
    throw new NotFoundError('User', req.params.id)
  }
  
  res.json({ data: user })
}))

// ✅ GOOD: With validation
app.post('/users', asyncHandler(async (req, res) => {
  // Validate input
  const result = CreateUserSchema.safeParse(req.body)
  if (!result.success) {
    throw new ValidationError(
      'Invalid input',
      result.error.flatten().fieldErrors
    )
  }
  
  // Check for duplicates
  const existing = await db.users.findUnique({
    where: { email: result.data.email }
  })
  
  if (existing) {
    throw new ConflictError('User with this email already exists')
  }
  
  // Create user
  const user = await db.users.create({ data: result.data })
  
  res.status(201).json({ data: user })
}))
```

### Next.js App Router Error Handling

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { AppError, NotFoundError } from '@/lib/errors'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const id = searchParams.get('id')
    
    if (!id) {
      return NextResponse.json(
        { error: { code: 'MISSING_PARAM', message: 'User ID required' } },
        { status: 400 }
      )
    }
    
    const user = await db.users.findUnique({ where: { id } })
    
    if (!user) {
      throw new NotFoundError('User', id)
    }
    
    return NextResponse.json({ data: user })
    
  } catch (error) {
    // Handle known errors
    if (error instanceof AppError) {
      return NextResponse.json(
        { error: { code: error.code, message: error.message } },
        { status: error.statusCode }
      )
    }
    
    // Log unknown errors
    console.error('Unexpected error:', error)
    
    // Generic error response
    return NextResponse.json(
      { error: { code: 'INTERNAL_ERROR', message: 'An error occurred' } },
      { status: 500 }
    )
  }
}
```

### Error Logging

```typescript
// Structured error logging
export function logError(error: Error, context?: Record<string, any>) {
  const errorLog = {
    timestamp: new Date().toISOString(),
    name: error.name,
    message: error.message,
    stack: error.stack,
    ...(error instanceof AppError && {
      code: error.code,
      statusCode: error.statusCode,
      isOperational: error.isOperational
    }),
    ...context
  }
  
  // Log to appropriate destination
  if (process.env.NODE_ENV === 'production') {
    // Send to logging service (Sentry, LogRocket, etc.)
    Sentry.captureException(error, { extra: context })
  } else {
    // Console in development
    console.error('ERROR:', JSON.stringify(errorLog, null, 2))
  }
}

// Usage in routes
try {
  // ... route logic
} catch (error) {
  logError(error as Error, {
    url: req.url,
    method: req.method,
    userId: req.user?.id,
    requestId: req.id
  })
  throw error  // Let error middleware handle response
}
```

### Graceful Degradation

```typescript
// Fallback when external service fails
export async function getMarketData(symbol: string) {
  try {
    // Try primary data source
    const data = await primaryAPI.getMarketData(symbol)
    return data
  } catch (error) {
    console.warn('Primary API failed, trying fallback', error)
    
    try {
      // Fallback to secondary source
      const data = await secondaryAPI.getMarketData(symbol)
      return data
    } catch (fallbackError) {
      console.error('All data sources failed', fallbackError)
      
      // Return cached data if available
      const cached = await cache.get(`market:${symbol}`)
      if (cached) {
        return { ...cached, stale: true }
      }
      
      // Last resort: throw error
      throw new AppError(
        'Market data unavailable',
        503,
        'SERVICE_UNAVAILABLE'
      )
    }
  }
}
```

### Validation Error Handling

```typescript
import { z } from 'zod'

const UserSchema = z.object({
  email: z.string().email('Invalid email format'),
  age: z.number().min(0, 'Age must be positive').max(150, 'Age too large'),
  name: z.string().min(1, 'Name required').max(100, 'Name too long')
})

export async function createUser(input: unknown) {
  try {
    const validated = UserSchema.parse(input)
    return await db.users.create({ data: validated })
  } catch (error) {
    if (error instanceof z.ZodError) {
      // Format validation errors
      const formatted = error.errors.reduce((acc, err) => {
        const path = err.path.join('.')
        acc[path] = err.message
        return acc
      }, {} as Record<string, string>)
      
      throw new ValidationError('Validation failed', formatted)
    }
    throw error
  }
}
```

### Circuit Breaker Pattern

```typescript
class CircuitBreaker {
  private failures = 0
  private readonly threshold = 5
  private readonly timeout = 60000 // 1 minute
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED'
  private nextAttempt = Date.now()

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    // Circuit is OPEN - reject immediately
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new AppError(
          'Service temporarily unavailable',
          503,
          'CIRCUIT_OPEN'
        )
      }
      this.state = 'HALF_OPEN'
    }

    try {
      const result = await fn()
      
      // Success - reset circuit
      if (this.state === 'HALF_OPEN') {
        this.state = 'CLOSED'
        this.failures = 0
      }
      
      return result
    } catch (error) {
      this.failures++
      
      // Too many failures - open circuit
      if (this.failures >= this.threshold) {
        this.state = 'OPEN'
        this.nextAttempt = Date.now() + this.timeout
        console.error('Circuit breaker OPEN', { failures: this.failures })
      }
      
      throw error
    }
  }
}

// Usage
const externalAPIBreaker = new CircuitBreaker()

async function callExternalAPI(data: any) {
  return externalAPIBreaker.execute(async () => {
    const response = await fetch('https://api.example.com/data', {
      method: 'POST',
      body: JSON.stringify(data)
    })
    
    if (!response.ok) {
      throw new Error('API request failed')
    }
    
    return response.json()
  })
}
```

### Testing Error Handling

```typescript
describe('Error handling', () => {
  it('returns 404 for non-existent user', async () => {
    const response = await request(app).get('/users/invalid-id')
    
    expect(response.status).toBe(404)
    expect(response.body).toMatchObject({
      error: {
        code: 'NOT_FOUND',
        message: expect.stringContaining('User')
      }
    })
  })
  
  it('returns 400 for invalid input', async () => {
    const response = await request(app)
      .post('/users')
      .send({ email: 'invalid' })
    
    expect(response.status).toBe(400)
    expect(response.body.error.code).toBe('VALIDATION_ERROR')
    expect(response.body.error.details).toBeDefined()
  })
  
  it('handles database errors gracefully', async () => {
    // Mock database failure
    jest.spyOn(db.users, 'create').mockRejectedValue(new Error('DB error'))
    
    const response = await request(app)
      .post('/users')
      .send({ email: 'test@example.com', name: 'Test' })
    
    expect(response.status).toBe(500)
    expect(response.body.error.code).toBe('INTERNAL_ERROR')
    expect(response.body.error.message).not.toContain('DB error')  // No leak
  })
})
```

### Quick Checklist

- [ ] Custom error classes defined
- [ ] Global error middleware implemented
- [ ] All async routes wrapped with asyncHandler
- [ ] Validation errors properly formatted
- [ ] Error logging includes context
- [ ] Error responses consistent across API
- [ ] No sensitive data in error messages
- [ ] Graceful degradation for external services
- [ ] Circuit breaker for critical dependencies
- [ ] Error handling tested
- [ ] No empty catch blocks
- [ ] No swallowed errors
- [ ] All errors use Error classes (no strings)
- [ ] HTTP status codes match error types

---

## OpenCode Integration

**When to Use**:
- Implementing error handling in APIs
- Creating error middleware
- Designing error response formats
- Setting up error logging
- Building fault-tolerant systems

**Load this skill when**:
- User mentions "error handling", "exception", "error middleware"
- Implementing API endpoints
- Debugging production errors

**Usage Pattern**:
```typescript
// Automatically loaded when AGENTS.md detects error handling keywords
// Or manually load:
@use error-handling
User: "Implement proper error handling for the API"
```

**Combines well with**:
- `backend-patterns` - Overall backend architecture
- `security-review` - Secure error messages

---

**Remember**: These Iron Laws prevent silent failures, improve debuggability, and ensure consistent error handling. No exceptions (pun intended).
