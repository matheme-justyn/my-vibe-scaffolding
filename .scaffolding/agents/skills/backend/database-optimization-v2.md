---
name: database-optimization
version: 2.0.0
description: Database optimization with Iron Laws enforcement - query optimization, indexing strategies, N+1 prevention, connection pooling, and ORM best practices for high-performance backend systems.
origin: ECC-derived (domain expertise)
adapted_for: OpenCode
transformation: Superpowers Iron Laws integration
---

# Database Optimization v2.0

## Iron Laws (Superpowers Style)

### 1. NO MISSING INDEXES ON FILTERED COLUMNS

**❌ BAD**:
```sql
-- Frequent query without index
SELECT * FROM users WHERE email = 'user@example.com';
-- Table scan on 1M rows

-- JOIN without foreign key index
SELECT orders.*, users.name 
FROM orders 
JOIN users ON orders.user_id = users.id
WHERE orders.status = 'pending';
-- No index on orders.user_id or orders.status

-- Range query without index
SELECT * FROM logs 
WHERE created_at BETWEEN '2026-01-01' AND '2026-12-31';
-- Full table scan on time-series data
```

**✅ GOOD**:
```sql
-- Add index on frequently queried column
CREATE INDEX idx_users_email ON users(email);

-- Composite index for multi-column filters
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Time-series index
CREATE INDEX idx_logs_created_at ON logs(created_at);

-- Verify index usage
EXPLAIN ANALYZE 
SELECT * FROM users WHERE email = 'user@example.com';
-- Should show "Index Scan using idx_users_email"
```

```typescript
// ORM: Define indexes in model
@Entity()
@Index(['email']) // Single column
@Index(['userId', 'status']) // Composite
export class Order {
  @Column()
  @Index() // Foreign key index
  userId: number;
  
  @Column()
  status: string;
}
```

**Violation Handling**: Run EXPLAIN on all queries, add indexes to WHERE, JOIN, ORDER BY columns

**No Excuses**:
- ❌ "It works fine with small data"
- ❌ "Indexes slow down writes"
- ❌ "I'll add indexes later"

**Enforcement**: Query profiling logs, slow query monitoring, pre-deployment performance tests

---

### 2. NO N+1 QUERIES

**❌ BAD**:
```typescript
// N+1: 1 query + N queries in loop
const users = await User.findAll(); // 1 query
for (const user of users) {
  const orders = await Order.findAll({ 
    where: { userId: user.id } 
  }); // N queries
  console.log(user.name, orders.length);
}

// GraphQL N+1
const resolvers = {
  User: {
    orders: (user) => Order.findAll({ where: { userId: user.id } })
    // Called N times for N users
  }
}

// Sequelize lazy loading
const user = await User.findByPk(1);
const orders = await user.getOrders(); // Separate query
const items = await orders[0].getItems(); // Another query
```

**✅ GOOD**:
```typescript
// Eager loading with include
const users = await User.findAll({
  include: [{ model: Order }]
}); // Single JOIN query

// Manual batch loading
const users = await User.findAll();
const userIds = users.map(u => u.id);
const orders = await Order.findAll({ 
  where: { userId: userIds } // WHERE userId IN (...)
});
const ordersByUserId = groupBy(orders, 'userId');
users.forEach(user => {
  user.orders = ordersByUserId[user.id] || [];
});

// DataLoader for GraphQL
const orderLoader = new DataLoader(async (userIds) => {
  const orders = await Order.findAll({ 
    where: { userId: userIds } 
  });
  return userIds.map(id => 
    orders.filter(o => o.userId === id)
  );
});

const resolvers = {
  User: {
    orders: (user) => orderLoader.load(user.id)
  }
}
```

**Violation Handling**: Replace loops with batch queries, use DataLoader, enable query logging

**No Excuses**:
- ❌ "It's only a few records"
- ❌ "Joins are complex"
- ❌ "The ORM handles it"

**Enforcement**: Query count monitoring, APM tools (New Relic), unit tests asserting query count

---

### 3. NO SELECT * (SPECIFY COLUMNS)

