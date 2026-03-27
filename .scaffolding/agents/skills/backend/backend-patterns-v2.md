---
name: backend-patterns
description: Node.js backend patterns with Iron Laws enforcement - async patterns, error handling, middleware, database queries, API design, and microservices architecture
version: 2.0.0
origin: ECC (everything-claude-code)
adapted_for: OpenCode
enhanced_with: Superpowers Iron Laws
last_updated: 2026-03-27
---

# Backend Patterns

## OpenCode Integration

**When to Use**:
- Building Node.js backend services
- Designing API architecture
- Implementing middleware
- Database query optimization
- Error handling strategies
- Microservices design

**Load this skill when**:
- User mentions "backend", "Node.js", "Express", "API", "microservices"
- Creating server-side logic
- Architecting backend systems

**Usage Pattern**:
```typescript
// Automatically loaded when AGENTS.md detects backend keywords
// Or manually load:
@use backend-patterns
User: "Design a scalable backend API"
```

**Combines well with**:
- `api-design` - REST API design patterns
- `security-review` - Backend security
- `test-driven-development` - TDD workflow

---

## Iron Laws (Superpowers 風格)

### 1. NO SYNC CODE IN ASYNC PATHS

```javascript
// ❌ BAD: Blocks event loop - kills server performance
async function handler(req, res) {
  const data = fs.readFileSync('file.txt')  // BLOCKS all other requests
  res.json({ data })
}

// ❌ BAD: Sync crypto in async handler
async function hashPassword(password: string) {
  return crypto.pbkdf2Sync(password, 'salt', 100000, 64, 'sha512')  // BLOCKS
}

// ✅ GOOD: Non-blocking async operations
async function handler(req, res) {
  const data = await fs.promises.readFile('file.txt', 'utf-8')
  res.json({ data })
}

// ✅ GOOD: Async crypto
async function hashPassword(password: string) {
  return new Promise((resolve, reject) => {
    crypto.pbkdf2(password, 'salt', 100000, 64, 'sha512', (err, key) => {
      if (err) reject(err)
      else resolve(key.toString('hex'))
    })
  })
}
```

**違反處理**:
- 在 code review 階段拒絕 PR
- 要求刪除同步呼叫，改用 async 版本
- Build 階段執行 linter 檢查，失敗則阻擋

**不接受藉口**:
- ❌ "這只是小檔案，很快" → 仍會阻塞 event loop
- ❌ "只在 startup 執行一次" → 用 dynamic import
- ❌ "效能差異不大" → 一個請求阻塞，所有請求等待
- ❌ "這是內部 API" → 內部也要遵守規則

**強制執行**:
- ESLint: `no-sync` rule（所有 `*Sync` 方法報錯）
- TypeScript: 標註 async handler type
- CI: 執行 `eslint --max-warnings 0`

---

### 2. NO NAKED PROMISES (所有 Promise 必須有錯誤處理)

```javascript
// ❌ BAD: Unhandled promise rejection - 靜默失敗
async function handler(req, res) {
  const data = await fetchFromAPI()  // 如果 throw，整個 process 可能 crash
  res.json({ data })
}

// ❌ BAD: Promise without await in async function
async function processData() {
  saveToDatabase(data)  // 忘記 await，不知道成功與否
  return "done"
}

// ✅ GOOD: Try-catch 包裹
async function handler(req, res) {
  try {
    const data = await fetchFromAPI()
    res.json({ data })
  } catch (error) {
    console.error('API fetch failed:', error)
    res.status(500).json({ error: 'Internal error' })
  }
}

// ✅ GOOD: Centralized error handler
async function handler(req, res) {
  const data = await fetchFromAPI()  // Throw 會被 middleware 捕捉
  res.json({ data })
}

// Error middleware
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(500).json({ error: 'Internal error' })
})
```

**違反處理**:
- Code review 發現 naked await → 要求加 try-catch
- 或使用 centralized error middleware（推薦）
- Runtime: 啟用 `process.on('unhandledRejection')` 監控

**不接受藉口**:
- ❌ "這個 API 很穩定" → 網路永遠不穩定
- ❌ "錯誤會往上拋" → 拋到哪？有人捕捉嗎？
- ❌ "有 global error handler" → 那也要確認每個 promise chain 連接正確
- ❌ "測試都過了" → 測試不會模擬所有 network failures

