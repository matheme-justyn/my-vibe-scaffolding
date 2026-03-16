# API DESIGN

**Status**: Active | **Domain**: Backend  
**Related Modules**: DATABASE_SCHEMA, AUTH_IMPLEMENTATION, MICROSERVICES_PATTERNS

## Purpose

This module defines standards for designing robust, scalable, and developer-friendly APIs. It covers REST API design, GraphQL patterns, HTTP status codes, versioning strategies, authentication, pagination, error handling, and API documentation.

## When to Use This Module

- Designing new API endpoints or services
- Evaluating existing API design for improvements
- Creating API documentation
- Implementing API versioning or deprecation
- Designing error responses and status codes
- Setting up authentication and authorization
- Implementing pagination, filtering, or sorting
- Reviewing API security practices

---

## 1. REST API Design Principles

### 1.1 Resource Naming

**Use nouns, not verbs. Resources are things, not actions.**

```
✅ GOOD: RESTful resource naming
GET    /users              # List users
GET    /users/123          # Get specific user
POST   /users              # Create user
PUT    /users/123          # Update user (full replacement)
PATCH  /users/123          # Update user (partial update)
DELETE /users/123          # Delete user

❌ BAD: RPC-style endpoints
GET    /getUsers
POST   /createUser
POST   /updateUser
POST   /deleteUser
```

### 1.2 Resource Hierarchy

```
✅ GOOD: Clear relationships
GET /users/123/posts           # Get posts by user 123
GET /users/123/posts/456       # Get post 456 by user 123
POST /users/123/posts          # Create post for user 123

❌ BAD: Flat structure losing context
GET /posts?userId=123
GET /posts/456
POST /posts
```

### 1.3 Plural vs Singular

**Use plural nouns for collections.**

```
✅ GOOD: Consistent plurals
GET /users
GET /posts
GET /comments

❌ BAD: Mixed singular/plural
GET /user
GET /posts
GET /comment
```

---

## 2. HTTP Methods

### 2.1 Method Semantics

| Method | Purpose | Idempotent? | Safe? | Request Body | Response Body |
|--------|---------|-------------|-------|--------------|---------------|
| **GET** | Retrieve resource(s) | Yes | Yes | No | Yes |
| **POST** | Create resource | No | No | Yes | Yes |
| **PUT** | Replace resource (full) | Yes | No | Yes | Yes |
| **PATCH** | Update resource (partial) | No | No | Yes | Yes |
| **DELETE** | Remove resource | Yes | No | No | Yes (optional) |
| **HEAD** | Get headers only | Yes | Yes | No | No |
| **OPTIONS** | Get available methods | Yes | Yes | No | Yes |

### 2.2 PUT vs PATCH

```typescript
// PUT: Full replacement (must send all fields)
PUT /users/123
{
  "name": "John Doe",
  "email": "john@example.com",
  "role": "admin",
  "active": true
}

// PATCH: Partial update (only send changed fields)
PATCH /users/123
{
  "email": "newemail@example.com"
}
```

---

## 3. HTTP Status Codes

### 3.1 Success Codes (2xx)

```typescript
// 200 OK - Standard success response
GET /users/123
Response: 200 OK
{ "id": 123, "name": "John" }

// 201 Created - Resource created
POST /users
Response: 201 Created
Location: /users/124
{ "id": 124, "name": "Jane" }

// 204 No Content - Success with no response body
DELETE /users/123
Response: 204 No Content

// 202 Accepted - Request accepted for async processing
POST /batch-import
Response: 202 Accepted
{ "jobId": "abc-123", "status": "pending" }
```

### 3.2 Client Error Codes (4xx)

```typescript
// 400 Bad Request - Invalid request syntax
POST /users
{ "email": "invalid-email" }
Response: 400 Bad Request
{
  "error": "ValidationError",
  "message": "Invalid request body",
  "details": [
    { "field": "email", "message": "Must be a valid email address" }
  ]
}

// 401 Unauthorized - Authentication required
GET /admin/users
Response: 401 Unauthorized
{
  "error": "Unauthorized",
  "message": "Authentication required"
}

// 403 Forbidden - Authenticated but not authorized
GET /admin/users
Response: 403 Forbidden
{
  "error": "Forbidden",
  "message": "You don't have permission to access this resource"
}

// 404 Not Found - Resource doesn't exist
GET /users/999
Response: 404 Not Found
{
  "error": "NotFound",
  "message": "User with ID 999 not found"
}

// 409 Conflict - Resource conflict (e.g., duplicate)
POST /users
{ "email": "existing@example.com" }
Response: 409 Conflict
{
  "error": "Conflict",
  "message": "User with this email already exists"
}

// 422 Unprocessable Entity - Valid syntax but semantic errors
POST /users
{ "age": -5 }
Response: 422 Unprocessable Entity
{
  "error": "ValidationError",
  "message": "Age must be a positive number"
}

// 429 Too Many Requests - Rate limit exceeded
GET /api/search
Response: 429 Too Many Requests
Retry-After: 60
{
  "error": "RateLimitExceeded",
  "message": "Rate limit exceeded. Try again in 60 seconds"
}
```