**❌ BAD**:
```sql
-- Fetches all columns including unused BLOB
SELECT * FROM products WHERE category = 'electronics';
-- Returns 50 columns, only need 3

-- SELECT * in JOIN (column name collisions)
SELECT * FROM orders o
JOIN users u ON o.user_id = u.id;
-- Ambiguous column names, duplicate 'id', 'created_at'

-- ORM fetching all relations
const user = await User.findOne({ 
  where: { id: 1 },
  include: [Order, Profile, Address] 
});
// Fetches 100+ columns across tables
```

**✅ GOOD**:
```sql
-- Explicit columns
SELECT id, name, price FROM products 
WHERE category = 'electronics';

-- Qualified columns in JOIN
SELECT 
  o.id as order_id,
  o.total,
  u.name as user_name,
  u.email
FROM orders o
JOIN users u ON o.user_id = u.id;
```

```typescript
// ORM: Select specific attributes
const users = await User.findAll({
  attributes: ['id', 'name', 'email'], // Only these columns
  include: [{
    model: Order,
    attributes: ['id', 'total', 'status']
  }]
});

// GraphQL: Request only needed fields
query {
  user(id: 1) {
    id
    name
    email
    # Don't fetch bio, avatar, settings unless needed
  }
}
```

**Violation Handling**: Replace SELECT * with explicit column lists, use ORM projections

**No Excuses**:
- ❌ "SELECT * is easier to write"
- ❌ "We might need the columns later"
- ❌ "Network bandwidth is cheap"

**Enforcement**: SQL linter, code review, database query analysis

---

### 4. NO TRANSACTIONS WITHOUT ROLLBACK

**❌ BAD**:
```typescript
// Transaction without error handling
const trx = await db.transaction();
await trx('users').insert({ name: 'Alice' });
await trx('accounts').insert({ userId: 1, balance: 100 });
await trx.commit(); // If second insert fails, first persists

// Missing rollback on error
try {
  await db.transaction(async (trx) => {
    await trx('users').insert(userData);
    await sendEmail(userData.email); // Non-transactional operation
    await trx('audit_log').insert(logData);
  });
} catch (error) {
  // Transaction auto-rolled back, but email already sent
}

// Nested transactions not handled
await db.transaction(async (trx1) => {
  await trx1('users').insert(user);
  await db.transaction(async (trx2) => {
    // Some ORMs don't support nested transactions
    await trx2('orders').insert(order);
  });
});
```

**✅ GOOD**:
```typescript
// Explicit rollback on error
const trx = await db.transaction();
try {
  await trx('users').insert({ name: 'Alice' });
  await trx('accounts').insert({ userId: 1, balance: 100 });
  await trx.commit();
} catch (error) {
  await trx.rollback();
  console.error('Transaction failed:', error);
  throw new TransactionError('User creation failed', error);
}

// Sequelize managed transaction
try {
  await sequelize.transaction(async (t) => {
    const user = await User.create(userData, { transaction: t });
    await Account.create({ userId: user.id, balance: 100 }, { transaction: t });
    // Auto-commits if successful, auto-rollback if error thrown
  });
} catch (error) {
  console.error('Transaction rolled back:', error);
  throw error;
}

// Non-transactional side effects AFTER commit
await db.transaction(async (trx) => {
  await trx('users').insert(userData);
  await trx('audit_log').insert(logData);
});
// Transaction committed, now safe to send email
await sendEmail(userData.email);

// Savepoints for partial rollback
await db.transaction(async (trx) => {
  await trx('users').insert(user);
  
  await trx.savepoint('before_orders');
  try {
    await trx('orders').insert(orders);
  } catch (error) {
    await trx.rollback('before_orders'); // Rollback to savepoint
    console.warn('Orders failed, user still created');
  }
});
```

**Violation Handling**: Wrap ALL transactions in try/catch with explicit rollback, move side effects outside transactions

**No Excuses**:
- ❌ "The ORM handles rollbacks automatically"
- ❌ "It's unlikely to fail"
- ❌ "Rollback is implicit"

**Enforcement**: Transaction logging, integration tests with forced failures, code review

---

### 5. NO UNBOUNDED QUERIES (PAGINATION/LIMITS REQUIRED)