**強制執行**:
- ESLint: `no-floating-promises` (TypeScript ESLint)
- Runtime監控: 
  ```javascript
  process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection:', reason)
    // 在開發環境 crash，production 記錄
  })
  ```
- CI: 檢查是否有 error middleware

---

### 3. NO UNHANDLED ERRORS (Empty Catch 絕對禁止)

```javascript
// ❌ BAD: Silent failure - 吞掉錯誤
try {
  await updateDatabase(data)
} catch (error) {
  // 什麼都不做 - BUG 永遠找不到
}

// ❌ BAD: Console.log 不是錯誤處理
try {
  await criticalOperation()
} catch (error) {
  console.log(error)  // 不夠！沒有回應使用者，沒有 alert
}

// ❌ BAD: Generic error message
try {
  await paymentProcess(amount)
} catch (error) {
  throw new Error('Something went wrong')  // 沒幫助
}

// ✅ GOOD: Log + re-throw with context
try {
  await updateDatabase(data)
} catch (error) {
  console.error('Database update failed:', error)
  throw new ApiError(500, 'Failed to update database', error)
}

// ✅ GOOD: Handle specific errors, re-throw unknown
try {
  await paymentProcess(amount)
} catch (error) {
  if (error.code === 'INSUFFICIENT_FUNDS') {
    throw new ApiError(400, 'Insufficient funds')
  }
  if (error.code === 'CARD_DECLINED') {
    throw new ApiError(400, 'Card declined')
  }
  // Unknown error - log and re-throw
  console.error('Unexpected payment error:', error)
  throw new ApiError(500, 'Payment processing failed')
}
```

**違反處理**:
- Code review 發現 empty catch → 立刻拒絕 PR
- 要求至少: log error + throw or return error response
- 對於 critical operations: 必須 alert/notify

**不接受藉口**:
- ❌ "這個錯誤不重要" → 如果不重要，為什麼寫 try-catch？
- ❌ "只是測試程式碼" → 測試也要 fail loudly
- ❌ "我知道不會出錯" → 那更不該 try-catch
- ❌ "會在 logs 裡" → Console.log 不夠，要 proper logging

**強制執行**:
- ESLint: `no-empty` rule
- Custom ESLint rule: 檢查 catch block 是否只有 console.log
- Code review checklist: ✓ All errors handled properly
- Sentry/監控工具: 設定 alert threshold

---

## Implementation Details (原 ECC 內容)

### Overview

Node.js backend patterns for production-grade server applications.

### When to Activate

- Designing REST or GraphQL API endpoints
- Implementing repository, service, or controller layers
- Optimizing database queries (N+1, indexing, connection pooling)
- Adding caching (Redis, in-memory, HTTP cache headers)
- Setting up background jobs or async processing
- Structuring error handling and validation for APIs
- Building middleware (auth, logging, rate limiting)

### API Design Patterns

#### RESTful API Structure

```typescript
// ✅ Resource-based URLs
GET    /api/markets                 # List resources
GET    /api/markets/:id             # Get single resource
POST   /api/markets                 # Create resource
PUT    /api/markets/:id             # Replace resource
PATCH  /api/markets/:id             # Update resource
DELETE /api/markets/:id             # Delete resource

// ✅ Query parameters for filtering, sorting, pagination
GET /api/markets?status=active&sort=volume&limit=20&offset=0
```

#### Repository Pattern

```typescript
// Abstract data access logic
interface MarketRepository {
  findAll(filters?: MarketFilters): Promise<Market[]>
  findById(id: string): Promise<Market | null>
  create(data: CreateMarketDto): Promise<Market>
  update(id: string, data: UpdateMarketDto): Promise<Market>
  delete(id: string): Promise<void>
}

class SupabaseMarketRepository implements MarketRepository {
  async findAll(filters?: MarketFilters): Promise<Market[]> {
    let query = supabase.from('markets').select('*')

    if (filters?.status) {
      query = query.eq('status', filters.status)
    }

    if (filters?.limit) {
      query = query.limit(filters.limit)
    }

    const { data, error } = await query

    if (error) throw new Error(error.message)
    return data
  }

  // Other methods...
}
```

