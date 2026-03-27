---
name: api-design
version: 2.0.0
description: REST API design patterns with Iron Laws enforcement - resource naming, status codes, pagination, filtering, error responses, versioning, and rate limiting for production APIs.
origin: ECC (everything-claude-code)
adapted_for: OpenCode
transformation: Superpowers Iron Laws integration
---

# API Design Patterns v2.0

## Iron Laws (Superpowers Style)

### 1. NO MISMATCHED HTTP METHODS AND STATUS CODES

**❌ BAD**:
```typescript
// POST returning 200 with success in body
app.post('/users', (req, res) => {
  const user = createUser(req.body)
  res.status(200).json({ success: true, data: user })  // WRONG
})

// GET returning 200 with error in body
app.get('/users/:id', (req, res) => {
  const user = getUser(req.params.id)
  if (!user) {
    res.status(200).json({ error: 'User not found' })  // WRONG
  }
})
```

**✅ GOOD**:
```typescript
// POST returns 201 Created with Location header
app.post('/users', (req, res) => {
  const user = createUser(req.body)
  res
    .status(201)
    .location(`/api/v1/users/${user.id}`)
    .json({ data: user })
})

// GET returns 404 for not found
app.get('/users/:id', (req, res) => {
  const user = getUser(req.params.id)
  if (!user) {
    res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'User not found' }
    })
  }
})
```

**Violation Handling**: Delete and rewrite with correct HTTP semantics

**No Excuses**:
- ❌ "Frontend expects 200 for everything"
- ❌ "It's easier to handle in the client"
- ❌ "Our existing API uses this pattern"

**Enforcement**: API tests verify status codes, automated API contract testing (Pact, Dredd)

---

### 2. NO NAKED 500 ERRORS (MUST BE GENERIC)

**❌ BAD**:
```typescript
// Exposing internal error details
app.post('/users', (req, res) => {
  try {
    createUser(req.body)
  } catch (error) {
    res.status(500).json({
      error: error.message,  // "Cannot read property 'id' of undefined"
      stack: error.stack      // Full stack trace
    })
  }
})
```

**✅ GOOD**:
```typescript
// Generic error message with internal logging
app.post('/users', (req, res) => {
  try {
    createUser(req.body)
  } catch (error) {
    // Log full error internally
    console.error('User creation failed:', error)
    
    // Return generic message
    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'An error occurred. Please try again.'
      },
      meta: {
        request_id: req.id  // For support lookup
      }
    })
  }
})
```

**Violation Handling**: Implement error middleware that sanitizes all 500 responses

**No Excuses**:
- ❌ "We need detailed errors for debugging"
- ❌ "It's only development mode"
- ❌ "I'll add generic messages later"

**Enforcement**: API security scanner (OWASP ZAP), code review, pre-production penetration testing

---

### 3. NO PAGINATION WITHOUT HYPERMEDIA LINKS

**❌ BAD**:
```typescript
// Pagination metadata only
{
  "data": [...],
  "page": 2,
  "total": 100
}
// Client must construct URLs themselves
```

**✅ GOOD**:
```typescript
// HATEOAS-style pagination links
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 2,
    "per_page": 20,
    "total_pages": 5
  },
  "links": {
    "first": "/api/v1/items?page=1&per_page=20",
    "prev": "/api/v1/items?page=1&per_page=20",
    "self": "/api/v1/items?page=2&per_page=20",
    "next": "/api/v1/items?page=3&per_page=20",
    "last": "/api/v1/items?page=5&per_page=20"
  }
}
```

**Violation Handling**: Add hypermedia links to all paginated responses

**No Excuses**:
- ❌ "Frontend knows how to construct URLs"
- ❌ "Links add extra bytes"
- ❌ "We don't need HATEOAS"

**Enforcement**: API contract tests verify link presence, JSON Schema validation

---

### 4. NO VERBS IN RESOURCE URLS

**❌ BAD**:
```typescript
POST   /api/v1/createUser
GET    /api/v1/getUsers
POST   /api/v1/deleteUser
GET    /api/v1/getUserOrders
```

**✅ GOOD**:
```typescript
POST   /api/v1/users           // Create user
GET    /api/v1/users           // List users
DELETE /api/v1/users/:id       // Delete user
GET    /api/v1/users/:id/orders // Get user's orders

// Use verbs ONLY for non-CRUD actions
POST   /api/v1/orders/:id/cancel
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
```

**Violation Handling**: Refactor URLs to use nouns and HTTP methods

**No Excuses**:
- ❌ "It's clearer what the endpoint does"
- ❌ "Our team is used to this style"
- ❌ "REST is just a guideline"

