# PRODUCTION_READINESS

**Status**: Active | Domain: Quality  
**Related Modules**: PERFORMANCE_OPTIMIZATION, TROUBLESHOOTING, SECURITY_CHECKLIST, BACKEND_PATTERNS

## Purpose

This module provides a comprehensive production deployment checklist covering security, monitoring, scalability, disaster recovery, and operational readiness. Use this module to ensure applications are production-ready before launch.

## When to Use This Module

Reference this module when:
- Preparing for production deployment
- Conducting pre-launch reviews
- Setting up monitoring and alerting
- Implementing disaster recovery plans
- Scaling to production traffic
- Performing security audits
- Creating operational runbooks
- Onboarding production systems

## Production Checklist

### Security

- [ ] **Environment Variables**: All secrets in environment variables, not code
- [ ] **HTTPS**: TLS/SSL certificates configured and valid
- [ ] **Authentication**: Secure authentication implemented
- [ ] **Authorization**: RBAC or ABAC properly configured
- [ ] **Input Validation**: All user inputs validated and sanitized
- [ ] **Rate Limiting**: API rate limits configured
- [ ] **CORS**: CORS headers properly configured
- [ ] **Security Headers**: Helmet.js or equivalent enabled
- [ ] **SQL Injection**: Parameterized queries used
- [ ] **XSS Prevention**: Output encoding implemented
- [ ] **CSRF Protection**: CSRF tokens in place
- [ ] **Dependency Scanning**: No critical vulnerabilities (npm audit, Snyk)
- [ ] **Secret Rotation**: Secrets rotation policy defined

```typescript
// Security headers
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https:']
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

// Rate limiting
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});

app.use('/api', limiter);
```

### Performance

- [ ] **Load Testing**: Tested under expected load
- [ ] **Caching**: Redis or CDN caching configured
- [ ] **Database Indexes**: All frequently queried columns indexed
- [ ] **Connection Pooling**: Database connection pooling enabled
- [ ] **Static Assets**: Assets served via CDN
- [ ] **Compression**: Gzip/Brotli compression enabled
- [ ] **Code Splitting**: Frontend bundle optimized
- [ ] **Image Optimization**: Images compressed and lazy-loaded
- [ ] **Query Optimization**: Slow queries identified and optimized

```typescript
// Load testing with k6
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 }, // Ramp up to 100 users
    { duration: '5m', target: 100 }, // Stay at 100 users
    { duration: '2m', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
    http_req_failed: ['rate<0.01'],   // Error rate under 1%
  },
};

export default function () {
  const res = http.get('https://api.example.com/health');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
```

### Monitoring

- [ ] **Application Monitoring**: APM tool configured (Datadog, New Relic, Sentry)
- [ ] **Log Aggregation**: Centralized logging (ELK, Splunk, Datadog)
- [ ] **Error Tracking**: Sentry or equivalent configured
- [ ] **Metrics**: Key metrics tracked (CPU, memory, response time)
- [ ] **Alerts**: Critical alerts configured (downtime, errors, performance)
- [ ] **Uptime Monitoring**: External uptime monitor (Pingdom, UptimeRobot)
- [ ] **Health Checks**: `/health` endpoint implemented
- [ ] **Dashboards**: Grafana or equivalent dashboards created

```typescript
// Health check endpoint
app.get('/health', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    externalApi: await checkExternalApi()
  };
  
  const healthy = Object.values(checks).every(v => v);
  
  res.status(healthy ? 200 : 503).json({
    status: healthy ? 'healthy' : 'unhealthy',
    checks,
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION
  });
});

// Readiness check
app.get('/ready', async (req, res) => {
  const ready = await checkDatabaseConnection();
  res.status(ready ? 200 : 503).json({ ready });
});

// Liveness check
app.get('/live', (req, res) => {
  res.status(200).json({ alive: true });
});
```

### Reliability

- [ ] **Graceful Shutdown**: SIGTERM handled properly
- [ ] **Circuit Breakers**: External service failures handled
- [ ] **Retry Logic**: Exponential backoff for failures
- [ ] **Timeouts**: All network calls have timeouts
- [ ] **Idempotency**: POST/PUT operations idempotent
- [ ] **Database Migrations**: Migrations tested and reversible
- [ ] **Zero-Downtime Deploys**: Rolling updates configured
- [ ] **Auto-Scaling**: Horizontal scaling configured
- [ ] **Load Balancing**: Load balancer configured

```typescript
// Graceful shutdown
const server = app.listen(3000);

process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  
  server.close(() => {
    console.log('HTTP server closed');
    
    // Close database connections
    db.end().then(() => {
      console.log('Database connections closed');
      process.exit(0);
    });
  });
  
  // Force shutdown after 30 seconds
  setTimeout(() => {
    console.error('Forced shutdown');
    process.exit(1);
  }, 30000);
});

// Circuit breaker
import CircuitBreaker from 'opossum';

const breaker = new CircuitBreaker(externalApiCall, {
  timeout: 3000, // 3 seconds
  errorThresholdPercentage: 50,
  resetTimeout: 30000 // 30 seconds
});

breaker.on('open', () => {
  console.log('Circuit breaker opened');
});

breaker.on('halfOpen', () => {
  console.log('Circuit breaker half-open');
});
```

### Disaster Recovery

- [ ] **Backups**: Automated daily backups configured
- [ ] **Backup Testing**: Restore process tested monthly
- [ ] **Database Replication**: Read replicas configured
- [ ] **Disaster Recovery Plan**: Written and tested DR plan
- [ ] **Failover**: Automatic failover configured
- [ ] **Data Retention**: Retention policy documented
- [ ] **Incident Response**: Incident response plan documented

