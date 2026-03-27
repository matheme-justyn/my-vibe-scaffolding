---
name: database-optimization
description: Database query optimization, indexing strategies, N+1 problem prevention, connection pooling, and ORM best practices for high-performance backend systems.
origin: ECC-derived (adapted from backend-patterns)
adapted_for: OpenCode
---

# Database Optimization

## OpenCode Integration

**When to Use**:
- Database queries running slow
- High database load
- N+1 query problems
- Scaling database connections
- Implementing caching strategies

**Load this skill when**:
- User mentions "database", "slow queries", "performance", "optimization"
- Profiling database bottlenecks
- Designing data access patterns

**Usage Pattern**:
```typescript
// Automatically loaded when AGENTS.md detects database optimization keywords
// Or manually load:
@use database-optimization
User: "Optimize slow database queries"
```

**Combines well with**:
- `backend-patterns` - Overall backend architecture
- `api-design` - API performance

---

## Overview

Database optimization strategies for high-performance backend systems.

## Core Principles

### 1. Query Optimization

**Always use SELECT with specific columns** (not SELECT *)

```typescript
// ❌ BAD: Fetches all columns
const users = await db.query('SELECT * FROM users')

// ✅ GOOD: Fetch only needed columns
const users = await db.query('SELECT id, name, email FROM users')
```

### 2. N+1 Problem Prevention

**The N+1 Problem**: One query to fetch records + N queries to fetch relations

```typescript
// ❌ BAD: N+1 queries
const posts = await db.posts.findMany()
for (const post of posts) {
  post.author = await db.users.findUnique({ where: { id: post.authorId } })
}
// Result: 1 query for posts + N queries for authors

// ✅ GOOD: Single query with JOIN
const posts = await db.posts.findMany({
  include: { author: true }
})
// Result: 1 query with JOIN
```

### 3. Indexing Strategies

**Create indexes on frequently queried columns**

```sql
-- Index on foreign keys
CREATE INDEX idx_posts_author_id ON posts(author_id);

-- Composite index for multi-column queries
CREATE INDEX idx_posts_status_created ON posts(status, created_at DESC);

-- Unique index for unique constraints
CREATE UNIQUE INDEX idx_users_email ON users(email);
```

### 4. Connection Pooling

```typescript
// ❌ BAD: Creating new connection per request
async function getUser(id: string) {
  const connection = await createConnection()
  const user = await connection.query('SELECT * FROM users WHERE id = $1', [id])
  await connection.close()
  return user
}

// ✅ GOOD: Use connection pool
import { Pool } from 'pg'

const pool = new Pool({
  max: 20, // Max connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000
})

async function getUser(id: string) {
  const client = await pool.connect()
  try {
    const result = await client.query('SELECT * FROM users WHERE id = $1', [id])
    return result.rows[0]
  } finally {
    client.release()
  }
}
```

## Query Patterns

### Batch Loading

```typescript
// ❌ BAD: Multiple queries
for (const userId of userIds) {
  users.push(await db.users.findUnique({ where: { id: userId } }))
}

// ✅ GOOD: Single query with IN
const users = await db.users.findMany({
  where: { id: { in: userIds } }
})
```

### Pagination

```typescript
// ❌ BAD: Offset pagination (slow for large offsets)
SELECT * FROM posts ORDER BY created_at DESC OFFSET 10000 LIMIT 20;

// ✅ GOOD: Cursor-based pagination (keyset pagination)
SELECT * FROM posts 
WHERE created_at < $1 
ORDER BY created_at DESC 
LIMIT 20;
```

### Counting Records

```typescript
// ❌ BAD: Fetching all records to count
const posts = await db.posts.findMany()
const count = posts.length

// ✅ GOOD: Use COUNT query
const count = await db.posts.count()
```

## Caching Strategies

### Query Result Caching

```typescript
import Redis from 'ioredis'
const redis = new Redis()

async function getUser(id: string) {
  // Check cache first
  const cached = await redis.get(`user:${id}`)
  if (cached) return JSON.parse(cached)
  
  // Cache miss - query database
  const user = await db.users.findUnique({ where: { id } })
  
  // Store in cache (expire after 1 hour)
  await redis.setex(`user:${id}`, 3600, JSON.stringify(user))
  
  return user
}
```