**Enforcement**: URL linting in CI/CD, OpenAPI spec validation

---

### 5. NO UNVERSIONED APIS

**❌ BAD**:
```typescript
// No version
GET /api/users

// When you need breaking changes, you're stuck
GET /api/users-v2  // Ugly workaround
GET /api/new-users // Even uglier
```

**✅ GOOD**:
```typescript
// Version from day 1
GET /api/v1/users

// Breaking changes get new version
GET /api/v2/users  // v2 with different response shape

// Both versions coexist during migration
```

**Violation Handling**: Add /v1/ to all existing routes, never deploy unversioned APIs

**No Excuses**:
- ❌ "We won't have breaking changes"
- ❌ "It's just an internal API"
- ❌ "We'll add versioning when we need it"

**Enforcement**: API gateway enforces /vN/ prefix, CI/CD blocks unversioned routes

---

## Implementation Details (Original ECC)

### Resource Design

#### URL Structure

```
# Resources are nouns, plural, lowercase, kebab-case
GET    /api/v1/users
GET    /api/v1/users/:id
POST   /api/v1/users
PUT    /api/v1/users/:id
PATCH  /api/v1/users/:id
DELETE /api/v1/users/:id

# Sub-resources for relationships
GET    /api/v1/users/:id/orders
POST   /api/v1/users/:id/orders

# Actions that don't map to CRUD (use verbs sparingly)
POST   /api/v1/orders/:id/cancel
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
```

#### Naming Rules

```
# GOOD
/api/v1/team-members          # kebab-case for multi-word resources
/api/v1/orders?status=active  # query params for filtering
/api/v1/users/123/orders      # nested resources for ownership

# BAD
/api/v1/getUsers              # verb in URL
/api/v1/user                  # singular (use plural)
/api/v1/team_members          # snake_case in URLs
/api/v1/users/123/getOrders   # verb in nested resource
```

### HTTP Methods and Status Codes

#### Method Semantics

| Method | Idempotent | Safe | Use For |
|--------|-----------|------|---------|
| GET | Yes | Yes | Retrieve resources |
| POST | No | No | Create resources, trigger actions |
| PUT | Yes | No | Full replacement of a resource |
| PATCH | No* | No | Partial update of a resource |
| DELETE | Yes | No | Remove a resource |

*PATCH can be made idempotent with proper implementation

#### Status Code Reference

```
# Success
200 OK                    — GET, PUT, PATCH (with response body)
201 Created               — POST (include Location header)
204 No Content            — DELETE, PUT (no response body)

# Client Errors
400 Bad Request           — Validation failure, malformed JSON
401 Unauthorized          — Missing or invalid authentication
403 Forbidden             — Authenticated but not authorized
404 Not Found             — Resource doesn't exist
409 Conflict              — Duplicate entry, state conflict
422 Unprocessable Entity  — Semantically invalid (valid JSON, bad data)
429 Too Many Requests     — Rate limit exceeded

# Server Errors
500 Internal Server Error — Unexpected failure (never expose details)
502 Bad Gateway           — Upstream service failed
503 Service Unavailable   — Temporary overload, include Retry-After
```

### Response Format

#### Success Response

```json
{
  "data": {
    "id": "user_123",
    "email": "user@example.com",
    "created_at": "2025-03-12T10:30:00Z"
  },
  "meta": {
    "request_id": "req_abc123"
  }
}
```

#### Error Response

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email address"
      }
    ]
  },
  "meta": {
    "request_id": "req_abc123"
  }
}
```

#### Collection Response

```json
{
  "data": [
    { "id": 1, "name": "Item 1" },
    { "id": 2, "name": "Item 2" }
  ],
  "meta": {
    "total": 42,
    "page": 1,
    "per_page": 20,
    "total_pages": 3
  },
  "links": {
    "first": "/api/v1/items?page=1",
    "prev": null,
    "next": "/api/v1/items?page=2",
    "last": "/api/v1/items?page=3"
  }
}
```

### Pagination

#### Cursor-Based (Recommended for large datasets)

```
GET /api/v1/items?cursor=eyJpZCI6MTIzfQ&limit=20

Response:
{
  "data": [...],
  "meta": {
    "next_cursor": "eyJpZCI6MTQzfQ",
    "has_more": true
  }
}
```

**Pros**: Consistent results, handles real-time data  
**Cons**: Can't jump to arbitrary page

#### Offset-Based (Simpler, good for small datasets)

```
GET /api/v1/items?page=2&per_page=20