### 3.3 Server Error Codes (5xx)

```typescript
// 500 Internal Server Error - Generic server error
GET /users
Response: 500 Internal Server Error
{
  "error": "InternalServerError",
  "message": "An unexpected error occurred",
  "requestId": "req-abc-123"  // For tracking
}

// 503 Service Unavailable - Temporary unavailability
GET /users
Response: 503 Service Unavailable
Retry-After: 120
{
  "error": "ServiceUnavailable",
  "message": "Service is temporarily unavailable. Try again later"
}
```

---

## 4. Error Responses

### 4.1 Standard Error Format

```typescript
// ✅ GOOD: Consistent error structure
interface ErrorResponse {
  error: string;          // Error code/type
  message: string;        // Human-readable message
  details?: Array<{       // Optional field-level errors
    field: string;
    message: string;
  }>;
  requestId?: string;     // For tracking/debugging
  timestamp?: string;     // When error occurred
}

// Example implementation
{
  "error": "ValidationError",
  "message": "Request validation failed",
  "details": [
    { "field": "email", "message": "Email is required" },
    { "field": "password", "message": "Password must be at least 8 characters" }
  ],
  "requestId": "req-abc-123",
  "timestamp": "2026-03-16T10:30:00Z"
}
```

### 4.2 Error Code Naming

```typescript
// ✅ GOOD: Descriptive error codes
const ErrorCodes = {
  // Validation errors
  VALIDATION_ERROR: 'ValidationError',
  MISSING_REQUIRED_FIELD: 'MissingRequiredField',
  
  // Authentication errors
  UNAUTHORIZED: 'Unauthorized',
  INVALID_CREDENTIALS: 'InvalidCredentials',
  TOKEN_EXPIRED: 'TokenExpired',
  
  // Authorization errors
  FORBIDDEN: 'Forbidden',
  INSUFFICIENT_PERMISSIONS: 'InsufficientPermissions',
  
  // Resource errors
  NOT_FOUND: 'NotFound',
  ALREADY_EXISTS: 'AlreadyExists',
  CONFLICT: 'Conflict',
  
  // Rate limiting
  RATE_LIMIT_EXCEEDED: 'RateLimitExceeded',
  
  // Server errors
  INTERNAL_SERVER_ERROR: 'InternalServerError',
  SERVICE_UNAVAILABLE: 'ServiceUnavailable',
};
```

---

## 5. Pagination

### 5.1 Offset-Based Pagination

```typescript
// ✅ Request
GET /users?limit=20&offset=40

// ✅ Response
{
  "data": [...],  // Array of users
  "pagination": {
    "limit": 20,
    "offset": 40,
    "total": 1000,
    "hasMore": true
  },
  "links": {
    "self": "/users?limit=20&offset=40",
    "first": "/users?limit=20&offset=0",
    "prev": "/users?limit=20&offset=20",
    "next": "/users?limit=20&offset=60",
    "last": "/users?limit=20&offset=980"
  }
}
```

### 5.2 Cursor-Based Pagination (Recommended for Large Datasets)

```typescript
// ✅ Request
GET /users?limit=20&cursor=eyJpZCI6MTIzfQ==

// ✅ Response
{
  "data": [...],
  "pagination": {
    "limit": 20,
    "nextCursor": "eyJpZCI6MTQzfQ==",
    "hasMore": true
  }
}
```

### 5.3 Page-Based Pagination

```typescript
// ✅ Request
GET /users?page=3&perPage=20

// ✅ Response
{
  "data": [...],
  "pagination": {
    "page": 3,
    "perPage": 20,
    "totalPages": 50,
    "totalItems": 1000
  }
}
```

---

## 6. Filtering and Sorting

### 6.1 Filtering

```
// ✅ GOOD: Query parameter filtering
GET /users?role=admin&active=true&createdAfter=2025-01-01

// ✅ Multiple values (OR)
GET /users?role=admin,moderator

// ✅ Range queries
GET /products?priceMin=100&priceMax=500

// ✅ Text search
GET /articles?q=javascript&category=tutorial
```

### 6.2 Sorting

```
// ✅ Single field
GET /users?sort=createdAt

// ✅ Descending order
GET /users?sort=-createdAt  // Prefix with - for descending

// ✅ Multiple fields
GET /users?sort=lastName,firstName

// ✅ Explicit order
GET /users?sortBy=createdAt&order=desc
```

