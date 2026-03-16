# PERFORMANCE_OPTIMIZATION

**Status**: Active | Domain: Quality  
**Related Modules**: BACKEND_PATTERNS, FRONTEND_STANDARDS, DATABASE_SCHEMA, PRODUCTION_READINESS

## Purpose

This module provides comprehensive guidance for optimizing application performance. It covers profiling, caching strategies, database optimization, lazy loading, code splitting, CDN usage, and monitoring. Use this module to identify bottlenecks and implement proven performance improvements.

## When to Use This Module

Reference this module when:
- Application response time is slow
- Database queries are causing bottlenecks
- Frontend bundle size is too large
- Server CPU/memory usage is high
- Implementing caching strategies
- Preparing for production deployment
- Scaling to handle increased traffic
- Conducting performance audits
- Troubleshooting performance degradation

## Profiling and Measurement

### Frontend Performance Measurement

```typescript
// Performance API
const perfObserver = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    console.log(`${entry.name}: ${entry.duration}ms`);
  }
});

perfObserver.observe({ entryTypes: ['measure', 'navigation', 'resource'] });

// Custom timing
performance.mark('task-start');
// ... perform task
performance.mark('task-end');
performance.measure('task-duration', 'task-start', 'task-end');

// Web Vitals monitoring
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

getCLS(console.log); // Cumulative Layout Shift
getFID(console.log); // First Input Delay
getFCP(console.log); // First Contentful Paint
getLCP(console.log); // Largest Contentful Paint
getTTFB(console.log); // Time to First Byte
```

### Backend Profiling

```typescript
import { performance } from 'perf_hooks';

// Function profiling
function profileAsync<T>(fn: () => Promise<T>, label: string): Promise<T> {
  const start = performance.now();
  
  return fn().finally(() => {
    const duration = performance.now() - start;
    console.log(`${label}: ${duration.toFixed(2)}ms`);
  });
}

// Usage
app.get('/api/users', async (req, res) => {
  const users = await profileAsync(
    () => db.users.findAll(),
    'Fetch users query'
  );
  
  res.json(users);
});

// Detailed profiling with clinic.js
// Run: clinic doctor -- node server.js
// Generate flamegraphs and analyze bottlenecks
```

## Caching Strategies

### In-Memory Caching

```typescript
import NodeCache from 'node-cache';

// Create cache instance
const cache = new NodeCache({
  stdTTL: 600, // 10 minutes default TTL
  checkperiod: 120 // Check for expired keys every 2 minutes
});

// Cache wrapper
async function cachedQuery<T>(
  key: string,
  fn: () => Promise<T>,
  ttl?: number
): Promise<T> {
  const cached = cache.get<T>(key);
  
  if (cached !== undefined) {
    return cached;
  }
  
  const result = await fn();
  cache.set(key, result, ttl);
  
  return result;
}

// Usage
app.get('/api/users/:id', async (req, res) => {
  const { id } = req.params;
  
  const user = await cachedQuery(
    `user:${id}`,
    () => db.users.findById(id),
    300 // 5 minutes
  );
  
  res.json(user);
});

// Cache invalidation
async function updateUser(id: string, data: any): Promise<void> {
  await db.users.update(id, data);
  cache.del(`user:${id}`);
}
```

### Redis Caching

```typescript
import { createClient } from 'redis';

const redis = createClient({ url: 'redis://localhost:6379' });
await redis.connect();

// Cache with Redis
async function cacheWithRedis<T>(
  key: string,
  fn: () => Promise<T>,
  ttl: number = 600
): Promise<T> {
  const cached = await redis.get(key);
  
  if (cached) {
    return JSON.parse(cached);
  }
  
  const result = await fn();
  await redis.setEx(key, ttl, JSON.stringify(result));
  
  return result;
}

// Cache patterns
class CacheManager {
  // Cache-aside pattern
  async get<T>(key: string): Promise<T | null> {
    const cached = await redis.get(key);
    return cached ? JSON.parse(cached) : null;
  }
  
  async set(key: string, value: any, ttl: number = 600): Promise<void> {
    await redis.setEx(key, ttl, JSON.stringify(value));
  }
  
  async invalidate(key: string): Promise<void> {
    await redis.del(key);
  }
  
  // Cache with tags for bulk invalidation
  async setWithTags(key: string, value: any, tags: string[], ttl: number = 600): Promise<void> {
    await redis.setEx(key, ttl, JSON.stringify(value));
    
    for (const tag of tags) {
      await redis.sAdd(`tag:${tag}`, key);
    }
  }
  
  async invalidateByTag(tag: string): Promise<void> {
    const keys = await redis.sMembers(`tag:${tag}`);
    
    if (keys.length > 0) {
      await redis.del(keys);
    }
    
    await redis.del(`tag:${tag}`);
  }
}

// Usage
const cacheManager = new CacheManager();

await cacheManager.setWithTags('user:123', userData, ['users', 'user:123'], 600);
await cacheManager.invalidateByTag('users'); // Invalidate all user caches
```

### HTTP Caching Headers