### Cache Invalidation

```typescript
async function updateUser(id: string, data: UserUpdateInput) {
  // Update database
  const user = await db.users.update({
    where: { id },
    data
  })
  
  // Invalidate cache
  await redis.del(`user:${id}`)
  
  return user
}
```

## ORM Best Practices

### Prisma Optimization

```typescript
// Select only needed fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    email: true
  }
})

// Use include for relations (avoids N+1)
const posts = await prisma.post.findMany({
  include: {
    author: true,
    comments: {
      include: { author: true }
    }
  }
})

// Use transactions for multiple operations
await prisma.$transaction([
  prisma.user.update({ where: { id: 1 }, data: { balance: { decrement: 100 } } }),
  prisma.user.update({ where: { id: 2 }, data: { balance: { increment: 100 } } })
])
```

### Supabase Optimization

```typescript
// Use select() to fetch specific columns
const { data } = await supabase
  .from('users')
  .select('id, name, email')
  
// Use proper indexing with filters
const { data } = await supabase
  .from('posts')
  .select('*')
  .eq('status', 'published')  // Ensure index on status
  .order('created_at', { ascending: false })
  .limit(20)

// Batch inserts
const { data } = await supabase
  .from('posts')
  .insert([
    { title: 'Post 1' },
    { title: 'Post 2' },
    { title: 'Post 3' }
  ])
```

## Monitoring and Profiling

### Query Logging

```typescript
// Enable query logging in development
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient({
  log: ['query', 'info', 'warn', 'error']
})

// Log slow queries
const slowQueryThreshold = 100 // ms

prisma.$use(async (params, next) => {
  const before = Date.now()
  const result = await next(params)
  const after = Date.now()
  const duration = after - before
  
  if (duration > slowQueryThreshold) {
    console.warn(`Slow query detected (${duration}ms):`, {
      model: params.model,
      action: params.action,
      args: params.args
    })
  }
  
  return result
})
```

### Performance Metrics

```typescript
// Track database performance
const metrics = {
  queries: 0,
  totalDuration: 0,
  slowQueries: 0
}

async function trackQuery<T>(
  queryName: string,
  queryFn: () => Promise<T>
): Promise<T> {
  const start = Date.now()
  try {
    const result = await queryFn()
    const duration = Date.now() - start
    
    metrics.queries++
    metrics.totalDuration += duration
    
    if (duration > 100) {
      metrics.slowQueries++
      console.warn(`Slow query: ${queryName} took ${duration}ms`)
    }
    
    return result
  } catch (error) {
    console.error(`Query failed: ${queryName}`, error)
    throw error
  }
}

// Usage
const users = await trackQuery('getUsers', () =>
  db.users.findMany()
)
```

## Common Pitfalls

### ❌ Using SELECT * in production

```typescript
// BAD: Fetches unnecessary data
const users = await db.query('SELECT * FROM users')
```

### ❌ Not using connection pooling

```typescript
// BAD: Creates new connection per request
const connection = await createConnection()
```

### ❌ N+1 queries

```typescript
// BAD: One query per user
for (const post of posts) {
  post.author = await getUser(post.authorId)
}
```

### ❌ Not indexing foreign keys

```sql
-- BAD: No index on author_id
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  author_id INT REFERENCES users(id)
);
```

### ❌ Using offset pagination for large datasets

```typescript
// BAD: Slow for large offsets
SELECT * FROM posts OFFSET 10000 LIMIT 20;
```

## Quick Checklist

- [ ] SELECT specific columns (not SELECT *)
- [ ] Foreign keys are indexed
- [ ] N+1 queries eliminated (use joins/includes)
- [ ] Connection pooling configured
- [ ] Query results cached (Redis/memory)
- [ ] Pagination uses cursors (not offsets)
- [ ] Slow query logging enabled
- [ ] Transactions used for multi-step operations
- [ ] Batch operations instead of loops
- [ ] Database monitoring set up

## Resources

- [Prisma Best Practices](https://www.prisma.io/docs/guides/performance-and-optimization)
- [PostgreSQL Performance Tips](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [Supabase Performance](https://supabase.com/docs/guides/database/performance)
- [Database Indexing Strategies](https://use-the-index-luke.com/)
