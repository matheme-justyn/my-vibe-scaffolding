# DATABASE SCHEMA

**Status**: Active | **Domain**: Backend  
**Related Modules**: API_DESIGN, PERFORMANCE_OPTIMIZATION, MICROSERVICES_PATTERNS

## Purpose

This module defines standards for designing scalable, maintainable, and performant database schemas. It covers relational database design, normalization, indexing strategies, data types, constraints, migrations, and best practices for SQL and NoSQL databases.

## When to Use This Module

- Designing new database schemas or tables
- Evaluating existing schema for improvements
- Planning database migrations
- Optimizing query performance
- Implementing data integrity constraints
- Choosing between SQL and NoSQL databases
- Designing for scalability and partitioning

---

## 1. Relational Database Design Principles

### 1.1 Normalization

**Normal Forms**:

- **1NF (First Normal Form)**: No repeating groups, atomic values
- **2NF (Second Normal Form)**: 1NF + no partial dependencies
- **3NF (Third Normal Form)**: 2NF + no transitive dependencies
- **BCNF (Boyce-Codd)**: Every determinant is a candidate key

```sql
-- ❌ BAD: Not in 1NF (repeating groups)
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_name VARCHAR(255),
  product1 VARCHAR(255),
  product2 VARCHAR(255),
  product3 VARCHAR(255)
);

-- ✅ GOOD: 1NF (atomic values, separate tables)
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  price DECIMAL(10,2) NOT NULL
);
```

### 1.2 Denormalization (When Needed)

**When to denormalize**:
- Read-heavy workloads with complex joins
- Aggregation queries running frequently
- Real-time analytics requirements

```sql
-- ✅ Denormalized for performance
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  customer_name VARCHAR(255),     -- Denormalized from customers table
  customer_email VARCHAR(255),    -- Denormalized from customers table
  total_amount DECIMAL(10,2),     -- Cached calculation
  item_count INTEGER,             -- Cached count
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Maintain denormalized data with triggers or application logic
CREATE OR REPLACE FUNCTION update_order_totals()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE orders
  SET total_amount = (
    SELECT SUM(price * quantity)
    FROM order_items
    WHERE order_id = NEW.order_id
  ),
  item_count = (
    SELECT COUNT(*)
    FROM order_items
    WHERE order_id = NEW.order_id
  )
  WHERE id = NEW.order_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_items_update
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW EXECUTE FUNCTION update_order_totals();
```

---

## 2. Table Design

### 2.1 Naming Conventions

```sql
-- ✅ GOOD: Clear, consistent naming
CREATE TABLE users (              -- Plural table names
  id SERIAL PRIMARY KEY,          -- Short, clear column names
  first_name VARCHAR(100),        -- snake_case
  last_name VARCHAR(100),
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_sessions (      -- Relationship tables: entity1_entity2
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  session_token VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMP NOT NULL
);

-- ❌ BAD: Inconsistent naming
CREATE TABLE User (               -- PascalCase (wrong for tables)
  UserID INT PRIMARY KEY,         -- Prefix notation
  fName VARCHAR(100),             -- Abbreviations
  lName VARCHAR(100),
  EMAIL TEXT,                     -- Inconsistent casing
  CreatedDate DATETIME            -- Mixed conventions
);
```

### 2.2 Primary Keys

```sql
-- ✅ OPTION 1: Auto-increment integer (simple, compact)
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);

-- ✅ OPTION 2: UUID (globally unique, distributed-friendly)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255)
);

-- ✅ OPTION 3: Composite key (for junction tables)
CREATE TABLE user_roles (
  user_id INTEGER NOT NULL REFERENCES users(id),
  role_id INTEGER NOT NULL REFERENCES roles(id),
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, role_id)
);

-- ❌ BAD: Natural keys that can change
CREATE TABLE users (
  email VARCHAR(255) PRIMARY KEY,  -- Email might change
  name VARCHAR(255)
);
```

### 2.3 Foreign Keys

```sql
-- ✅ GOOD: Foreign keys with explicit constraints
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  author_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ON DELETE options:
-- CASCADE: Delete child rows when parent is deleted
-- SET NULL: Set FK to NULL when parent is deleted
-- RESTRICT: Prevent deletion if children exist (default)
-- NO ACTION: Similar to RESTRICT but checked at end of statement

-- ✅ Named foreign key constraints
ALTER TABLE posts
ADD CONSTRAINT fk_posts_author
FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE;
```

---

## 3. Data Types

### 3.1 Choosing the Right Data Type