```typescript
app.get('/api/posts/:id', async (req, res) => {
  const { id } = req.params;
  const post = await db.posts.findById(id);
  
  // Cache-Control header
  res.setHeader('Cache-Control', 'public, max-age=300'); // 5 minutes
  
  // ETag for conditional requests
  const etag = crypto.createHash('md5').update(JSON.stringify(post)).digest('hex');
  res.setHeader('ETag', etag);
  
  // Check If-None-Match header
  if (req.headers['if-none-match'] === etag) {
    return res.status(304).end();
  }
  
  res.json(post);
});

// Vary header for different cache keys
app.get('/api/data', (req, res) => {
  res.setHeader('Vary', 'Accept-Encoding, Accept-Language');
  // ...
});
```

## Database Optimization

### Query Optimization

```typescript
// BAD: N+1 query problem
const users = await db.users.findAll();
for (const user of users) {
  user.posts = await db.posts.findByUserId(user.id); // N queries
}

// GOOD: Eager loading
const users = await db.users.findAll({
  include: [{ model: db.posts }] // Single query with JOIN
});

// Query indexing
await db.query(`
  CREATE INDEX idx_posts_user_id ON posts(user_id);
  CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
`);

// Composite index for multi-column queries
await db.query(`
  CREATE INDEX idx_posts_user_status ON posts(user_id, status);
`);

// EXPLAIN query performance
const explain = await db.query('EXPLAIN ANALYZE SELECT * FROM posts WHERE user_id = $1', [userId]);
console.log(explain);
```

### Connection Pooling

```typescript
import { Pool } from 'pg';

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'myapp',
  user: 'postgres',
  password: 'password',
  max: 20, // Maximum pool size
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000
});

// Query with pooling
async function query(text: string, params: any[]): Promise<any> {
  const client = await pool.connect();
  
  try {
    return await client.query(text, params);
  } finally {
    client.release();
  }
}
```

### Pagination and Cursors

```typescript
// Offset pagination (simple but slower for large offsets)
app.get('/api/posts', async (req, res) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const offset = (page - 1) * limit;
  
  const posts = await db.posts.findAll({ limit, offset });
  
  res.json({ posts, page, limit });
});

// Cursor-based pagination (faster for large datasets)
app.get('/api/posts/cursor', async (req, res) => {
  const cursor = req.query.cursor as string;
  const limit = parseInt(req.query.limit as string) || 20;
  
  const query = cursor
    ? 'SELECT * FROM posts WHERE id < $1 ORDER BY id DESC LIMIT $2'
    : 'SELECT * FROM posts ORDER BY id DESC LIMIT $1';
  
  const params = cursor ? [cursor, limit] : [limit];
  const posts = await db.query(query, params);
  
  const nextCursor = posts.length > 0 ? posts[posts.length - 1].id : null;
  
  res.json({ posts, nextCursor });
});
```

## Frontend Optimization

### Code Splitting

```typescript
// React lazy loading
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./Dashboard'));
const Profile = lazy(() => import('./Profile'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/profile" element={<Profile />} />
      </Routes>
    </Suspense>
  );
}

// Webpack dynamic imports
async function loadModule() {
  const module = await import(/* webpackChunkName: "heavy-module" */ './heavy-module');
  module.doSomething();
}

// Route-based splitting (Next.js)
// pages/dashboard.tsx -> automatically code-split
```

### Image Optimization

```typescript
// Next.js Image component
import Image from 'next/image';

<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={600}
  priority // Load immediately
  placeholder="blur" // Show blur while loading
/>

// Lazy loading images
<img
  src="/image.jpg"
  loading="lazy"
  decoding="async"
  alt="Lazy loaded image"
/>

// Responsive images
<picture>
  <source srcset="/image-mobile.jpg" media="(max-width: 600px)" />
  <source srcset="/image-tablet.jpg" media="(max-width: 1200px)" />
  <img src="/image-desktop.jpg" alt="Responsive image" />
</picture>

// WebP with fallback
<picture>
  <source srcset="/image.webp" type="image/webp" />
  <img src="/image.jpg" alt="Image with WebP support" />
</picture>
```

### Bundle Optimization

```javascript
// webpack.config.js
module.exports = {
  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          priority: 10
        },
        common: {
          minChunks: 2,
          priority: 5,
          reuseExistingChunk: true
        }
      }
    },
    minimize: true,
    usedExports: true // Tree shaking
  }
};

// package.json - Remove unused dependencies
npm prune --production

// Analyze bundle size
npx webpack-bundle-analyzer dist/stats.json
```

### Memoization

```typescript
import { useMemo, useCallback } from 'react';

function ExpensiveComponent({ data, filter }) {
  // Memoize expensive computation
  const filteredData = useMemo(() => {
    return data.filter(item => item.category === filter);
  }, [data, filter]);
  
  // Memoize callback to prevent re-renders
  const handleClick = useCallback(() => {
    console.log('Clicked');
  }, []);
  
  return <div>{/* Render filtered data */}</div>;
}

// React.memo for component memoization
const MemoizedComponent = React.memo(({ value }) => {
  return <div>{value}</div>;
}, (prevProps, nextProps) => {
  // Custom comparison
  return prevProps.value === nextProps.value;
});
```