#### Service Layer Pattern

```typescript
// Business logic separated from data access
class MarketService {
  constructor(private marketRepo: MarketRepository) {}

  async searchMarkets(query: string, limit: number = 10): Promise<Market[]> {
    // Business logic
    const embedding = await generateEmbedding(query)
    const results = await this.vectorSearch(embedding, limit)

    // Fetch full data
    const markets = await this.marketRepo.findByIds(results.map(r => r.id))

    // Sort by similarity
    return markets.sort((a, b) => {
      const scoreA = results.find(r => r.id === a.id)?.score || 0
      const scoreB = results.find(r => r.id === b.id)?.score || 0
      return scoreA - scoreB
    })
  }

  private async vectorSearch(embedding: number[], limit: number) {
    // Vector search implementation
  }
}
```

#### Middleware Pattern

```typescript
// Request/response processing pipeline
export function withAuth(handler: NextApiHandler): NextApiHandler {
  return async (req, res) => {
    const token = req.headers.authorization?.replace('Bearer ', '')

    if (!token) {
      return res.status(401).json({ error: 'Unauthorized' })
    }

    try {
      const user = await verifyToken(token)
      req.user = user
      return handler(req, res)
    } catch (error) {
      return res.status(401).json({ error: 'Invalid token' })
    }
  }
}

// Usage
export default withAuth(async (req, res) => {
  // Handler has access to req.user
})
```

### Database Patterns

#### Query Optimization

```typescript
// ✅ GOOD: Select only needed columns
const { data } = await supabase
  .from('markets')
  .select('id, name, status, volume')
  .eq('status', 'active')
  .order('volume', { ascending: false })
  .limit(10)

// ❌ BAD: Select everything
const { data } = await supabase
  .from('markets')
  .select('*')
```

#### N+1 Query Prevention

```typescript
// ❌ BAD: N+1 query problem
const markets = await getMarkets()
for (const market of markets) {
  market.creator = await getUser(market.creator_id)  // N queries
}

// ✅ GOOD: Batch fetch
const markets = await getMarkets()
const creatorIds = markets.map(m => m.creator_id)
const creators = await getUsers(creatorIds)  // 1 query
const creatorMap = new Map(creators.map(c => [c.id, c]))

markets.forEach(market => {
  market.creator = creatorMap.get(market.creator_id)
})
```

#### Transaction Pattern

```typescript
async function createMarketWithPosition(
  marketData: CreateMarketDto,
  positionData: CreatePositionDto
) {
  // Use Supabase transaction
  const { data, error } = await supabase.rpc('create_market_with_position', {
    market_data: marketData,
    position_data: positionData
  })

  if (error) throw new Error('Transaction failed')
  return data
}

// SQL function in Supabase
CREATE OR REPLACE FUNCTION create_market_with_position(
  market_data jsonb,
  position_data jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
BEGIN
  -- Start transaction automatically
  INSERT INTO markets VALUES (market_data);
  INSERT INTO positions VALUES (position_data);
  RETURN jsonb_build_object('success', true);
EXCEPTION
  WHEN OTHERS THEN
    -- Rollback happens automatically
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;
```

### Caching Strategies

#### Redis Caching Layer

```typescript
class CachedMarketRepository implements MarketRepository {
  constructor(
    private baseRepo: MarketRepository,
    private redis: RedisClient
  ) {}

  async findById(id: string): Promise<Market | null> {
    // Check cache first
    const cached = await this.redis.get(`market:${id}`)

    if (cached) {
      return JSON.parse(cached)
    }

    // Cache miss - fetch from database
    const market = await this.baseRepo.findById(id)

    if (market) {
      // Cache for 5 minutes
      await this.redis.setex(`market:${id}`, 300, JSON.stringify(market))
    }

    return market
  }

  async invalidateCache(id: string): Promise<void> {
    await this.redis.del(`market:${id}`)
  }
}
```

#### Cache-Aside Pattern

```typescript
async function getMarketWithCache(id: string): Promise<Market> {
  const cacheKey = `market:${id}`

  // Try cache
  const cached = await redis.get(cacheKey)
  if (cached) return JSON.parse(cached)

  // Cache miss - fetch from DB
  const market = await db.markets.findUnique({ where: { id } })

  if (!market) throw new Error('Market not found')

  // Update cache
  await redis.setex(cacheKey, 300, JSON.stringify(market))

  return market
}
```