---

## 7. Versioning

### 7.1 URL Versioning (Recommended)

```
✅ GOOD: Version in URL path
https://api.example.com/v1/users
https://api.example.com/v2/users

Advantages:
- Clear and visible
- Easy to cache
- Simple routing
```

### 7.2 Header Versioning

```
✅ Alternative: Version in Accept header
GET /users
Accept: application/vnd.example.v2+json

Advantages:
- Clean URLs
- RESTful
- More flexible
```

### 7.3 Deprecation Strategy

```typescript
// ✅ Announce deprecation early
Response Headers:
Deprecation: true
Sunset: Sat, 31 Dec 2026 23:59:59 GMT
Link: <https://api.example.com/v2/users>; rel="successor-version"

// ✅ Provide migration guide
{
  "data": [...],
  "warnings": [
    {
      "code": "DEPRECATED_ENDPOINT",
      "message": "This endpoint will be removed on 2026-12-31",
      "migrationGuide": "https://docs.example.com/migration/v1-to-v2"
    }
  ]
}
```

---

## 8. Authentication & Authorization

### 8.1 JWT Bearer Tokens

```typescript
// ✅ GOOD: Standard Authorization header
GET /users
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

// Server response
{
  "data": [...],
  "user": {
    "id": 123,
    "role": "admin"
  }
}
```

### 8.2 API Keys

```typescript
// ✅ Custom header for API keys
GET /users
X-API-Key: sk_live_abc123def456

// ❌ BAD: API key in URL (insecure, logged)
GET /users?apiKey=sk_live_abc123def456
```

### 8.3 OAuth 2.0

```typescript
// ✅ OAuth 2.0 flow
1. Authorization request
GET /oauth/authorize?
  response_type=code&
  client_id=CLIENT_ID&
  redirect_uri=https://example.com/callback&
  scope=read:users write:posts

2. Token exchange
POST /oauth/token
{
  "grant_type": "authorization_code",
  "code": "AUTH_CODE",
  "client_id": "CLIENT_ID",
  "client_secret": "CLIENT_SECRET",
  "redirect_uri": "https://example.com/callback"
}

Response:
{
  "access_token": "eyJhbGciOiJIUzI1...",
  "refresh_token": "refresh_token_here",
  "expires_in": 3600,
  "token_type": "Bearer"
}
```

---

## 9. Rate Limiting

### 9.1 Response Headers

```typescript
// ✅ Standard rate limit headers
Response Headers:
X-RateLimit-Limit: 1000       // Total requests per window
X-RateLimit-Remaining: 999    // Remaining requests
X-RateLimit-Reset: 1710586800 // Unix timestamp when limit resets

// If rate limit exceeded
Response: 429 Too Many Requests
Retry-After: 60  // Seconds until retry allowed
{
  "error": "RateLimitExceeded",
  "message": "API rate limit exceeded",
  "retryAfter": 60
}
```

### 9.2 Rate Limit Strategies

```typescript
// ✅ Per-user rate limiting
const userRateLimit = {
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 100,                   // 100 requests per window
};

// ✅ Tiered rate limits
const rateLimits = {
  free: { windowMs: 3600000, max: 100 },
  pro: { windowMs: 3600000, max: 1000 },
  enterprise: { windowMs: 3600000, max: 10000 },
};
```

---

## 10. HATEOAS (Hypermedia)

```typescript
// ✅ GOOD: Include links to related resources
GET /users/123
Response:
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "_links": {
    "self": { "href": "/users/123" },
    "posts": { "href": "/users/123/posts" },
    "followers": { "href": "/users/123/followers" },
    "following": { "href": "/users/123/following" }
  }
}
```

---

## 11. Content Negotiation

```typescript
// ✅ Accept header for response format
GET /users
Accept: application/json        // JSON response
Accept: application/xml         // XML response
Accept: text/csv               // CSV response

// ✅ Content-Type for request format
POST /users
Content-Type: application/json
{
  "name": "John Doe"
}

// ✅ Multiple formats with quality values
Accept: application/json;q=0.9, application/xml;q=0.8
```

---

## 12. Caching

### 12.1 Cache-Control Headers

```typescript
// ✅ Public cacheable resource
GET /products/123
Response:
Cache-Control: public, max-age=3600
ETag: "686897696a7c876b7e"

// ✅ Private cacheable resource
GET /users/me
Response:
Cache-Control: private, max-age=300

// ✅ No cache
GET /account/balance
Response:
Cache-Control: no-cache, no-store, must-revalidate
```

### 12.2 Conditional Requests

