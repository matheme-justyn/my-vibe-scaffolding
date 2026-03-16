# TROUBLESHOOTING

**Status**: Active | Domain: Quality  
**Related Modules**: PERFORMANCE_OPTIMIZATION, BACKEND_PATTERNS, PRODUCTION_READINESS, TESTING_STRATEGY

## Purpose

This module provides systematic debugging strategies, logging patterns, error tracking, root cause analysis, and common troubleshooting scenarios. Use this module to diagnose issues efficiently and build observable systems.

## When to Use This Module

Reference this module when:
- Application crashes or hangs
- Debugging production issues
- Setting up logging and monitoring
- Investigating performance degradation
- Analyzing error patterns
- Implementing error tracking
- Creating runbooks for common issues
- Training team on debugging workflows

## Systematic Debugging Approach

### The Scientific Method

1. **Observe**: What is the actual behavior?
2. **Hypothesize**: What could cause this?
3. **Test**: Verify hypothesis with experiments
4. **Analyze**: Did the test confirm or reject?
5. **Repeat**: Iterate until root cause found

```typescript
// Debugging workflow
class DebugSession {
  private observations: string[] = [];
  private hypotheses: string[] = [];
  private experiments: { hypothesis: string; result: string }[] = [];
  
  observe(observation: string): void {
    this.observations.push(`[${new Date().toISOString()}] ${observation}`);
    console.log(`📋 Observation: ${observation}`);
  }
  
  hypothesize(hypothesis: string): void {
    this.hypotheses.push(hypothesis);
    console.log(`💡 Hypothesis: ${hypothesis}`);
  }
  
  experiment(hypothesis: string, test: () => Promise<boolean>): Promise<void> {
    return test().then(result => {
      const outcome = result ? '✅ Confirmed' : '❌ Rejected';
      this.experiments.push({ hypothesis, result: outcome });
      console.log(`🧪 ${hypothesis}: ${outcome}`);
    });
  }
  
  summarize(): void {
    console.log('\n=== Debug Summary ===');
    console.log('Observations:', this.observations);
    console.log('Hypotheses:', this.hypotheses);
    console.log('Experiments:', this.experiments);
  }
}

// Usage
const debug = new DebugSession();

debug.observe('User login fails with 500 error');
debug.hypothesize('Database connection issue');
await debug.experiment('DB connection timeout', async () => {
  const canConnect = await db.ping();
  return !canConnect;
});
```

## Logging Best Practices

### Structured Logging

```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: {
    service: 'my-app',
    version: process.env.APP_VERSION
  },
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

// Log levels: error, warn, info, http, verbose, debug, silly

// Usage
logger.info('User logged in', {
  userId: '123',
  ip: req.ip,
  userAgent: req.headers['user-agent']
});

logger.error('Database query failed', {
  query: sql,
  error: error.message,
  stack: error.stack
});

logger.debug('Cache hit', {
  key: cacheKey,
  ttl: 300
});
```

### Request Logging Middleware

```typescript
import morgan from 'morgan';

// Custom token for request ID
morgan.token('request-id', (req) => req.id);

// Detailed request logging
app.use(morgan(':request-id :method :url :status :response-time ms - :res[content-length]'));

// Request ID middleware
app.use((req, res, next) => {
  req.id = crypto.randomUUID();
  res.setHeader('X-Request-ID', req.id);
  next();
});

// Log request/response body for debugging
app.use((req, res, next) => {
  if (process.env.LOG_LEVEL === 'debug') {
    logger.debug('Request body', {
      requestId: req.id,
      body: req.body
    });
    
    const originalSend = res.send;
    res.send = function(data) {
      logger.debug('Response body', {
        requestId: req.id,
        body: data
      });
      return originalSend.call(this, data);
    };
  }
  next();
});
```

### Correlation IDs

```typescript
// Propagate request ID across services
async function callExternalService(url: string, requestId: string): Promise<any> {
  const response = await fetch(url, {
    headers: {
      'X-Request-ID': requestId,
      'X-Correlation-ID': requestId
    }
  });
  
  return response.json();
}

// Log with correlation ID
logger.info('Calling external service', {
  requestId: req.id,
  correlationId: req.headers['x-correlation-id'],
  url
});
```