**❌ BAD**:
```sql
-- No LIMIT (returns all rows)
SELECT * FROM logs; 
-- 10M rows crash client

-- Unbounded JOIN
SELECT users.*, orders.*
FROM users
JOIN orders ON users.id = orders.user_id;
-- Cartesian explosion if user has 1000 orders

-- No pagination in API
app.get('/api/products', async (req, res) => {
  const products = await Product.findAll(); // All rows
  res.json(products);
});
```

**✅ GOOD**:
```sql
-- LIMIT for safety
SELECT * FROM logs 
ORDER BY created_at DESC 
LIMIT 100;

-- Cursor-based pagination
SELECT * FROM logs 
WHERE id > :lastId 
ORDER BY id ASC 
LIMIT 100;

-- Offset pagination (less efficient but acceptable)
SELECT * FROM logs 
ORDER BY created_at DESC 
LIMIT 100 OFFSET 0;
```

```typescript
// API with pagination parameters
app.get('/api/products', async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = Math.min(parseInt(req.query.limit) || 20, 100); // Max 100
  const offset = (page - 1) * limit;
  
  const { rows, count } = await Product.findAndCountAll({
    limit,
    offset,
    order: [['created_at', 'DESC']]
  });
  
  res.json({
    data: rows,
    pagination: {
      page,
      limit,
      total: count,
      totalPages: Math.ceil(count / limit)
    }
  });
});

// Cursor pagination (more efficient for large datasets)
app.get('/api/products', async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit) || 20, 100);
  const cursor = req.query.cursor; // Last ID from previous page
  
  const products = await Product.findAll({
    where: cursor ? { id: { [Op.gt]: cursor } } : {},
    limit: limit + 1, // Fetch one extra to check if there's next page
    order: [['id', 'ASC']]
  });
  
  const hasNext = products.length > limit;
  const items = hasNext ? products.slice(0, limit) : products;
  const nextCursor = hasNext ? items[items.length - 1].id : null;
  
  res.json({
    data: items,
    pagination: {
      limit,
      nextCursor,
      hasNext
    }
  });
});

// GraphQL with relay-style pagination
type Query {
  products(first: Int!, after: String): ProductConnection!
}

type ProductConnection {
  edges: [ProductEdge!]!
  pageInfo: PageInfo!
}
```

**Violation Handling**: Add LIMIT to ALL queries, implement pagination on ALL list endpoints

**No Excuses**:
- ❌ "The table only has 100 rows now"
- ❌ "Users won't fetch everything"
- ❌ "I'll add pagination later"

**Enforcement**: Database query limits (max_rows), API response size monitoring, load testing

---

## Implementation Details (Original ECC Domain Knowledge)

### Query Optimization Strategies

#### 1. Index Selection

**When to Add Indexes**:
```typescript
// High-cardinality columns (many unique values)
CREATE INDEX idx_users_email ON users(email); // Unique per user

// Foreign keys (JOIN columns)
CREATE INDEX idx_orders_user_id ON orders(user_id);

// Frequently filtered columns
CREATE INDEX idx_products_category ON products(category);

// Composite indexes (order matters!)
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
// Good for: WHERE user_id = X AND status = Y
// Good for: WHERE user_id = X
// BAD for: WHERE status = Y (index not used)
```

**When NOT to Add Indexes**:
```typescript
// Low-cardinality columns (few unique values)
// ❌ CREATE INDEX idx_users_active ON users(active);
// Only 2 values: true/false

// Frequently updated columns
// ❌ CREATE INDEX idx_products_view_count ON products(view_count);
// Updated on every page view, slows writes

// Small tables (< 1000 rows)
// Indexes add overhead without benefit
```

#### 2. Query Rewriting

**Subquery to JOIN**:
```sql
-- SLOW: Subquery executed N times
SELECT * FROM users
WHERE id IN (
  SELECT user_id FROM orders WHERE status = 'completed'
);

-- FAST: Single JOIN
SELECT DISTINCT users.*
FROM users
INNER JOIN orders ON users.id = orders.user_id
WHERE orders.status = 'completed';
```

**EXISTS vs IN**:
```sql
-- SLOW: IN with subquery (materializes subquery)
SELECT * FROM users
WHERE id IN (SELECT user_id FROM orders);

-- FAST: EXISTS (short-circuits on first match)
SELECT * FROM users u
WHERE EXISTS (
  SELECT 1 FROM orders o WHERE o.user_id = u.id
);
```

