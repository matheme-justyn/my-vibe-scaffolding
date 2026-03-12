---
name: error-handling
description: Comprehensive error handling patterns including error types, middleware, logging, user-facing messages, and recovery strategies for production systems.
origin: ECC-derived (extracted from backend-patterns and security-review)
adapted_for: OpenCode
---

# Error Handling Patterns

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

## Overview

Production-grade error handling patterns for reliable backend systems.

## Error Types Hierarchy

### Custom Error Classes

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

## Error Middleware (Express)

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

## Error Handling in Routes

```typescript
import { asyncHandler } from './middleware/errorHandler'
import { NotFoundError, ValidationError } from './errors'

// ❌ BAD: No error handling
app.get('/users/:id', async (req, res) => {
  const user = await db.users.findUnique({ where: { id: req.params.id } })
  res.json(user)  // What if user is null? What if query fails?
})

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

## Next.js App Router Error Handling

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

## Error Logging

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

## Graceful Degradation

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

## Validation Error Handling

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

## Circuit Breaker Pattern

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

## Error Response Format

```typescript
// Success response
{
  "data": { /* ... */ },
  "meta": {
    "request_id": "req_abc123",
    "timestamp": "2025-03-12T10:30:00Z"
  }
}

// Error response
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input parameters",
    "details": {
      "email": "Must be a valid email address",
      "age": "Must be a positive number"
    }
  },
  "meta": {
    "request_id": "req_abc123",
    "timestamp": "2025-03-12T10:30:00Z"
  }
}
```

## Best Practices

### ✅ DO

- Use custom error classes with proper hierarchy
- Log errors with context (user ID, request ID, URL)
- Return consistent error response format
- Use status codes correctly
- Implement graceful degradation
- Use circuit breakers for external services
- Validate all inputs
- Use asyncHandler to avoid try-catch in every route

### ❌ DON'T

- Expose internal error details to users
- Return different error formats from different endpoints
- Swallow errors silently
- Use generic error messages without codes
- Log sensitive data (passwords, tokens)
- Return 200 with error in body
- Use error strings instead of error classes

## Testing Error Handling

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

## Quick Checklist

- [ ] Custom error classes defined
- [ ] Global error middleware implemented
- [ ] All routes wrapped with asyncHandler
- [ ] Validation errors properly formatted
- [ ] Error logging includes context
- [ ] Error responses consistent across API
- [ ] No sensitive data in error messages
- [ ] Graceful degradation for external services
- [ ] Circuit breaker for critical dependencies
- [ ] Error handling tested

## Resources

- [Error Handling in Express](https://expressjs.com/en/guide/error-handling.html)
- [Next.js Error Handling](https://nextjs.org/docs/app/building-your-application/routing/error-handling)
- [Circuit Breaker Pattern](https://martinfowler.com/bliki/CircuitBreaker.html)
- [HTTP Status Codes](https://httpstatuses.com/)
