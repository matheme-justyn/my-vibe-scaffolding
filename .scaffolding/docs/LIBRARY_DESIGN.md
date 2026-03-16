# LIBRARY DESIGN

**Status**: Active | **Domain**: Project Types  
**Related Modules**: CLI_DESIGN, API_DESIGN, STYLE_GUIDE

## Purpose

This module defines standards for designing reusable libraries and packages that are maintainable, well-documented, and easy to integrate. It covers public API design, versioning, backward compatibility, documentation, testing, and distribution.

## When to Use This Module

- Creating reusable npm/PyPI/gem packages
- Designing public APIs for libraries
- Planning version releases and deprecation
- Writing library documentation
- Implementing backward compatibility
- Publishing to package registries

---

## 1. Library Design Principles

### 1.1 Minimal Public API

```typescript
// ✅ GOOD: Small, focused API surface
export class Database {
  connect(url: string): Promise<void>
  disconnect(): Promise<void>
  query<T>(sql: string, params?: any[]): Promise<T[]>
}

// ❌ BAD: Exposing internal implementation
export class Database {
  connect(url: string): Promise<void>
  disconnect(): Promise<void>
  query<T>(sql: string, params?: any[]): Promise<T[]>
  _parseConnectionString(url: string): ConnectionConfig  // Internal!
  _createConnection(config: ConnectionConfig): Connection  // Internal!
  _validateQuery(sql: string): boolean  // Internal!
}
```

### 1.2 Principle of Least Surprise

```typescript
// ✅ GOOD: Intuitive naming and behavior
array.filter(x => x > 0)  // Returns new array
array.sort()  // Sorts in-place (expected for sort)

// ❌ BAD: Surprising behavior
array.filter(x => x > 0)  // Modifies original array (unexpected!)
```

### 1.3 Consistent API Design

```typescript
// ✅ GOOD: Consistent method signatures
class Cache {
  get(key: string): Promise<any>
  set(key: string, value: any): Promise<void>
  delete(key: string): Promise<void>
  has(key: string): Promise<boolean>
}

// ❌ BAD: Inconsistent signatures
class Cache {
  get(key: string): Promise<any>
  set(key: string, value: any, callback: Function): void  // Callback instead of Promise
  delete(key): any  // Missing type, different return
  hasKey(k: string): boolean  // Different naming pattern
}
```

---

## 2. Public API Design

### 2.1 Clear Entry Point

```typescript
// ✅ GOOD: Single main export
// index.ts
export { Database } from './database';
export { Query } from './query';
export type { DatabaseConfig, QueryResult } from './types';

// Usage
import { Database } from 'my-database-lib';
const db = new Database();

// ❌ BAD: Deep imports required
import { Database } from 'my-database-lib/dist/core/database';
```

### 2.2 Options Objects

```typescript
// ✅ GOOD: Options object for flexibility
interface DatabaseConfig {
  host: string;
  port?: number;
  username?: string;
  password?: string;
  ssl?: boolean;
  timeout?: number;
}

const db = new Database({
  host: 'localhost',
  port: 5432,
  ssl: true
});

// ❌ BAD: Many positional parameters
const db = new Database('localhost', 5432, 'user', 'pass', true, 5000);
```

### 2.3 Builder Pattern (for Complex Configuration)

```typescript
// ✅ GOOD: Fluent builder API
const query = new QueryBuilder()
  .select('id', 'name', 'email')
  .from('users')
  .where('age', '>', 18)
  .orderBy('name')
  .limit(10)
  .build();
```

---

## 3. Backward Compatibility

### 3.1 Semantic Versioning (SemVer)

```
MAJOR.MINOR.PATCH

MAJOR: Breaking changes (incompatible API changes)
MINOR: New features (backward-compatible)
PATCH: Bug fixes (backward-compatible)

Examples:
1.0.0 → 1.0.1  (Bug fix)
1.0.1 → 1.1.0  (New feature, no breaking changes)
1.1.0 → 2.0.0  (Breaking change)
```

### 3.2 Deprecation Strategy