### Error Handling Patterns

#### Centralized Error Handler

```typescript
class ApiError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message)
    Object.setPrototypeOf(this, ApiError.prototype)
  }
}

export function errorHandler(error: unknown, req: Request): Response {
  if (error instanceof ApiError) {
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: error.statusCode })
  }

  if (error instanceof z.ZodError) {
    return NextResponse.json({
      success: false,
      error: 'Validation failed',
      details: error.errors
    }, { status: 400 })
  }

  // Log unexpected errors
  console.error('Unexpected error:', error)

  return NextResponse.json({
    success: false,
    error: 'Internal server error'
  }, { status: 500 })
}

// Usage
export async function GET(request: Request) {
  try {
    const data = await fetchData()
    return NextResponse.json({ success: true, data })
  } catch (error) {
    return errorHandler(error, request)
  }
}
```

#### Retry with Exponential Backoff

```typescript
async function fetchWithRetry<T>(
  fn: () => Promise<T>,
  maxRetries = 3
): Promise<T> {
  let lastError: Error

  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn()
    } catch (error) {
      lastError = error as Error

      if (i < maxRetries - 1) {
        // Exponential backoff: 1s, 2s, 4s
        const delay = Math.pow(2, i) * 1000
        await new Promise(resolve => setTimeout(resolve, delay))
      }
    }
  }

  throw lastError!
}

// Usage
const data = await fetchWithRetry(() => fetchFromAPI())
```

### Authentication & Authorization

#### JWT Token Validation

```typescript
import jwt from 'jsonwebtoken'

interface JWTPayload {
  userId: string
  email: string
  role: 'admin' | 'user'
}

export function verifyToken(token: string): JWTPayload {
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as JWTPayload
    return payload
  } catch (error) {
    throw new ApiError(401, 'Invalid token')
  }
}

export async function requireAuth(request: Request) {
  const token = request.headers.get('authorization')?.replace('Bearer ', '')

  if (!token) {
    throw new ApiError(401, 'Missing authorization token')
  }

  return verifyToken(token)
}

// Usage in API route
export async function GET(request: Request) {
  const user = await requireAuth(request)

  const data = await getDataForUser(user.userId)

  return NextResponse.json({ success: true, data })
}
```

#### Role-Based Access Control

```typescript
type Permission = 'read' | 'write' | 'delete' | 'admin'

interface User {
  id: string
  role: 'admin' | 'moderator' | 'user'
}

const rolePermissions: Record<User['role'], Permission[]> = {
  admin: ['read', 'write', 'delete', 'admin'],
  moderator: ['read', 'write', 'delete'],
  user: ['read', 'write']
}

export function hasPermission(user: User, permission: Permission): boolean {
  return rolePermissions[user.role].includes(permission)
}

export function requirePermission(permission: Permission) {
  return (handler: (request: Request, user: User) => Promise<Response>) => {
    return async (request: Request) => {
      const user = await requireAuth(request)

      if (!hasPermission(user, permission)) {
        throw new ApiError(403, 'Insufficient permissions')
      }

      return handler(request, user)
    }
  }
}

// Usage - HOF wraps the handler
export const DELETE = requirePermission('delete')(
  async (request: Request, user: User) => {
    // Handler receives authenticated user with verified permission
    return new Response('Deleted', { status: 200 })
  }
)
```

### Rate Limiting

#### Simple In-Memory Rate Limiter

```typescript
class RateLimiter {
  private requests = new Map<string, number[]>()

  async checkLimit(
    identifier: string,
    maxRequests: number,
    windowMs: number
  ): Promise<boolean> {
    const now = Date.now()
    const requests = this.requests.get(identifier) || []

    // Remove old requests outside window
    const recentRequests = requests.filter(time => now - time < windowMs)

    if (recentRequests.length >= maxRequests) {
      return false  // Rate limit exceeded
    }

    // Add current request
    recentRequests.push(now)
    this.requests.set(identifier, recentRequests)

    return true
  }
}

const limiter = new RateLimiter()

export async function GET(request: Request) {
  const ip = request.headers.get('x-forwarded-for') || 'unknown'

  const allowed = await limiter.checkLimit(ip, 100, 60000)  // 100 req/min

  if (!allowed) {
    return NextResponse.json({
      error: 'Rate limit exceeded'
    }, { status: 429 })
  }

  // Continue with request
}
```