```bash
# Automated backup script
#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/backups"
DB_NAME="production_db"

# Create backup
pg_dump $DB_NAME > "$BACKUP_DIR/backup_$TIMESTAMP.sql"

# Compress
gzip "$BACKUP_DIR/backup_$TIMESTAMP.sql"

# Upload to S3
aws s3 cp "$BACKUP_DIR/backup_$TIMESTAMP.sql.gz" \
  s3://my-backups/db/ \
  --storage-class GLACIER

# Delete local backup
rm "$BACKUP_DIR/backup_$TIMESTAMP.sql.gz"

# Delete old backups (keep last 7 days)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

echo "Backup completed: $TIMESTAMP"
```

### Infrastructure

- [ ] **Infrastructure as Code**: Terraform/CloudFormation configured
- [ ] **CI/CD Pipeline**: Automated deployment pipeline
- [ ] **Container Orchestration**: Kubernetes/ECS configured
- [ ] **Environment Parity**: Dev/staging/prod environments identical
- [ ] **DNS**: DNS records configured with low TTL
- [ ] **CDN**: CloudFlare/CloudFront configured
- [ ] **SSL/TLS**: Certificates auto-renewing (Let's Encrypt)
- [ ] **Firewall**: WAF configured
- [ ] **DDoS Protection**: CloudFlare or AWS Shield enabled

```yaml
# Docker Compose for local development
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
    depends_on:
      - db
      - redis
  
  db:
    image: postgres:15
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: password
  
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### Documentation

- [ ] **API Documentation**: OpenAPI/Swagger docs generated
- [ ] **Runbooks**: Operational runbooks written
- [ ] **Architecture Diagrams**: System architecture documented
- [ ] **Incident Playbooks**: Incident response procedures documented
- [ ] **Deployment Guide**: Deployment process documented
- [ ] **Configuration Reference**: All env vars documented
- [ ] **Troubleshooting Guide**: Common issues documented

## Deployment Strategies

### Blue-Green Deployment

```yaml
# Blue environment (current production)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue
  template:
    metadata:
      labels:
        app: myapp
        version: blue
    spec:
      containers:
      - name: app
        image: myapp:v1.0.0

---
# Green environment (new version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: green
  template:
    metadata:
      labels:
        app: myapp
        version: green
    spec:
      containers:
      - name: app
        image: myapp:v1.1.0

---
# Service (switch traffic by updating selector)
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
    version: blue  # Change to green to switch traffic
  ports:
  - port: 80
    targetPort: 3000
```

### Canary Deployment

```yaml
# Main deployment (90% traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-stable
spec:
  replicas: 9
  selector:
    matchLabels:
      app: myapp
      track: stable

---
# Canary deployment (10% traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
      track: canary
```

## Monitoring Setup

### Application Metrics

```typescript
import * as Sentry from '@sentry/node';
import { PrometheusExporter } from '@opentelemetry/exporter-prometheus';

// Sentry for error tracking
Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1
});

// Prometheus metrics
const { endpoint } = PrometheusExporter.startServer({ port: 9464 });

// Custom metrics
import prometheus from 'prom-client';

const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

const activeConnections = new prometheus.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

const requestCounter = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});
```

### Log Aggregation

```typescript
import winston from 'winston';
import { LoggingWinston } from '@google-cloud/logging-winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    // Console for local development
    new winston.transports.Console(),
    
    // Google Cloud Logging for production
    new LoggingWinston({
      projectId: process.env.GCP_PROJECT_ID,
      keyFilename: process.env.GCP_KEY_FILE
    })
  ]
});

// Structured logging
logger.info('User action', {
  userId: '123',
  action: 'login',
  timestamp: new Date().toISOString(),
  ip: req.ip
});
```

## Incident Response

### Incident Severity Levels

| Level | Response Time | Examples |
|-------|---------------|----------|
| **P0 - Critical** | Immediate | Complete service outage |
| **P1 - High** | 1 hour | Major feature broken |
| **P2 - Medium** | 4 hours | Minor feature broken |
| **P3 - Low** | 1 business day | Cosmetic issues |

### Incident Response Template

```markdown
# Incident Report

**Incident ID**: INC-2024-001
**Severity**: P0
**Status**: Resolved
**Detected**: 2024-01-15 10:30 UTC
**Resolved**: 2024-01-15 11:45 UTC

## Summary
Brief description of the incident.

## Timeline
- 10:30 - Monitoring alert triggered
- 10:32 - Incident declared
- 10:45 - Root cause identified
- 11:30 - Fix deployed
- 11:45 - Incident resolved

## Impact
- Users affected: 10,000
- Duration: 75 minutes
- Revenue loss: $5,000

## Root Cause
Detailed explanation of what went wrong.

## Resolution
What was done to fix the issue.

## Action Items
- [ ] Add monitoring for X
- [ ] Improve documentation
- [ ] Conduct postmortem meeting
```

## Anti-Patterns

### ❌ No Health Checks

**Why it's wrong**: Cannot detect service issues.

**Do this instead**: Implement comprehensive health checks.

### ❌ Secrets in Code

**Why it's wrong**: Security vulnerability.

**Do this instead**: Use environment variables and secret managers.

### ❌ No Monitoring

**Why it's wrong**: Cannot diagnose issues.

**Do this instead**: Implement comprehensive monitoring and alerting.

### ❌ Manual Deployments

**Why it's wrong**: Error-prone and slow.

**Do this instead**: Automate deployments with CI/CD.

## Related Modules

- **SECURITY_CHECKLIST** - Security best practices
- **PERFORMANCE_OPTIMIZATION** - Performance tuning
- **TROUBLESHOOTING** - Debugging production issues
- **BACKEND_PATTERNS** - Error handling and resilience