```sql
-- ✅ GOOD: Appropriate data types
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,          -- VARCHAR for variable-length strings
  description TEXT,                     -- TEXT for long content
  price DECIMAL(10,2) NOT NULL,        -- DECIMAL for money (exact)
  quantity INTEGER NOT NULL DEFAULT 0,  -- INTEGER for whole numbers
  is_active BOOLEAN DEFAULT true,      -- BOOLEAN for flags
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  metadata JSONB                        -- JSONB for flexible schema
);

-- ❌ BAD: Inappropriate data types
CREATE TABLE products_bad (
  id VARCHAR(50),                      -- VARCHAR for ID (inefficient)
  price FLOAT,                          -- FLOAT for money (precision loss)
  quantity VARCHAR(10),                 -- VARCHAR for numbers (can't do math)
  is_active VARCHAR(5),                -- VARCHAR for boolean ("true"/"false")
  created_at VARCHAR(50)               -- VARCHAR for timestamp
);
```

### 3.2 String Types

```sql
-- VARCHAR(n): Variable length with limit
name VARCHAR(255)

-- TEXT: Variable length without limit
content TEXT

-- CHAR(n): Fixed length (padded with spaces)
country_code CHAR(2)  -- Always exactly 2 characters (e.g., "US")

-- When to use each:
-- VARCHAR: Known max length (names, emails, phone numbers)
-- TEXT: Unknown length (blog posts, comments, descriptions)
-- CHAR: Fixed-length codes (ISO codes, status flags)
```

### 3.3 Numeric Types

```sql
-- Integers
SMALLINT     -- -32,768 to 32,767
INTEGER      -- -2,147,483,648 to 2,147,483,647
BIGINT       -- Very large integers

-- Auto-increment
SERIAL       -- INTEGER with auto-increment
BIGSERIAL    -- BIGINT with auto-increment

-- Decimal (exact, for money)
DECIMAL(10,2)  -- 10 total digits, 2 after decimal point

-- Floating point (approximate, for scientific calculations)
REAL         -- 6 decimal digits precision
DOUBLE PRECISION  -- 15 decimal digits precision
```

### 3.4 Date and Time Types

```sql
-- Date only
DATE         -- '2026-03-16'

-- Time only
TIME         -- '14:30:00'

-- Date and time without timezone
TIMESTAMP    -- '2026-03-16 14:30:00'

-- Date and time with timezone (recommended for UTC storage)
TIMESTAMPTZ  -- '2026-03-16 14:30:00+00'

-- ✅ Best practice: Store timestamps in UTC
created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
```

---

## 4. Indexes

### 4.1 When to Create Indexes

**Create indexes on**:
- Primary keys (automatic)
- Foreign keys
- Columns used in WHERE clauses
- Columns used in JOIN conditions
- Columns used in ORDER BY clauses
- Columns used in GROUP BY clauses

```sql
-- ✅ Index on frequently queried column
CREATE INDEX idx_users_email ON users(email);

-- ✅ Index on foreign key
CREATE INDEX idx_posts_author_id ON posts(author_id);

-- ✅ Composite index (for queries filtering on multiple columns)
CREATE INDEX idx_posts_author_created ON posts(author_id, created_at);

-- ✅ Partial index (for specific conditions)
CREATE INDEX idx_active_users ON users(email) WHERE is_active = true;

-- ✅ Full-text search index
CREATE INDEX idx_posts_content_search ON posts USING GIN(to_tsvector('english', content));
```

### 4.2 Index Types

```sql
-- B-tree (default, good for most queries)
CREATE INDEX idx_users_name ON users(name);

-- Hash (equality comparisons only, faster than B-tree)
CREATE INDEX idx_users_email ON users USING HASH(email);

-- GIN (Generalized Inverted Index, for arrays, JSONB, full-text)
CREATE INDEX idx_products_tags ON products USING GIN(tags);

-- GiST (Generalized Search Tree, for geometric data, full-text)
CREATE INDEX idx_locations ON stores USING GIST(location);

-- BRIN (Block Range Index, for very large tables with natural ordering)
CREATE INDEX idx_logs_created ON logs USING BRIN(created_at);
```

### 4.3 Covering Indexes

```sql
-- ✅ Include additional columns in index to avoid table lookup
CREATE INDEX idx_posts_author_covering
ON posts(author_id) INCLUDE (title, created_at);

-- Query can be answered entirely from index:
-- SELECT title, created_at FROM posts WHERE author_id = 123;
```

---

## 5. Constraints

### 5.1 NOT NULL

```sql
-- ✅ Required fields
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL,        -- Email is required
  name VARCHAR(255) NOT NULL,         -- Name is required
  bio TEXT                            -- Bio is optional
);
```

### 5.2 UNIQUE

```sql
-- ✅ Single-column uniqueness
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL
);

-- ✅ Multi-column uniqueness
CREATE TABLE user_roles (
  user_id INTEGER NOT NULL,
  role_id INTEGER NOT NULL,
  UNIQUE(user_id, role_id)
);
```