```typescript
// ✅ GOOD: Deprecate before removing
/**
 * @deprecated Use `query()` instead. Will be removed in v3.0.0
 */
export function execute(sql: string): Promise<any> {
  console.warn('execute() is deprecated. Use query() instead.');
  return this.query(sql);
}

// New method
export function query(sql: string): Promise<any> {
  // Implementation
}

// Timeline:
// v2.0.0: Add query(), deprecate execute()
// v2.x.x: Both methods work, warnings for execute()
// v3.0.0: Remove execute()
```

### 3.3 Feature Flags

```typescript
// ✅ GOOD: Feature flags for experimental features
interface DatabaseConfig {
  host: string;
  experimentalFeatures?: {
    asyncIterators?: boolean;
    streaming?: boolean;
  };
}

const db = new Database({
  host: 'localhost',
  experimentalFeatures: {
    asyncIterators: true  // Opt-in to experimental feature
  }
});
```

---

## 4. Error Handling

### 4.1 Custom Error Classes

```typescript
// ✅ GOOD: Specific error types
export class DatabaseError extends Error {
  constructor(message: string, public code: string) {
    super(message);
    this.name = 'DatabaseError';
  }
}

export class ConnectionError extends DatabaseError {
  constructor(message: string) {
    super(message, 'CONNECTION_ERROR');
  }
}

export class QueryError extends DatabaseError {
  constructor(message: string, public query: string) {
    super(message, 'QUERY_ERROR');
  }
}

// Usage
try {
  await db.query('SELECT * FROM users');
} catch (error) {
  if (error instanceof QueryError) {
    console.error('Query failed:', error.query);
  } else if (error instanceof ConnectionError) {
    console.error('Connection failed');
  }
}
```

### 4.2 Error Messages

```typescript
// ✅ GOOD: Clear, actionable error messages
throw new QueryError(
  'Invalid column "age" in WHERE clause. Available columns: id, name, email',
  query
);

// ❌ BAD: Vague error message
throw new Error('Query failed');
```

---

## 5. TypeScript Support

### 5.1 Type Definitions

```typescript
// ✅ GOOD: Export types alongside implementation
export interface DatabaseConfig {
  host: string;
  port?: number;
  ssl?: boolean;
}

export interface QueryResult<T> {
  rows: T[];
  rowCount: number;
}

export class Database {
  constructor(config: DatabaseConfig);
  query<T = any>(sql: string): Promise<QueryResult<T>>;
}
```

### 5.2 Generic Types

```typescript
// ✅ GOOD: Generics for type safety
interface User {
  id: number;
  name: string;
}

const result = await db.query<User>('SELECT * FROM users');
// result.rows is User[]
```

### 5.3 Declaration Files

```typescript
// index.d.ts
export declare class Database {
  constructor(config: DatabaseConfig);
  connect(): Promise<void>;
  query<T>(sql: string): Promise<QueryResult<T>>;
}

export interface DatabaseConfig {
  host: string;
  port?: number;
}

export interface QueryResult<T> {
  rows: T[];
  rowCount: number;
}
```

---

## 6. Documentation

### 6.1 README Structure

```markdown
# My Library

Brief description (1-2 sentences)

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

\`\`\`bash
npm install my-library
\`\`\`

## Quick Start

\`\`\`javascript
const { Database } = require('my-library');
const db = new Database({ host: 'localhost' });
\`\`\`

## API Documentation

### Database

#### Constructor

\`new Database(config)\`

- \`config\` (Object): Configuration options
  - \`host\` (string): Database host
  - \`port\` (number, optional): Port number (default: 5432)

#### Methods

##### \`connect()\`

Establishes connection to database.

Returns: \`Promise<void>\`

### Examples

[Detailed examples]

## Contributing

[Contribution guidelines]

## License

MIT
```

### 6.2 JSDoc Comments

