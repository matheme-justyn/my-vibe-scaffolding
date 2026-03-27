---
description: Generate or update documentation (API docs, README, inline comments)
agent: architect
subtask: true
---

# Document Command

Generate comprehensive documentation: $ARGUMENTS

## Your Task

1. **Identify documentation type** - API, README, architecture, inline
2. **Analyze existing documentation** - Check what's missing
3. **Generate documentation** - Use appropriate format
4. **Validate completeness** - Ensure all public APIs documented

## Documentation Types

### 1. API Documentation

**For REST APIs** (OpenAPI/Swagger):

```yaml
openapi: 3.0.0
info:
  title: User Management API
  version: 1.0.0
paths:
  /api/users:
    get:
      summary: List all users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
```

**For TypeScript/JavaScript**:

```typescript
/**
 * Fetches a user by ID
 * 
 * @param {string} userId - The unique user identifier
 * @returns {Promise<User>} The user object
 * @throws {NotFoundError} When user doesn't exist
 * @throws {AuthError} When not authenticated
 * 
 * @example
 * const user = await getUser('user_123')
 * console.log(user.name)
 */
export async function getUser(userId: string): Promise<User> {
  // implementation
}
```

### 2. README Documentation

**Structure**:

```markdown
# Project Name

[![Version](badge-url)](link)
[![Tests](badge-url)](link)

Brief description (1-2 sentences)

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

\`\`\`bash
npm install project-name
\`\`\`

## Quick Start

\`\`\`typescript
import { Thing } from 'project-name'

const thing = new Thing()
thing.doSomething()
\`\`\`

## API Reference

### Class: Thing

#### constructor(options)

- `options.foo` (string) - Description
- `options.bar` (number) - Description

#### thing.doSomething()

Returns: `Promise<Result>`

Description of what it does.

## Configuration

\`\`\`typescript
{
  option1: 'value',
  option2: 42
}
\`\`\`

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md)

## License

MIT
```

### 3. Architecture Documentation

**Create ADR (Architecture Decision Record)**:

```markdown
# ADR 0001: Use PostgreSQL for Primary Database

## Status

Accepted

## Context

We need to choose a database for our application.
Requirements: ACID compliance, relational data, scalability.

## Decision

Use PostgreSQL 15 as primary database.

## Consequences

**Positive**:
- ACID compliance
- Mature ecosystem
- JSON support for flexible schemas
- Strong typing

**Negative**:
- Requires vertical scaling initially
- More complex than NoSQL for simple use cases

## Alternatives Considered

- MongoDB: Not ACID compliant
- MySQL: Less feature-rich than PostgreSQL
- SQLite: Not suitable for production scale
```

### 4. Inline Code Comments

**When to comment**:
- ✅ WHY the code does something (business logic)
- ✅ Complex algorithms or non-obvious solutions
- ✅ Edge cases or workarounds
- ❌ WHAT the code does (should be obvious from code)

**Good comments**:
```typescript
// WORKAROUND: API returns empty array instead of 404
// Remove this check when API v2 is deployed (2025-Q2)
if (response.data.length === 0) {
  throw new NotFoundError()
}

// Performance optimization: Cache user data for 5 minutes
// Reduces database load from 1000 queries/sec to 50 queries/sec
const cachedUser = await cache.get(`user:${id}`, { ttl: 300 })
```

**Bad comments**:
```typescript
// Get user by ID
function getUser(id: string) { ... }

// Loop through items
for (const item of items) { ... }
```

### 5. Component Documentation (React/Vue)

```typescript
/**
 * Button component with multiple variants
 * 
 * @component
 * @example
 * <Button variant="primary" onClick={handleClick}>
 *   Click me
 * </Button>
 */
export function Button({
  /**
   * Button visual style
   * @default "primary"
   */
  variant = 'primary',
  
  /**
   * Click handler
   */
  onClick,
  
  /**
   * Button content
   */
  children
}: ButtonProps) {
  return (
    <button 
      className={`btn btn-${variant}`}
      onClick={onClick}
    >
      {children}
    </button>
  )
}
```

### 6. Database Schema Documentation

```sql
-- Users table
-- Stores user account information
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Authentication
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL, -- bcrypt hashed
  
  -- Profile
  name VARCHAR(100) NOT NULL,
  avatar_url TEXT,
  
  -- Metadata
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  last_login TIMESTAMP,
  
  -- Soft delete support
  deleted_at TIMESTAMP
);

-- Indexes for common queries
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_created_at ON users(created_at DESC);
```

## Documentation Checklist

### Public API Functions
- [ ] JSDoc/docstring present
- [ ] Parameters documented with types
- [ ] Return type documented
- [ ] Exceptions documented
- [ ] Usage example provided

### README
- [ ] Clear project description
- [ ] Installation instructions
- [ ] Quick start example
- [ ] API reference or link
- [ ] Configuration options
- [ ] Contributing guidelines
- [ ] License specified

### Architecture
- [ ] ADRs for major decisions
- [ ] System architecture diagram
- [ ] Data flow diagrams
- [ ] Deployment architecture

### Inline Comments
- [ ] Complex logic explained
- [ ] Edge cases documented
- [ ] Workarounds noted with expiration
- [ ] No obvious/redundant comments

## Tools

**Generation**:
- `typedoc` - TypeScript documentation
- `jsdoc` - JavaScript documentation
- `sphinx` - Python documentation
- `godoc` - Go documentation
- `swagger-ui` - API documentation UI

**Diagrams**:
- `mermaid` - Text-based diagrams
- `draw.io` - Visual diagrams
- `excalidraw` - Sketchy diagrams

**Validation**:
- `markdownlint` - Markdown linting
- `eslint-plugin-jsdoc` - JSDoc validation

## When to Write Documentation

✅ **Before coding**:
- API contracts (OpenAPI spec)
- Architecture decisions (ADRs)

✅ **During coding**:
- Inline comments for complex logic
- JSDoc for public functions

✅ **After coding**:
- README updates
- Usage examples
- Tutorial guides

---

**IMPORTANT**: Documentation should be maintained, not just written once. Update docs when code changes!