## Error Tracking

### Sentry Integration

```typescript
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1,
  beforeSend(event, hint) {
    // Filter sensitive data
    if (event.request?.cookies) {
      delete event.request.cookies;
    }
    return event;
  }
});

// Capture exception with context
try {
  await processPayment(orderId);
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      operation: 'payment',
      orderId
    },
    user: {
      id: req.user.id,
      email: req.user.email
    },
    extra: {
      orderDetails: order
    }
  });
  
  throw error;
}

// Breadcrumbs for context
Sentry.addBreadcrumb({
  category: 'payment',
  message: 'Payment initiated',
  level: 'info',
  data: { orderId, amount }
});
```

### Custom Error Classes

```typescript
class AppError extends Error {
  constructor(
    public message: string,
    public statusCode: number = 500,
    public isOperational: boolean = true,
    public context?: Record<string, any>
  ) {
    super(message);
    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message: string, context?: Record<string, any>) {
    super(message, 400, true, context);
  }
}

class DatabaseError extends AppError {
  constructor(message: string, context?: Record<string, any>) {
    super(message, 500, false, context);
  }
}

// Global error handler
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  if (err instanceof AppError) {
    logger.error(err.message, {
      requestId: req.id,
      statusCode: err.statusCode,
      context: err.context,
      stack: err.stack
    });
    
    res.status(err.statusCode).json({
      error: err.message,
      requestId: req.id
    });
  } else {
    // Unexpected error
    logger.error('Unexpected error', {
      requestId: req.id,
      error: err.message,
      stack: err.stack
    });
    
    Sentry.captureException(err);
    
    res.status(500).json({
      error: 'Internal server error',
      requestId: req.id
    });
  }
});
```

## Debugging Tools

### Node.js Debugger

```bash
# Start with debugger
node --inspect server.js

# Debug with Chrome DevTools
# Open chrome://inspect

# VS Code launch.json
{
  "type": "node",
  "request": "launch",
  "name": "Debug Server",
  "program": "${workspaceFolder}/server.js",
  "env": {
    "NODE_ENV": "development"
  }
}
```

### Interactive Debugging

```typescript
// Breakpoint in code
debugger; // Execution pauses here when debugger attached

// Conditional breakpoint
if (userId === '123') {
  debugger;
}

// Console debugging
console.trace('Execution path'); // Print stack trace
console.time('operation');
// ... code
console.timeEnd('operation'); // Log duration

// Inspect object
console.dir(complexObject, { depth: null });
```

### Memory Leak Detection

```typescript
import v8 from 'v8';
import { writeHeapSnapshot } from 'v8';

// Take heap snapshot
function captureHeapSnapshot(filename: string): void {
  writeHeapSnapshot(filename);
  console.log(`Heap snapshot saved to ${filename}`);
}

// Monitor memory usage
setInterval(() => {
  const usage = process.memoryUsage();
  logger.info('Memory usage', {
    heapUsed: `${(usage.heapUsed / 1024 / 1024).toFixed(2)} MB`,
    heapTotal: `${(usage.heapTotal / 1024 / 1024).toFixed(2)} MB`,
    rss: `${(usage.rss / 1024 / 1024).toFixed(2)} MB`
  });
}, 60000); // Every minute

// Detect memory leaks with clinic.js
// npm install -g clinic
// clinic doctor -- node server.js
```

## Common Issues and Solutions

### Issue: Database Connection Timeout

**Symptoms:**
- Slow API responses
- Connection pool exhausted errors
- Timeout errors

**Diagnosis:**
```typescript
// Check connection pool status
const poolStatus = pool.totalCount - pool.idleCount;
logger.info('Connection pool', {
  total: pool.totalCount,
  idle: pool.idleCount,
  active: poolStatus
});

// Enable query logging
const query = await db.query({
  text: 'SELECT * FROM users WHERE id = $1',
  values: [userId]
}, {
  logging: (sql, timing) => {
    logger.debug('Query executed', { sql, timing });
  }
});
```