#### 3. Connection Pooling

```typescript
// ❌ BAD: New connection per request
app.get('/users', async (req, res) => {
  const db = await connectToDatabase(); // Slow handshake
  const users = await db.query('SELECT * FROM users');
  await db.close();
  res.json(users);
});

// ✅ GOOD: Connection pool
import { Pool } from 'pg';

const pool = new Pool({
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  max: 20, // Max connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

app.get('/users', async (req, res) => {
  const client = await pool.connect(); // Reuses existing connection
  try {
    const result = await client.query('SELECT * FROM users LIMIT 100');
    res.json(result.rows);
  } finally {
    client.release(); // Return to pool
  }
});
```

#### 4. Caching Strategies

**Query Result Caching**:
```typescript
import Redis from 'ioredis';
const redis = new Redis();

async function getUser(id: number) {
  // Check cache first
  const cached = await redis.get(`user:${id}`);
  if (cached) return JSON.parse(cached);
  
  // Cache miss: fetch from database
  const user = await User.findByPk(id);
  await redis.setex(`user:${id}`, 3600, JSON.stringify(user)); // Cache 1 hour
  return user;
}

// Invalidate on update
async function updateUser(id: number, data: Partial<User>) {
  await User.update(data, { where: { id } });
  await redis.del(`user:${id}`); // Invalidate cache
}
```

**Application-Level Caching**:
```typescript
import NodeCache from 'node-cache';
const cache = new NodeCache({ stdTTL: 600 }); // 10 minutes

async function getCategories() {
  const key = 'categories:all';
  
  // Check in-memory cache
  if (cache.has(key)) {
    return cache.get(key);
  }
  
  // Fetch from database
  const categories = await Category.findAll();
  cache.set(key, categories);
  return categories;
}
```

#### 5. Bulk Operations

**Batch Inserts**:
```typescript
// ❌ SLOW: Individual inserts
for (const user of users) {
  await User.create(user); // N queries
}

// ✅ FAST: Bulk insert
await User.bulkCreate(users); // Single query with VALUES (...)
```

**Batch Updates**:
```typescript
// ❌ SLOW: Update in loop
for (const order of orders) {
  await Order.update(
    { status: 'shipped' },
    { where: { id: order.id } }
  ); // N queries
}

// ✅ FAST: Single UPDATE with WHERE IN
const orderIds = orders.map(o => o.id);
await Order.update(
  { status: 'shipped' },
  { where: { id: orderIds } }
); // UPDATE ... WHERE id IN (...)
```

---

## ORM-Specific Patterns

### Sequelize

```typescript
// Eager loading with associations
const users = await User.findAll({
  include: [{
    model: Order,
    as: 'orders',
    where: { status: 'completed' },
    required: false // LEFT JOIN instead of INNER JOIN
  }]
});

// Raw queries for complex operations
const [results] = await sequelize.query(`
  SELECT 
    users.id,
    users.name,
    COUNT(orders.id) as order_count
  FROM users
  LEFT JOIN orders ON users.id = orders.user_id
  GROUP BY users.id
  HAVING COUNT(orders.id) > 10
`, { type: QueryTypes.SELECT });

// Transactions with isolation level
await sequelize.transaction(
  { isolationLevel: Transaction.ISOLATION_LEVELS.READ_COMMITTED },
  async (t) => {
    await User.create(userData, { transaction: t });
    await Account.create(accountData, { transaction: t });
  }
);
```

### TypeORM

```typescript
// Query builder for complex queries
const users = await getRepository(User)
  .createQueryBuilder('user')
  .leftJoinAndSelect('user.orders', 'order')
  .where('order.status = :status', { status: 'completed' })
  .andWhere('user.active = :active', { active: true })
  .orderBy('user.created_at', 'DESC')
  .limit(100)
  .getMany();

// Optimistic locking with version column
@Entity()
export class User {
  @VersionColumn()
  version: number;
}

// Update fails if version changed (concurrent modification detected)
await userRepository.save(user); // Throws OptimisticLockVersionMismatchError
```

### Prisma