### 5.3 CHECK Constraints

```sql
-- ✅ Value validation
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  quantity INTEGER NOT NULL CHECK (quantity >= 0),
  discount_percent INTEGER CHECK (discount_percent BETWEEN 0 AND 100)
);

-- ✅ Complex check constraints
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
  age INTEGER CHECK (age >= 18)
);
```

### 5.4 DEFAULT Values

```sql
-- ✅ Sensible defaults
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  status VARCHAR(20) DEFAULT 'draft',
  view_count INTEGER DEFAULT 0,
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 6. Relationships

### 6.1 One-to-Many

```sql
-- ✅ User has many posts
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT
);
```

### 6.2 Many-to-Many

```sql
-- ✅ Users can have many roles, roles can have many users
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE user_roles (
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, role_id)
);
```

### 6.3 Self-Referencing (Tree Structures)

```sql
-- ✅ Comments with replies
CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  post_id INTEGER NOT NULL REFERENCES posts(id),
  parent_id INTEGER REFERENCES comments(id) ON DELETE CASCADE,
  author_id INTEGER NOT NULL REFERENCES users(id),
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ✅ Query tree with recursive CTE
WITH RECURSIVE comment_tree AS (
  -- Base case: top-level comments
  SELECT id, parent_id, content, 0 AS depth
  FROM comments
  WHERE parent_id IS NULL AND post_id = 123
  
  UNION ALL
  
  -- Recursive case: replies
  SELECT c.id, c.parent_id, c.content, ct.depth + 1
  FROM comments c
  JOIN comment_tree ct ON c.parent_id = ct.id
)
SELECT * FROM comment_tree ORDER BY depth, id;
```

---

## 7. Migrations

### 7.1 Migration Structure

```sql
-- ✅ GOOD: Versioned migration files
-- migrations/001_create_users_table.sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- migrations/002_add_users_bio.sql
ALTER TABLE users ADD COLUMN bio TEXT;

-- migrations/003_create_posts_table.sql
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 7.2 Migration Best Practices

```sql
-- ✅ Make migrations reversible
-- UP migration
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- DOWN migration
ALTER TABLE users DROP COLUMN phone;

-- ✅ Use transactions
BEGIN;
ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active';
CREATE INDEX idx_users_status ON users(status);
COMMIT;

-- ✅ Test migrations on a copy of production data before deploying
```

### 7.3 Schema Versioning

```sql
-- ✅ Track migration history
CREATE TABLE schema_migrations (
  version VARCHAR(255) PRIMARY KEY,
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Record applied migrations
INSERT INTO schema_migrations (version) VALUES ('20260316_create_users');
```

---

## 8. JSON/JSONB (PostgreSQL)

### 8.1 When to Use JSONB

**Use JSONB for**:
- Flexible schema (user preferences, settings)
- Semi-structured data (API responses, logs)
- Rapidly changing data models

```sql
-- ✅ JSONB for flexible user preferences
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  preferences JSONB DEFAULT '{}'::jsonb,
  metadata JSONB
);

-- Insert JSON data
INSERT INTO users (email, name, preferences)
VALUES ('john@example.com', 'John', '{"theme": "dark", "language": "en"}');

-- Query JSON fields
SELECT * FROM users WHERE preferences->>'theme' = 'dark';

-- Index JSONB fields
CREATE INDEX idx_users_preferences ON users USING GIN(preferences);
```

### 8.2 JSONB Operators

```sql
-- -> returns JSON object
SELECT preferences->'theme' FROM users;  -- Returns JSON: "dark"

-- ->> returns text
SELECT preferences->>'theme' FROM users;  -- Returns text: dark

-- ? checks if key exists
SELECT * FROM users WHERE preferences ? 'theme';

-- @> checks if contains JSON
SELECT * FROM users WHERE preferences @> '{"theme": "dark"}';

-- #> navigate nested JSON
SELECT metadata#>'{profile,avatar,url}' FROM users;
```

---

## 9. Soft Deletes

```sql
-- ✅ GOOD: Soft delete pattern
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  deleted_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- "Delete" without actually deleting
UPDATE posts SET deleted_at = CURRENT_TIMESTAMP WHERE id = 123;

-- Query only non-deleted records
SELECT * FROM posts WHERE deleted_at IS NULL;

-- Create view for active records
CREATE VIEW active_posts AS
SELECT * FROM posts WHERE deleted_at IS NULL;
```

---

## 10. Partitioning (for Large Tables)

### 10.1 Range Partitioning (by Date)