Response:
{
  "data": [...],
  "meta": {
    "page": 2,
    "per_page": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

**Pros**: Simple, can jump to any page  
**Cons**: Results shift with inserts/deletes

### Filtering and Sorting

```
# Single filter
GET /api/v1/orders?status=completed

# Multiple filters (comma-separated)
GET /api/v1/orders?status=completed,processing

# Range filters
GET /api/v1/orders?created_after=2025-01-01&created_before=2025-12-31

# Sorting (+ for asc, - for desc)
GET /api/v1/orders?sort=-created_at,+total

# Combining filters, sorting, pagination
GET /api/v1/orders?status=completed&sort=-created_at&page=1&per_page=20
```

### Versioning

#### URL Versioning (Recommended)

```
GET /api/v1/users
GET /api/v2/users
```

**Pros**: Explicit, easy to route  
**Cons**: Multiple endpoints to maintain

#### Header Versioning

```
GET /api/users
Accept: application/vnd.myapi.v2+json
```

**Pros**: Clean URLs  
**Cons**: Less visible, harder to test

#### When to Version

- Breaking changes to request/response format
- Removing fields
- Changing field types
- Changing authentication

**Don't version for**:
- Adding optional fields
- Adding new endpoints
- Bug fixes

### Rate Limiting

#### Headers

```
X-RateLimit-Limit: 1000       # Max requests per window
X-RateLimit-Remaining: 950    # Remaining requests
X-RateLimit-Reset: 1678886400 # Unix timestamp when limit resets
Retry-After: 3600             # Seconds until can retry (on 429)
```

#### Strategies

```
# Per-user (recommended)
1000 requests per hour per authenticated user

# Per-IP (public endpoints)
100 requests per hour per IP

# Tiered (for SaaS)
Free: 100/hour
Pro: 1000/hour
Enterprise: Unlimited
```

### Authentication

#### Bearer Token (Recommended)

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

#### API Key (Legacy)

```
X-API-Key: sk_live_abc123...
```

#### OAuth 2.0 (Public APIs)

```
Authorization: Bearer {access_token}

# Token refresh
POST /api/v1/auth/refresh
{ "refresh_token": "..." }
```

### Security Best Practices

1. **Always use HTTPS** in production
2. **Validate all inputs** (use schema validation)
3. **Rate limit** all endpoints
4. **Never expose internal IDs** (use UUIDs or hashed IDs)
5. **Log security events** (failed auth, rate limit hits)
6. **Use CORS properly** (whitelist origins, not `*`)
7. **Sanitize error messages** (no stack traces in production)
8. **Implement request signing** for sensitive operations

### Testing API Design

```typescript
// Test resource naming
describe('API Resource Naming', () => {
  it('uses plural nouns', () => {
    expect(getEndpoint('/api/v1/users')).toBeDefined()
  })
  
  it('uses kebab-case for multi-word resources', () => {
    expect(getEndpoint('/api/v1/team-members')).toBeDefined()
  })
})

// Test status codes
describe('API Status Codes', () => {
  it('returns 201 on POST success', async () => {
    const res = await POST('/api/v1/users', { email: 'test@example.com' })
    expect(res.status).toBe(201)
    expect(res.headers.location).toBeDefined()
  })
  
  it('returns 400 for invalid input', async () => {
    const res = await POST('/api/v1/users', { email: 'invalid' })
    expect(res.status).toBe(400)
    expect(res.body.error.code).toBe('VALIDATION_ERROR')
  })
})
```

### Quick Checklist

Before shipping an API:

- [ ] All endpoints use plural nouns
- [ ] Proper HTTP methods and status codes
- [ ] Error responses include `error.code` and `error.message`
- [ ] Collections are paginated with hypermedia links
- [ ] Filtering and sorting work consistently
- [ ] Rate limiting is implemented
- [ ] Authentication is required (except public endpoints)
- [ ] CORS is configured properly
- [ ] All responses include `request_id` in meta
- [ ] Documentation is generated (OpenAPI/Swagger)
- [ ] Load tests pass with expected traffic
- [ ] All endpoints versioned (/v1/, /v2/, etc.)

---

## OpenCode Integration

**When to Use**: 
- Designing new API endpoints
- Reviewing existing API contracts
- Adding pagination, filtering, or sorting
- Implementing error handling for APIs
- Planning API versioning strategy
- Building public or partner-facing APIs

**Load this skill when**:
- User mentions "API design", "REST API", "endpoint"
- Creating backend services
- Reviewing API documentation

**Usage Pattern**:
```typescript
// Automatically loaded when AGENTS.md detects API-related keywords
// Or manually load:
@use api-design
User: "Design a user management API"
```

---

**Remember**: These Iron Laws enforce HTTP semantics, security, and usability. REST is not just a guideline—it's a contract.