### Background Jobs & Queues

#### Simple Queue Pattern

```typescript
class JobQueue<T> {
  private queue: T[] = []
  private processing = false

  async add(job: T): Promise<void> {
    this.queue.push(job)

    if (!this.processing) {
      this.process()
    }
  }

  private async process(): Promise<void> {
    this.processing = true

    while (this.queue.length > 0) {
      const job = this.queue.shift()!

      try {
        await this.execute(job)
      } catch (error) {
        console.error('Job failed:', error)
      }
    }

    this.processing = false
  }

  private async execute(job: T): Promise<void> {
    // Job execution logic
  }
}

// Usage for indexing markets
interface IndexJob {
  marketId: string
}

const indexQueue = new JobQueue<IndexJob>()

export async function POST(request: Request) {
  const { marketId } = await request.json()

  // Add to queue instead of blocking
  await indexQueue.add({ marketId })

  return NextResponse.json({ success: true, message: 'Job queued' })
}
```

### Logging & Monitoring

#### Structured Logging

```typescript
interface LogContext {
  userId?: string
  requestId?: string
  method?: string
  path?: string
  [key: string]: unknown
}

class Logger {
  log(level: 'info' | 'warn' | 'error', message: string, context?: LogContext) {
    const entry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      ...context
    }

    console.log(JSON.stringify(entry))
  }

  info(message: string, context?: LogContext) {
    this.log('info', message, context)
  }

  warn(message: string, context?: LogContext) {
    this.log('warn', message, context)
  }

  error(message: string, error: Error, context?: LogContext) {
    this.log('error', message, {
      ...context,
      error: error.message,
      stack: error.stack
    })
  }
}

const logger = new Logger()

// Usage
export async function GET(request: Request) {
  const requestId = crypto.randomUUID()

  logger.info('Fetching markets', {
    requestId,
    method: 'GET',
    path: '/api/markets'
  })

  try {
    const markets = await fetchMarkets()
    return NextResponse.json({ success: true, data: markets })
  } catch (error) {
    logger.error('Failed to fetch markets', error as Error, { requestId })
    return NextResponse.json({ error: 'Internal error' }, { status: 500 })
  }
}
```

---

## Anti-Patterns

### Anti-Pattern 1: Callback Hell

**問題**: Nested callbacks 難以閱讀和維護

**範例**:
```javascript
// ❌ BAD
fetchUser(userId, (user) => {
  fetchPosts(user.id, (posts) => {
    fetchComments(posts[0].id, (comments) => {
      // ...
    })
  })
})
```

**正確做法**: 使用 async/await（Iron Law #1）

### Anti-Pattern 2: Silent Failures

**問題**: 錯誤被吞掉，無法 debug

**範例**: 見 Iron Law #3

### Anti-Pattern 3: Memory Leaks

**問題**: Event listeners 沒清理，timers 沒 clear

**範例**:
```javascript
// ❌ BAD
app.get('/stream', (req, res) => {
  const interval = setInterval(() => {
    res.write('data\n')
  }, 1000)
  // 沒有 cleanup - connection 斷了也繼續執行
})

// ✅ GOOD
app.get('/stream', (req, res) => {
  const interval = setInterval(() => {
    res.write('data\n')
  }, 1000)
  
  req.on('close', () => {
    clearInterval(interval)
  })
})
```

---

## References

- **Origin**: ECC (everything-claude-code) by affaan-m
- **Enhanced**: Superpowers Iron Laws by Jesse Vincent (@obra)
- **ADR**: docs/adr/0013-skills-architecture-superpowers-strictness-ecc-coverage.md
- **Node.js Best Practices**: https://github.com/goldbergyoni/nodebestpractices
- **ESLint Rules**: https://eslint.org/docs/latest/rules/

---

**Remember**: Backend patterns + Iron Laws = Scalable, maintainable, production-ready server applications. Iron Laws are non-negotiable. ✅