```sql
-- ✅ Partition large logs table by month
CREATE TABLE logs (
  id BIGSERIAL,
  user_id INTEGER,
  action VARCHAR(100),
  created_at TIMESTAMP NOT NULL,
  PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- Create partitions
CREATE TABLE logs_2026_01 PARTITION OF logs
  FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');

CREATE TABLE logs_2026_02 PARTITION OF logs
  FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');

CREATE TABLE logs_2026_03 PARTITION OF logs
  FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');

-- Queries automatically use correct partition
SELECT * FROM logs WHERE created_at >= '2026-02-15';
```

### 10.2 List Partitioning (by Category)

```sql
-- ✅ Partition users by region
CREATE TABLE users (
  id SERIAL,
  email VARCHAR(255),
  region VARCHAR(10) NOT NULL,
  PRIMARY KEY (id, region)
) PARTITION BY LIST (region);

CREATE TABLE users_us PARTITION OF users FOR VALUES IN ('US', 'CA');
CREATE TABLE users_eu PARTITION OF users FOR VALUES IN ('UK', 'FR', 'DE');
CREATE TABLE users_asia PARTITION OF users FOR VALUES IN ('JP', 'CN', 'IN');
```

---

## 11. Audit Trails

```sql
-- ✅ Audit table pattern
CREATE TABLE audit_log (
  id BIGSERIAL PRIMARY KEY,
  table_name VARCHAR(100) NOT NULL,
  record_id INTEGER NOT NULL,
  action VARCHAR(20) NOT NULL,  -- INSERT, UPDATE, DELETE
  old_data JSONB,
  new_data JSONB,
  changed_by INTEGER REFERENCES users(id),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger function to log changes
CREATE OR REPLACE FUNCTION log_audit()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, changed_by)
  VALUES (
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    TG_OP,
    CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
    CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) ELSE NULL END,
    current_setting('app.current_user_id', TRUE)::INTEGER
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to table
CREATE TRIGGER users_audit
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION log_audit();
```

---

## 12. NoSQL Design Patterns

### 12.1 MongoDB Document Design

```javascript
// ✅ GOOD: Embed related data for read efficiency
{
  "_id": ObjectId("..."),
  "name": "John Doe",
  "email": "john@example.com",
  "address": {
    "street": "123 Main St",
    "city": "Springfield",
    "country": "US"
  },
  "posts": [
    {
      "id": 1,
      "title": "First Post",
      "content": "...",
      "created_at": ISODate("2026-03-16T10:00:00Z")
    }
  ]
}

// ❌ BAD: Over-embedding (posts array could grow unbounded)
// Instead, reference posts in separate collection
{
  "_id": ObjectId("..."),
  "name": "John Doe",
  "email": "john@example.com",
  "post_ids": [1, 2, 3, ...]  // Just references
}
```

### 12.2 Redis Data Structures

```redis
# String (cache, session)
SET user:123:name "John Doe"
GET user:123:name

# Hash (user object)
HSET user:123 name "John" email "john@example.com" age 30
HGETALL user:123

# List (activity feed)
LPUSH user:123:feed "Posted a comment"
LRANGE user:123:feed 0 9  # Get last 10 items

# Set (unique tags)
SADD post:456:tags "javascript" "tutorial" "beginner"
SMEMBERS post:456:tags

# Sorted Set (leaderboard)
ZADD leaderboard 1000 "user:123" 950 "user:456"
ZREVRANGE leaderboard 0 9 WITHSCORES  # Top 10
```

---

## Anti-Patterns

### ❌ EAV (Entity-Attribute-Value) Pattern
Storing structured data as key-value pairs.

**Solution**: Use JSONB for flexible schema or proper columns.

### ❌ Storing Delimited Lists
Storing comma-separated values in a single column.

**Solution**: Use array type or junction table.

### ❌ Overusing TEXT/VARCHAR
Using TEXT for everything.

**Solution**: Choose appropriate data types (INTEGER, BOOLEAN, DECIMAL).

### ❌ Missing Indexes on Foreign Keys
Not indexing columns used in JOINs.

**Solution**: Always index foreign key columns.

### ❌ Using SELECT *
Selecting all columns when only a few are needed.

**Solution**: Specify needed columns explicitly.

---

## Related Modules

- **API_DESIGN** - API layer above database
- **PERFORMANCE_OPTIMIZATION** - Query optimization and caching
- **MICROSERVICES_PATTERNS** - Database per service pattern

---

## Resources

**PostgreSQL**:
- Official Docs: https://www.postgresql.org/docs/
- Performance Tips: https://wiki.postgresql.org/wiki/Performance_Optimization

**MySQL**:
- Official Docs: https://dev.mysql.com/doc/

**MongoDB**:
- Official Docs: https://docs.mongodb.com/
- Data Modeling: https://docs.mongodb.com/manual/core/data-modeling-introduction/

**Tools**:
- pgAdmin: PostgreSQL GUI
- DBeaver: Universal database tool
- DataGrip: JetBrains database IDE