**Solutions:**
1. Increase pool size
2. Add connection timeouts
3. Use connection pooling
4. Optimize slow queries

### Issue: Memory Leak

**Symptoms:**
- Increasing memory usage over time
- Out of memory errors
- Process crashes

**Diagnosis:**
```typescript
// Take heap snapshots at intervals
let snapshotCount = 0;

setInterval(() => {
  captureHeapSnapshot(`heap-${++snapshotCount}.heapsnapshot`);
}, 300000); // Every 5 minutes

// Compare snapshots in Chrome DevTools
// Memory > Load snapshot > Compare
```

**Solutions:**
1. Remove event listener leaks
2. Clear timers and intervals
3. Avoid global variable accumulation
4. Use WeakMap/WeakSet for caches

### Issue: Rate Limiting Exceeded

**Symptoms:**
- 429 Too Many Requests errors
- Blocked API calls

**Diagnosis:**
```typescript
// Log rate limit status
app.use((req, res, next) => {
  res.on('finish', () => {
    const remaining = res.getHeader('X-RateLimit-Remaining');
    const limit = res.getHeader('X-RateLimit-Limit');
    
    logger.info('Rate limit status', {
      requestId: req.id,
      remaining,
      limit,
      userId: req.user?.id
    });
  });
  next();
});
```

**Solutions:**
1. Implement exponential backoff
2. Batch requests
3. Use caching
4. Upgrade API tier

### Issue: CORS Errors

**Symptoms:**
- Browser blocks requests
- "Access-Control-Allow-Origin" errors

**Diagnosis:**
```typescript
// Log CORS headers
app.use((req, res, next) => {
  logger.debug('CORS request', {
    origin: req.headers.origin,
    method: req.method,
    path: req.path
  });
  next();
});
```

**Solutions:**
```typescript
import cors from 'cors';

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

## Observability

### Health Checks

```typescript
app.get('/health', async (req, res) => {
  const checks = {
    database: false,
    redis: false,
    external_api: false
  };
  
  try {
    await db.query('SELECT 1');
    checks.database = true;
  } catch (error) {
    logger.error('Database health check failed', { error });
  }
  
  try {
    await redis.ping();
    checks.redis = true;
  } catch (error) {
    logger.error('Redis health check failed', { error });
  }
  
  const healthy = Object.values(checks).every(v => v);
  
  res.status(healthy ? 200 : 503).json({
    status: healthy ? 'healthy' : 'unhealthy',
    checks,
    timestamp: new Date().toISOString()
  });
});
```

### Metrics Dashboard

```typescript
import prometheus from 'prom-client';

const register = new prometheus.Registry();

// HTTP request duration
const httpDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

register.registerMetric(httpDuration);

// Middleware
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpDuration.labels(req.method, req.route?.path || req.path, res.statusCode.toString()).observe(duration);
  });
  
  next();
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

## Anti-Patterns

### ❌ Console.log in Production

```typescript
// NEVER DO THIS
console.log('User data:', user);
```

**Why it's wrong**: No structure, no filtering, no searchability.

**Do this instead**: Use structured logging (Winston, Pino).

### ❌ Swallowing Errors

```typescript
// NEVER DO THIS
try {
  await operation();
} catch (error) {
  // Silent failure
}
```

**Why it's wrong**: Issues go unnoticed.

**Do this instead**: Log and track errors.

### ❌ No Request IDs

```typescript
// NEVER DO THIS
logger.error('Request failed', { error });
```

**Why it's wrong**: Can't trace errors across logs.

**Do this instead**: Include request ID in all logs.

## Related Modules

- **PERFORMANCE_OPTIMIZATION** - Performance debugging
- **PRODUCTION_READINESS** - Production monitoring
- **BACKEND_PATTERNS** - Error handling patterns
- **TESTING_STRATEGY** - Testing for debugging