```typescript
/**
 * Database client for PostgreSQL
 * 
 * @example
 * ```typescript
 * const db = new Database({ host: 'localhost', port: 5432 });
 * await db.connect();
 * const users = await db.query<User>('SELECT * FROM users');
 * ```
 */
export class Database {
  /**
   * Execute a SQL query
   * 
   * @param sql - SQL query string
   * @param params - Query parameters for parameterized queries
   * @returns Query results
   * @throws {QueryError} If query execution fails
   * 
   * @example
   * ```typescript
   * const result = await db.query(
   *   'SELECT * FROM users WHERE age > $1',
   *   [18]
   * );
   * ```
   */
  async query<T>(sql: string, params?: any[]): Promise<QueryResult<T>> {
    // Implementation
  }
}
```

### 6.3 API Reference Generation

```bash
# Generate API docs from JSDoc/TSDoc
typedoc --out docs src/index.ts
```

---

## 7. Testing

### 7.1 Unit Tests

```typescript
// ✅ Comprehensive test coverage
describe('Database', () => {
  let db: Database;

  beforeEach(() => {
    db = new Database({ host: 'localhost' });
  });

  describe('query()', () => {
    it('should execute SELECT query', async () => {
      const result = await db.query('SELECT * FROM users');
      expect(result.rows).toBeInstanceOf(Array);
    });

    it('should throw QueryError for invalid SQL', async () => {
      await expect(db.query('INVALID SQL')).rejects.toThrow(QueryError);
    });

    it('should support parameterized queries', async () => {
      const result = await db.query('SELECT * FROM users WHERE id = $1', [123]);
      expect(result.rows).toHaveLength(1);
    });
  });
});
```

### 7.2 Integration Tests

```typescript
// ✅ Test against real database
describe('Database Integration', () => {
  let db: Database;

  beforeAll(async () => {
    db = new Database({
      host: process.env.TEST_DB_HOST || 'localhost',
      port: 5432
    });
    await db.connect();
  });

  afterAll(async () => {
    await db.disconnect();
  });

  it('should insert and retrieve data', async () => {
    await db.query('INSERT INTO users (name) VALUES ($1)', ['John']);
    const result = await db.query('SELECT * FROM users WHERE name = $1', ['John']);
    expect(result.rows[0].name).toBe('John');
  });
});
```

---

## 8. Package Configuration

### 8.1 package.json

```json
{
  "name": "my-library",
  "version": "1.0.0",
  "description": "Database client for PostgreSQL",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "files": [
    "dist",
    "README.md",
    "LICENSE"
  ],
  "scripts": {
    "build": "tsc",
    "test": "jest",
    "prepublishOnly": "npm run build && npm test"
  },
  "keywords": ["database", "postgresql", "sql"],
  "author": "Your Name",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/username/my-library"
  },
  "bugs": {
    "url": "https://github.com/username/my-library/issues"
  },
  "engines": {
    "node": ">=14.0.0"
  },
  "peerDependencies": {
    "pg": "^8.0.0"
  },
  "devDependencies": {
    "@types/node": "^18.0.0",
    "typescript": "^5.0.0",
    "jest": "^29.0.0"
  }
}
```

### 8.2 Entry Points

```json
{
  "main": "./dist/index.js",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.mjs",
      "require": "./dist/index.js"
    },
    "./advanced": {
      "types": "./dist/advanced.d.ts",
      "import": "./dist/advanced.mjs",
      "require": "./dist/advanced.js"
    }
  }
}
```

---

## 9. Dependency Management

### 9.1 Dependencies vs DevDependencies

```json
{
  "dependencies": {
    "lodash": "^4.17.21"  // Required at runtime
  },
  "devDependencies": {
    "typescript": "^5.0.0",  // Only for development
    "jest": "^29.0.0"
  },
  "peerDependencies": {
    "react": "^18.0.0"  // Must be installed by consumer
  }
}
```

### 9.2 Zero Dependencies (When Possible)

```typescript
// ✅ GOOD: Avoid unnecessary dependencies
// Instead of importing lodash for simple operations
import _ from 'lodash';
const unique = _.uniq(array);

// Use native JavaScript
const unique = [...new Set(array)];
```

---

## 10. Distribution