```typescript
// ✅ ETag-based conditional requests
GET /users/123
Response:
ETag: "686897696a7c876b7e"
{ "id": 123, "name": "John" }

// Client makes conditional request
GET /users/123
If-None-Match: "686897696a7c876b7e"

// Resource unchanged
Response: 304 Not Modified

// Resource changed
Response: 200 OK
ETag: "abc123def456"
{ "id": 123, "name": "John Doe" }
```

---

## 13. Bulk Operations

### 13.1 Batch Requests

```typescript
// ✅ Create multiple resources
POST /users/batch
{
  "users": [
    { "name": "Alice", "email": "alice@example.com" },
    { "name": "Bob", "email": "bob@example.com" }
  ]
}

Response: 201 Created
{
  "created": [
    { "id": 124, "name": "Alice" },
    { "id": 125, "name": "Bob" }
  ],
  "errors": []
}
```

### 13.2 Bulk Updates/Deletes

```typescript
// ✅ Update multiple resources
PATCH /users/batch
{
  "updates": [
    { "id": 123, "active": false },
    { "id": 124, "role": "admin" }
  ]
}

// ✅ Delete multiple resources
DELETE /users/batch
{
  "ids": [123, 124, 125]
}
```

---

## 14. Webhooks

```typescript
// ✅ Webhook registration
POST /webhooks
{
  "url": "https://example.com/webhooks",
  "events": ["user.created", "user.updated"],
  "secret": "webhook_secret_key"
}

// ✅ Webhook payload
POST https://example.com/webhooks
X-Webhook-Signature: sha256=abc123...
{
  "event": "user.created",
  "timestamp": "2026-03-16T10:30:00Z",
  "data": {
    "id": 123,
    "name": "John Doe"
  }
}

// ✅ Signature verification (HMAC SHA256)
const signature = crypto
  .createHmac('sha256', webhookSecret)
  .update(JSON.stringify(payload))
  .digest('hex');
```

---

## 15. API Documentation

### 15.1 OpenAPI (Swagger)

```yaml
# ✅ OpenAPI 3.0 specification
openapi: 3.0.0
info:
  title: Example API
  version: 1.0.0
  description: API for managing users and posts

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
```

### 15.2 GraphQL Schema

```graphql
# ✅ GraphQL type definitions
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  publishedAt: DateTime
}

type Query {
  user(id: ID!): User
  users(limit: Int = 20, offset: Int = 0): [User!]!
  post(id: ID!): Post
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
}
```

---

## 16. GraphQL Best Practices

### 16.1 Query Design

```graphql
# ✅ GOOD: Request only needed fields
query GetUser {
  user(id: "123") {
    id
    name
    email
  }
}

# ✅ Nested queries
query GetUserWithPosts {
  user(id: "123") {
    id
    name
    posts(limit: 10) {
      id
      title
      publishedAt
    }
  }
}
```

### 16.2 Pagination (Relay Cursor Connections)

```graphql
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

type Query {
  users(first: Int, after: String): UserConnection!
}
```

### 16.3 Error Handling

```json
// ✅ GraphQL errors format
{
  "data": null,
  "errors": [
    {
      "message": "User not found",
      "locations": [{ "line": 2, "column": 3 }],
      "path": ["user"],
      "extensions": {
        "code": "NOT_FOUND",
        "userId": "999"
      }
    }
  ]
}
```

---

## Anti-Patterns

### ❌ Exposing Internal IDs
Using auto-increment IDs exposes system information.

**Solution**: Use UUIDs or obfuscated IDs for public APIs.

### ❌ Returning Raw Database Errors
Leaking SQL errors or stack traces.

**Solution**: Return generic error messages, log details server-side.

### ❌ Inconsistent Naming
Mixed camelCase, snake_case, PascalCase in one API.

**Solution**: Choose one convention (camelCase for JSON, snake_case for params).

### ❌ Ignoring HTTP Status Codes
Always returning 200 OK with error in body.

**Solution**: Use proper HTTP status codes (4xx, 5xx).

### ❌ No Rate Limiting
Allowing unlimited requests.

**Solution**: Implement rate limiting with clear limits and headers.

---

## Related Modules

- **DATABASE_SCHEMA** - Database design for API backends
- **AUTH_IMPLEMENTATION** - Authentication and authorization
- **MICROSERVICES_PATTERNS** - Service-to-service communication
- **PERFORMANCE_OPTIMIZATION** - API performance and caching

---

## Resources

**REST API**:
- REST API Tutorial: https://restfulapi.net/
- HTTP Status Codes: https://httpstatuses.com/

**GraphQL**:
- GraphQL Spec: https://spec.graphql.org/
- Apollo Docs: https://www.apollographql.com/docs/

**Standards**:
- RFC 7231 (HTTP/1.1): https://tools.ietf.org/html/rfc7231
- OAuth 2.0: https://oauth.net/2/
- OpenAPI Spec: https://swagger.io/specification/
