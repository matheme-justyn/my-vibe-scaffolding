---
name: api-design
description: REST API design patterns including resource naming, status codes, pagination, filtering, error responses, versioning, and rate limiting for production APIs.
origin: ECC (everything-claude-code)
adapted_for: OpenCode
---

# API Design Patterns

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

## Overview

Conventions and best practices for designing consistent, developer-friendly REST APIs.

## Resource Design

### URL Structure

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

### Naming Rules

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

## HTTP Methods and Status Codes

### Method Semantics

| Method | Idempotent | Safe | Use For |
|--------|-----------|------|---------|
| GET | Yes | Yes | Retrieve resources |
| POST | No | No | Create resources, trigger actions |
| PUT | Yes | No | Full replacement of a resource |
| PATCH | No* | No | Partial update of a resource |
| DELETE | Yes | No | Remove a resource |

*PATCH can be made idempotent with proper implementation

### Status Code Reference

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

### Common Mistakes

```
# BAD: 200 for everything
{ "status": 200, "success": false, "error": "Not found" }

# GOOD: Use proper HTTP status
HTTP 404 Not Found
{ "error": "User not found", "code": "USER_NOT_FOUND" }
```

## Response Format

### Success Response

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

### Error Response

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

### Collection Response

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

## Pagination

### Cursor-Based (Recommended for large datasets)

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

### Offset-Based (Simpler, good for small datasets)

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

## Filtering and Sorting

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

## Versioning

### URL Versioning (Recommended)

```
GET /api/v1/users
GET /api/v2/users
```

**Pros**: Explicit, easy to route
**Cons**: Multiple endpoints to maintain

### Header Versioning

```
GET /api/users
Accept: application/vnd.myapi.v2+json
```

**Pros**: Clean URLs
**Cons**: Less visible, harder to test

### When to Version

- Breaking changes to request/response format
- Removing fields
- Changing field types
- Changing authentication

**Don't version for**:
- Adding optional fields
- Adding new endpoints
- Bug fixes

## Rate Limiting

### Headers

```
X-RateLimit-Limit: 1000       # Max requests per window
X-RateLimit-Remaining: 950    # Remaining requests
X-RateLimit-Reset: 1678886400 # Unix timestamp when limit resets
Retry-After: 3600             # Seconds until can retry (on 429)
```

### Strategies

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

## Authentication

### Bearer Token (Recommended)

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

### API Key (Legacy)

```
X-API-Key: sk_live_abc123...
```

### OAuth 2.0 (Public APIs)

```
Authorization: Bearer {access_token}

# Token refresh
POST /api/v1/auth/refresh
{ "refresh_token": "..." }
```

## Security Best Practices

1. **Always use HTTPS** in production
2. **Validate all inputs** (use schema validation)
3. **Rate limit** all endpoints
4. **Never expose internal IDs** (use UUIDs or hashed IDs)
5. **Log security events** (failed auth, rate limit hits)
6. **Use CORS properly** (whitelist origins, not `*`)
7. **Sanitize error messages** (no stack traces in production)
8. **Implement request signing** for sensitive operations

## Testing API Design

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

## Common Pitfalls

❌ **Using verbs in URLs**: `/getUsers`, `/createOrder`
✅ **Use HTTP methods**: `GET /users`, `POST /orders`

❌ **Inconsistent naming**: `/users`, `/getUserOrders`
✅ **Consistent resources**: `/users`, `/users/:id/orders`

❌ **Exposing internal errors**: `"Error: Cannot read property 'id' of undefined"`
✅ **Generic error messages**: `"An internal error occurred. Request ID: req_123"`

❌ **No versioning**: Breaking changes without version bump
✅ **Version from day 1**: `/api/v1/users`

❌ **Missing pagination**: Returning 10,000 items in one response
✅ **Always paginate collections**: Default `per_page=20`, max `per_page=100`

## Quick Checklist

Before shipping an API:

- [ ] All endpoints use plural nouns
- [ ] Proper HTTP methods and status codes
- [ ] Error responses include `error.code` and `error.message`
- [ ] Collections are paginated
- [ ] Filtering and sorting work consistently
- [ ] Rate limiting is implemented
- [ ] Authentication is required (except public endpoints)
- [ ] CORS is configured properly
- [ ] All responses include `request_id` in meta
- [ ] Documentation is generated (OpenAPI/Swagger)
- [ ] Load tests pass with expected traffic

## References

- [REST API Design Best Practices](https://restfulapi.net/)
- [OpenAPI Specification](https://swagger.io/specification/)
- [HTTP Status Code Reference](https://httpstatuses.com/)
- [RFC 7807 - Problem Details for HTTP APIs](https://datatracker.ietf.org/doc/html/rfc7807)