### 10.1 Build Targets

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "declaration": true,
    "outDir": "./dist",
    "strict": true
  }
}
```

### 10.2 Bundle Formats

```javascript
// rollup.config.js
export default {
  input: 'src/index.ts',
  output: [
    {
      file: 'dist/index.js',
      format: 'cjs'  // CommonJS for Node.js
    },
    {
      file: 'dist/index.mjs',
      format: 'es'   // ES modules
    },
    {
      file: 'dist/index.umd.js',
      format: 'umd',  // Universal module for browsers
      name: 'MyLibrary'
    }
  ]
};
```

### 10.3 Tree Shaking Support

```typescript
// ✅ GOOD: Named exports enable tree shaking
export function connect() {}
export function query() {}

// Usage (only imports used function)
import { query } from 'my-library';

// ❌ BAD: Default export prevents tree shaking
export default {
  connect,
  query
};
```

---

## 11. Changelog

### 11.1 Keep a Changelog Format

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New feature X

## [1.1.0] - 2026-03-16

### Added
- Support for async iterators
- New `stream()` method for large result sets

### Changed
- Improved connection pooling performance

### Deprecated
- `execute()` method (use `query()` instead)

### Fixed
- Fixed memory leak in connection pool

## [1.0.0] - 2026-01-01

### Added
- Initial release
- Basic query functionality
- Connection pooling
```

---

## 12. Versioning Strategy

### 12.1 Pre-release Versions

```
1.0.0-alpha.1   # Alpha (unstable, missing features)
1.0.0-beta.1    # Beta (feature-complete, testing)
1.0.0-rc.1      # Release candidate (production-ready, final testing)
1.0.0           # Stable release
```

### 12.2 Version Ranges

```json
{
  "dependencies": {
    "exact": "1.2.3",           // Exact version
    "patch": "~1.2.3",          // 1.2.x (patch updates)
    "minor": "^1.2.3",          // 1.x.x (minor updates)
    "major": "*"                // Any version (not recommended)
  }
}
```

---

## 13. Examples Directory

```
my-library/
├── examples/
│   ├── basic-usage.js
│   ├── advanced-queries.js
│   ├── connection-pooling.js
│   └── typescript-example.ts
├── src/
├── dist/
└── README.md
```

```javascript
// examples/basic-usage.js
const { Database } = require('my-library');

async function main() {
  const db = new Database({ host: 'localhost' });
  
  try {
    await db.connect();
    const users = await db.query('SELECT * FROM users');
    console.log('Users:', users.rows);
  } finally {
    await db.disconnect();
  }
}

main();
```

---

## 14. Security

### 14.1 Security Policy

```markdown
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.x.x   | :white_check_mark: |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

Please report security vulnerabilities to security@example.com.
Do not open public issues for security vulnerabilities.
```

### 14.2 Dependency Audits

```bash
# Regular security audits
npm audit
npm audit fix

# Automated updates
npm install -g npm-check-updates
ncu -u
```

---

## Anti-Patterns

### ❌ Breaking Changes in Minor Versions
Changing API signatures in minor/patch releases.

**Solution**: Follow semantic versioning strictly.

### ❌ Exposing Internal Implementation
Exporting internal classes/functions.

**Solution**: Only export public API, keep internals private.

### ❌ No TypeScript Definitions
JavaScript-only libraries without type definitions.

**Solution**: Provide `.d.ts` files or write in TypeScript.

### ❌ Poor Documentation
Incomplete or outdated documentation.

**Solution**: Maintain comprehensive docs, keep them updated.

### ❌ Large Bundle Size
Including unnecessary dependencies.

**Solution**: Review dependencies, enable tree shaking, provide separate entry points.

---

## Related Modules

- **CLI_DESIGN** - Command-line interface design
- **API_DESIGN** - Public API patterns
- **STYLE_GUIDE** - Code conventions

---

## Resources

**Package Managers**:
- npm: https://www.npmjs.com/
- Yarn: https://yarnpkg.com/
- pnpm: https://pnpm.io/

**Documentation**:
- TSDoc: https://tsdoc.org/
- TypeDoc: https://typedoc.org/

**Standards**:
- Semantic Versioning: https://semver.org/
- Keep a Changelog: https://keepachangelog.com/