## Asset Optimization

### CDN Integration

```typescript
// CloudFlare CDN configuration
const CDN_URL = process.env.CDN_URL || '';

function getAssetUrl(path: string): string {
  return CDN_URL ? `${CDN_URL}${path}` : path;
}

// Usage
<link rel="stylesheet" href={getAssetUrl('/styles/main.css')} />
<script src={getAssetUrl('/scripts/app.js')}></script>
```

### Compression

```typescript
import compression from 'compression';

// Gzip compression
app.use(compression({
  level: 6, // Compression level (0-9)
  threshold: 1024, // Only compress responses > 1KB
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  }
}));

// Brotli compression (better than gzip)
import { promisify } from 'util';
import { brotliCompress } from 'zlib';

const compress = promisify(brotliCompress);

async function compressResponse(data: Buffer): Promise<Buffer> {
  return await compress(data);
}
```

### Static Asset Versioning

```typescript
// Generate hash-based filenames
import crypto from 'crypto';
import fs from 'fs';

function generateAssetHash(filePath: string): string {
  const content = fs.readFileSync(filePath);
  return crypto.createHash('md5').update(content).digest('hex').substring(0, 8);
}

// Rename assets with hash
const cssHash = generateAssetHash('dist/main.css');
fs.renameSync('dist/main.css', `dist/main.${cssHash}.css`);

// Long cache headers for versioned assets
app.use('/assets', express.static('public/assets', {
  maxAge: '1y', // Cache for 1 year
  immutable: true
}));
```

## API Optimization

### Response Compression

```typescript
app.get('/api/data', async (req, res) => {
  const data = await fetchLargeData();
  
  // Enable compression
  res.setHeader('Content-Encoding', 'gzip');
  res.json(data);
});
```

### GraphQL DataLoader

```typescript
import DataLoader from 'dataloader';

// Batch loading to solve N+1 problem
const userLoader = new DataLoader(async (userIds: readonly string[]) => {
  const users = await db.users.findByIds(userIds);
  
  // Return users in same order as userIds
  const userMap = new Map(users.map(u => [u.id, u]));
  return userIds.map(id => userMap.get(id));
});

// GraphQL resolver
const resolvers = {
  Post: {
    author: (post) => userLoader.load(post.authorId)
  }
};
```

### Rate Limiting and Throttling

```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per window
  standardHeaders: true,
  legacyHeaders: false
});

app.use('/api', limiter);

// Per-user rate limiting
const userLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: async (req) => {
    const user = req.user;
    return user?.tier === 'premium' ? 1000 : 100;
  },
  keyGenerator: (req) => req.user?.id || req.ip
});
```

## Monitoring and Alerts

### Application Monitoring

```typescript
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 0.1, // Sample 10% of transactions
  profilesSampleRate: 0.1
});

// Performance monitoring
app.use((req, res, next) => {
  const transaction = Sentry.startTransaction({
    op: 'http',
    name: `${req.method} ${req.path}`
  });
  
  res.on('finish', () => {
    transaction.setHttpStatus(res.statusCode);
    transaction.finish();
  });
  
  next();
});
```

### Custom Metrics

```typescript
import { StatsD } from 'node-statsd';

const statsd = new StatsD({ host: 'localhost', port: 8125 });

// Track metrics
function recordMetric(name: string, value: number, tags?: string[]): void {
  statsd.gauge(name, value, tags);
}

// Middleware for response time tracking
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    recordMetric('http.response_time', duration, [`method:${req.method}`, `path:${req.path}`]);
  });
  
  next();
});
```

## Anti-Patterns

### ❌ Premature Optimization

```typescript
// AVOID: Optimizing before profiling
function complexOptimization() {
  // Highly optimized but unreadable code
}
```

**Why it's wrong**: Wastes time optimizing non-bottlenecks.

**Do this instead**: Profile first, optimize bottlenecks.

### ❌ Over-Caching

```typescript
// NEVER DO THIS
cache.set('data', result, 86400000); // Cache for 24 hours without invalidation
```

**Why it's wrong**: Serves stale data.

**Do this instead**: Use appropriate TTLs and cache invalidation.

### ❌ Synchronous Operations in Request Handlers

```typescript
// NEVER DO THIS
app.get('/data', (req, res) => {
  const data = fs.readFileSync('data.json'); // Blocks event loop
  res.json(JSON.parse(data));
});
```

**Why it's wrong**: Blocks all requests.

**Do this instead**: Use async operations.

### ❌ Loading All Data at Once

```typescript
// NEVER DO THIS
const allUsers = await db.users.findAll(); // Loads millions of records
```

**Why it's wrong**: Memory exhaustion.

**Do this instead**: Use pagination or streaming.

## Related Modules

- **BACKEND_PATTERNS** - Async patterns and architecture
- **DATABASE_SCHEMA** - Query optimization
- **FRONTEND_STANDARDS** - Frontend performance
- **PRODUCTION_READINESS** - Production optimization
- **TROUBLESHOOTING** - Performance debugging