```typescript
// Relation queries
const users = await prisma.user.findMany({
  include: {
    orders: {
      where: { status: 'completed' },
      select: { id: true, total: true }
    }
  },
  take: 100
});

// Batch transactions
await prisma.$transaction([
  prisma.user.create({ data: userData }),
  prisma.account.create({ data: accountData }),
  prisma.auditLog.create({ data: logData })
]);

// Middleware for query logging
prisma.$use(async (params, next) => {
  const before = Date.now();
  const result = await next(params);
  const after = Date.now();
  console.log(`Query ${params.model}.${params.action} took ${after - before}ms`);
  return result;
});
```

---

## Performance Monitoring

### Slow Query Logging

**PostgreSQL**:
```sql
-- Enable slow query log (queries > 100ms)
ALTER SYSTEM SET log_min_duration_statement = 100;
SELECT pg_reload_conf();

-- View slow queries
SELECT 
  mean_exec_time,
  calls,
  query
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

**MySQL**:
```sql
-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 0.1; -- 100ms

-- Analyze slow queries
SELECT * FROM mysql.slow_log
ORDER BY query_time DESC
LIMIT 10;
```

### Application Monitoring

```typescript
// Query performance tracking
import { performance } from 'perf_hooks';

async function trackQuery<T>(name: string, query: () => Promise<T>): Promise<T> {
  const start = performance.now();
  try {
    return await query();
  } finally {
    const duration = performance.now() - start;
    if (duration > 100) {
      console.warn(`Slow query: ${name} took ${duration.toFixed(2)}ms`);
    }
    // Send to monitoring service
    metrics.histogram('db.query.duration', duration, { query: name });
  }
}

// Usage
const users = await trackQuery('User.findAll', () => 
  User.findAll({ limit: 100 })
);
```

---

## OpenCode Integration

### When to Use This Skill

**Auto-load when detecting**:
- Database performance issues ("slow queries", "database timeout")
- N+1 query problems ("too many queries")
- Missing indexes ("full table scan")
- Transaction issues ("race condition", "data inconsistency")
- Unbounded result sets ("out of memory", "large result set")

**Manual invocation**:
```
@use database-optimization
User: "Optimize this slow query"
```

### Workflow Integration

**1. Performance audit**:
```typescript
// Enable query logging
sequelize.options.logging = (sql, timing) => {
  console.log(`[${timing}ms] ${sql}`);
};

// Run typical user workflow
// Identify N+1 queries (multiple similar queries)
// Check for missing indexes (slow queries)
```

**2. Fix violations**:
- Add missing indexes
- Rewrite N+1 queries with eager loading
- Add pagination to unbounded queries
- Wrap operations in transactions
- Add query result caching

**3. Verify improvements**:
```bash
# Compare before/after
EXPLAIN ANALYZE SELECT ...;
# Check execution time, scan type, rows examined
```

### Skills Combination

**Works well with**:
- `backend-patterns` - Async patterns, error handling
- `api-design` - Pagination, filtering, rate limiting
- `security-review` - SQL injection prevention
- `test-driven-development` - Performance regression tests

**Example workflow**:
```
1. @use systematic-debugging → Identify slow queries
2. @use database-optimization → Fix N+1, add indexes
3. @use test-driven-development → Add performance tests
4. @use verification-before-completion → Verify improvements
```

---

## Verification Checklist

Before marking database optimization complete:

- [ ] All queries have explicit LIMIT or pagination
- [ ] No SELECT * (specify columns)
- [ ] Indexes exist on WHERE, JOIN, ORDER BY columns
- [ ] No N+1 queries (verified with query logging)
- [ ] All transactions have rollback handling
- [ ] Connection pooling configured
- [ ] Query performance monitored (slow query log enabled)
- [ ] Bulk operations used instead of loops
- [ ] Cache strategy implemented for hot data
- [ ] EXPLAIN ANALYZE shows index usage

**Performance metrics to track**:
- Average query duration < 100ms
- 95th percentile query duration < 500ms
- Database connection pool utilization < 80%
- Cache hit rate > 70%
- No queries scanning > 10,000 rows

---

**This skill enforces production-ready database performance practices with zero tolerance for common anti-patterns that cause scalability issues.**
