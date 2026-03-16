# MICROSERVICES PATTERNS

**Status**: Active | **Domain**: Backend  
**Related Modules**: API_DESIGN, DATABASE_SCHEMA, PERFORMANCE_OPTIMIZATION

## Purpose

This module defines patterns and best practices for building microservices architectures. It covers service decomposition, communication patterns, data management, resilience, observability, and deployment strategies for distributed systems.

## When to Use This Module

- Designing microservices architecture from scratch
- Decomposing monolithic applications
- Implementing inter-service communication
- Designing distributed data management
- Implementing resilience and fault tolerance
- Setting up service discovery and load balancing
- Implementing distributed tracing and monitoring

---

## 1. Service Decomposition

### 1.1 Decomposition by Business Capability

```
✅ GOOD: Services aligned with business domains
- User Service (authentication, profiles)
- Product Service (catalog, inventory)
- Order Service (order processing, fulfillment)
- Payment Service (billing, transactions)
- Notification Service (emails, SMS, push)

❌ BAD: Technical decomposition
- Database Service
- UI Service
- API Gateway Service
- Logging Service
```

### 1.2 Decomposition by Subdomain (DDD)

```
✅ Domain-Driven Design approach

Core Domains (critical business value):
- Order Management
- Payment Processing

Supporting Domains (necessary but not differentiating):
- Notification
- Shipping

Generic Domains (commodity):
- Authentication
- Logging
```

### 1.3 Service Size Guidelines

```
✅ GOOD: Right-sized services
- Small enough: Team of 2-3 developers can maintain
- Deployable independently
- Single responsibility
- Can be rewritten in 2-4 weeks

❌ BAD: Wrong-sized services
- Nanoservices (too small, high overhead)
- Distributed monoliths (tight coupling)
```

---

## 2. Communication Patterns

### 2.1 Synchronous Communication (REST/gRPC)

```typescript
// ✅ GOOD: REST API with proper error handling
// Order Service calling Payment Service
async function createOrder(orderData) {
  try {
    const paymentResponse = await fetch('http://payment-service/api/payments', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        amount: orderData.total,
        currency: 'USD',
        orderId: orderData.id
      }),
      timeout: 5000  // 5-second timeout
    });

    if (!paymentResponse.ok) {
      throw new Error(`Payment failed: ${paymentResponse.status}`);
    }

    const payment = await paymentResponse.json();
    return { orderId: orderData.id, paymentId: payment.id };
  } catch (error) {
    // Implement circuit breaker, fallback, or compensation
    throw new Error(`Order creation failed: ${error.message}`);
  }
}
```

**gRPC Alternative (for high-performance internal communication)**:

```protobuf
// payment.proto
syntax = "proto3";

service PaymentService {
  rpc ProcessPayment(PaymentRequest) returns (PaymentResponse);
}

message PaymentRequest {
  string order_id = 1;
  double amount = 2;
  string currency = 3;
}

message PaymentResponse {
  string payment_id = 1;
  string status = 2;
}
```

### 2.2 Asynchronous Communication (Message Queue)

```typescript
// ✅ GOOD: Event-driven architecture with RabbitMQ
// Order Service publishes OrderCreated event
import amqp from 'amqplib';

async function publishOrderCreated(order) {
  const connection = await amqp.connect('amqp://localhost');
  const channel = await connection.createChannel();
  
  const exchange = 'orders';
  await channel.assertExchange(exchange, 'topic', { durable: true });
  
  const event = {
    type: 'OrderCreated',
    timestamp: new Date().toISOString(),
    data: {
      orderId: order.id,
      userId: order.userId,
      total: order.total,
      items: order.items
    }
  };
  
  channel.publish(
    exchange,
    'order.created',
    Buffer.from(JSON.stringify(event)),
    { persistent: true }
  );
  
  console.log('Published OrderCreated event:', event);
}

// Payment Service subscribes to OrderCreated
async function subscribeToOrderCreated() {
  const connection = await amqp.connect('amqp://localhost');
  const channel = await connection.createChannel();
  
  const exchange = 'orders';
  const queue = 'payment-service-orders';
  
  await channel.assertExchange(exchange, 'topic', { durable: true });
  await channel.assertQueue(queue, { durable: true });
  await channel.bindQueue(queue, exchange, 'order.created');
  
  channel.consume(queue, async (msg) => {
    if (msg) {
      const event = JSON.parse(msg.content.toString());
      console.log('Received OrderCreated event:', event);
      
      try {
        await processPayment(event.data);
        channel.ack(msg);  // Acknowledge successful processing
      } catch (error) {
        console.error('Payment processing failed:', error);
        channel.nack(msg, false, true);  // Requeue for retry
      }
    }
  });
}
```

### 2.3 Saga Pattern (Distributed Transactions)

```typescript
// ✅ Choreography-based Saga
// Order Service
async function createOrder(orderData) {
  const order = await db.orders.create({ ...orderData, status: 'PENDING' });
  await publishEvent('OrderCreated', order);
  return order;
}

// Payment Service
async function handleOrderCreated(event) {
  try {
    const payment = await processPayment(event.data);
    await publishEvent('PaymentCompleted', { orderId: event.data.orderId, paymentId: payment.id });
  } catch (error) {
    await publishEvent('PaymentFailed', { orderId: event.data.orderId, reason: error.message });
  }
}

// Inventory Service
async function handlePaymentCompleted(event) {
  try {
    await reserveInventory(event.data.orderId);
    await publishEvent('InventoryReserved', event.data);
  } catch (error) {
    await publishEvent('InventoryReservationFailed', event.data);
    // Trigger compensation: refund payment
  }
}

// Order Service (compensation)
async function handleInventoryReservationFailed(event) {
  await db.orders.update(event.data.orderId, { status: 'FAILED' });
  await publishEvent('OrderCancelled', event.data);
}
```

---

## 3. Data Management

### 3.1 Database per Service Pattern

```
✅ GOOD: Each service owns its data

┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Order Service  │     │ Payment Service │     │ Inventory Svc   │
│                 │     │                 │     │                 │
│  ┌───────────┐  │     │  ┌───────────┐  │     │  ┌───────────┐  │
│  │  Orders   │  │     │  │ Payments  │  │     │  │Inventory  │  │
│  │    DB     │  │     │  │    DB     │  │     │  │    DB     │  │
│  └───────────┘  │     │  └───────────┘  │     │  └───────────┘  │
└─────────────────┘     └─────────────────┘     └─────────────────┘

Benefits:
- Independent scaling
- Technology diversity
- Isolation (failure, security)
- Independent deployment
```

### 3.2 CQRS (Command Query Responsibility Segregation)

```typescript
// ✅ Separate read and write models

// Write Model (Command Side) - Optimized for writes
class OrderCommandService {
  async createOrder(command: CreateOrderCommand) {
    const order = await this.orderRepository.save({
      userId: command.userId,
      items: command.items,
      status: 'PENDING'
    });
    
    await this.eventBus.publish('OrderCreated', order);
    return order.id;
  }
}

// Read Model (Query Side) - Optimized for reads
class OrderQueryService {
  async getOrderDetails(orderId: string) {
    // Read from denormalized view optimized for queries
    return await this.orderReadRepository.findById(orderId);
  }
  
  async getUserOrders(userId: string) {
    // Read from materialized view with joined data
    return await this.orderReadRepository.findByUserId(userId);
  }
}

// Event Handler to update read model
class OrderProjection {
  async handleOrderCreated(event: OrderCreatedEvent) {
    await this.orderReadRepository.create({
      id: event.orderId,
      userId: event.userId,
      customerName: event.customerName,  // Denormalized from User Service
      total: event.total,
      status: 'PENDING'
    });
  }
}
```

### 3.3 Event Sourcing

```typescript
// ✅ Store events instead of current state
interface OrderEvent {
  eventId: string;
  aggregateId: string;  // Order ID
  eventType: string;
  timestamp: Date;
  data: any;
}

class OrderEventStore {
  async appendEvent(event: OrderEvent) {
    await db.events.insert(event);
    await this.eventBus.publish(event);
  }
  
  async getEvents(orderId: string): Promise<OrderEvent[]> {
    return await db.events.find({ aggregateId: orderId }).sort({ timestamp: 1 });
  }
  
  // Rebuild current state from events
  async getCurrentState(orderId: string): Promise<Order> {
    const events = await this.getEvents(orderId);
    return events.reduce((order, event) => {
      return this.applyEvent(order, event);
    }, new Order());
  }
  
  private applyEvent(order: Order, event: OrderEvent): Order {
    switch (event.eventType) {
      case 'OrderCreated':
        return { ...order, id: event.data.id, status: 'PENDING' };
      case 'PaymentCompleted':
        return { ...order, status: 'PAID' };
      case 'OrderShipped':
        return { ...order, status: 'SHIPPED' };
      default:
        return order;
    }
  }
}
```

---

## 4. Resilience Patterns

### 4.1 Circuit Breaker

```typescript
// ✅ Prevent cascading failures
class CircuitBreaker {
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';
  private failureCount = 0;
  private lastFailureTime?: Date;
  private readonly threshold = 5;
  private readonly timeout = 60000; // 60 seconds
  
  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'OPEN') {
      if (Date.now() - this.lastFailureTime!.getTime() > this.timeout) {
        this.state = 'HALF_OPEN';
      } else {
        throw new Error('Circuit breaker is OPEN');
      }
    }
    
    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  private onSuccess() {
    this.failureCount = 0;
    this.state = 'CLOSED';
  }
  
  private onFailure() {
    this.failureCount++;
    this.lastFailureTime = new Date();
    
    if (this.failureCount >= this.threshold) {
      this.state = 'OPEN';
      console.log('Circuit breaker opened');
    }
  }
}

// Usage
const paymentServiceBreaker = new CircuitBreaker();

async function callPaymentService(data) {
  return await paymentServiceBreaker.execute(async () => {
    return await fetch('http://payment-service/api/process', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  });
}
```

### 4.2 Retry with Exponential Backoff

```typescript
// ✅ Retry failed requests with increasing delays
async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries = 3,
  baseDelay = 1000
): Promise<T> {
  let lastError: Error;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;
      
      if (attempt < maxRetries) {
        const delay = baseDelay * Math.pow(2, attempt);  // Exponential backoff
        const jitter = Math.random() * 1000;  // Add jitter to prevent thundering herd
        
        console.log(`Retry attempt ${attempt + 1} after ${delay + jitter}ms`);
        await new Promise(resolve => setTimeout(resolve, delay + jitter));
      }
    }
  }
  
  throw lastError!;
}

// Usage
const result = await retryWithBackoff(() =>
  fetch('http://payment-service/api/process', { method: 'POST', body: data })
);
```

### 4.3 Bulkhead Pattern

```typescript
// ✅ Isolate resources to prevent total system failure
class BulkheadExecutor {
  private readonly maxConcurrent: number;
  private currentExecuting = 0;
  private readonly queue: Array<() => void> = [];
  
  constructor(maxConcurrent: number) {
    this.maxConcurrent = maxConcurrent;
  }
  
  async execute<T>(fn: () => Promise<T>): Promise<T> {
    while (this.currentExecuting >= this.maxConcurrent) {
      await new Promise(resolve => this.queue.push(resolve));
    }
    
    this.currentExecuting++;
    
    try {
      return await fn();
    } finally {
      this.currentExecuting--;
      const next = this.queue.shift();
      if (next) next();
    }
  }
}

// Separate thread pools for different services
const paymentBulkhead = new BulkheadExecutor(10);  // Max 10 concurrent payment calls
const inventoryBulkhead = new BulkheadExecutor(20);  // Max 20 concurrent inventory calls

// If payment service is slow, inventory calls aren't blocked
await paymentBulkhead.execute(() => callPaymentService());
await inventoryBulkhead.execute(() => callInventoryService());
```

### 4.4 Timeout Pattern

```typescript
// ✅ Always set timeouts for external calls
async function fetchWithTimeout(url: string, options: RequestInit = {}, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    return response;
  } catch (error) {
    if (error.name === 'AbortError') {
      throw new Error(`Request timeout after ${timeout}ms`);
    }
    throw error;
  } finally {
    clearTimeout(timeoutId);
  }
}
```

---

## 5. Service Discovery

### 5.1 Client-Side Discovery (Eureka, Consul)

```typescript
// ✅ Service registers itself on startup
import Consul from 'consul';

class ServiceRegistry {
  private consul = new Consul();
  
  async register() {
    const serviceId = `${process.env.SERVICE_NAME}-${process.env.INSTANCE_ID}`;
    
    await this.consul.agent.service.register({
      id: serviceId,
      name: process.env.SERVICE_NAME,
      address: process.env.SERVICE_HOST,
      port: parseInt(process.env.SERVICE_PORT),
      check: {
        http: `http://${process.env.SERVICE_HOST}:${process.env.SERVICE_PORT}/health`,
        interval: '10s',
        timeout: '5s'
      }
    });
    
    console.log(`Service registered: ${serviceId}`);
  }
  
  async discover(serviceName: string) {
    const result = await this.consul.health.service({
      service: serviceName,
      passing: true  // Only healthy instances
    });
    
    return result.map(entry => ({
      host: entry.Service.Address,
      port: entry.Service.Port
    }));
  }
  
  async deregister() {
    await this.consul.agent.service.deregister(
      `${process.env.SERVICE_NAME}-${process.env.INSTANCE_ID}`
    );
  }
}
```

### 5.2 Server-Side Discovery (Kubernetes)

```yaml
# ✅ Kubernetes Service provides discovery and load balancing
apiVersion: v1
kind: Service
metadata:
  name: payment-service
spec:
  selector:
    app: payment
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP  # Internal load balancer

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: payment
  template:
    metadata:
      labels:
        app: payment
    spec:
      containers:
      - name: payment
        image: payment-service:1.0.0
        ports:
        - containerPort: 8080
```

---

## 6. API Gateway Pattern

```typescript
// ✅ Single entry point for clients
import express from 'express';
import proxy from 'express-http-proxy';

const app = express();

// Authentication middleware
app.use(async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  
  try {
    const user = await verifyToken(token);
    req.user = user;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

// Rate limiting
const rateLimit = require('express-rate-limit');
app.use(rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 100  // Max 100 requests per window
}));

// Route to services
app.use('/api/users', proxy('http://user-service:8080'));
app.use('/api/orders', proxy('http://order-service:8080'));
app.use('/api/payments', proxy('http://payment-service:8080'));

// Request aggregation (Backend for Frontend pattern)
app.get('/api/dashboard', async (req, res) => {
  const [user, orders, notifications] = await Promise.all([
    fetch(`http://user-service/users/${req.user.id}`),
    fetch(`http://order-service/users/${req.user.id}/orders`),
    fetch(`http://notification-service/users/${req.user.id}/notifications`)
  ]);
  
  res.json({
    user: await user.json(),
    orders: await orders.json(),
    notifications: await notifications.json()
  });
});

app.listen(3000);
```

---

## 7. Observability

### 7.1 Distributed Tracing (OpenTelemetry)

```typescript
// ✅ Trace requests across services
import { trace, context } from '@opentelemetry/api';

const tracer = trace.getTracer('order-service');

async function createOrder(orderData) {
  const span = tracer.startSpan('createOrder');
  
  try {
    // Propagate trace context to downstream services
    const ctx = trace.setSpan(context.active(), span);
    
    const order = await context.with(ctx, async () => {
      span.addEvent('Saving order to database');
      const savedOrder = await db.orders.create(orderData);
      
      span.addEvent('Calling payment service');
      const payment = await callPaymentService(savedOrder);
      
      return savedOrder;
    });
    
    span.setStatus({ code: SpanStatusCode.OK });
    return order;
  } catch (error) {
    span.recordException(error);
    span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
    throw error;
  } finally {
    span.end();
  }
}
```

### 7.2 Health Checks

```typescript
// ✅ Expose health endpoints
app.get('/health', async (req, res) => {
  const health = {
    uptime: process.uptime(),
    timestamp: Date.now(),
    status: 'OK',
    checks: {}
  };
  
  // Check database
  try {
    await db.query('SELECT 1');
    health.checks.database = 'OK';
  } catch (error) {
    health.checks.database = 'FAIL';
    health.status = 'DEGRADED';
  }
  
  // Check message queue
  try {
    await messageQueue.ping();
    health.checks.messageQueue = 'OK';
  } catch (error) {
    health.checks.messageQueue = 'FAIL';
    health.status = 'DEGRADED';
  }
  
  const statusCode = health.status === 'OK' ? 200 : 503;
  res.status(statusCode).json(health);
});

// Readiness probe (can accept traffic?)
app.get('/ready', async (req, res) => {
  const isReady = await checkDependencies();
  res.status(isReady ? 200 : 503).json({ ready: isReady });
});

// Liveness probe (is process alive?)
app.get('/live', (req, res) => {
  res.status(200).json({ alive: true });
});
```

### 7.3 Structured Logging

```typescript
// ✅ Consistent log format across services
import winston from 'winston';

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  defaultMeta: {
    service: process.env.SERVICE_NAME,
    version: process.env.SERVICE_VERSION
  },
  transports: [
    new winston.transports.Console()
  ]
});

// Log with trace context
logger.info('Order created', {
  orderId: order.id,
  userId: order.userId,
  traceId: span.spanContext().traceId,
  spanId: span.spanContext().spanId
});
```

---

## 8. Deployment Patterns

### 8.1 Blue-Green Deployment

```yaml
# ✅ Zero-downtime deployment
# Blue (current version)
apiVersion: v1
kind: Service
metadata:
  name: order-service
spec:
  selector:
    app: order
    version: blue  # Route to blue version
  ports:
    - port: 80

---
# Green (new version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: order
      version: green
  template:
    metadata:
      labels:
        app: order
        version: green
    spec:
      containers:
      - name: order
        image: order-service:2.0.0

# After validation, switch traffic:
# kubectl patch service order-service -p '{"spec":{"selector":{"version":"green"}}}'
```

### 8.2 Canary Deployment

```yaml
# ✅ Gradual rollout to subset of users
apiVersion: v1
kind: Service
metadata:
  name: order-service
spec:
  selector:
    app: order
  ports:
    - port: 80

---
# Stable version (90% traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service-stable
spec:
  replicas: 9
  selector:
    matchLabels:
      app: order
      track: stable

---
# Canary version (10% traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: order
      track: canary
  template:
    spec:
      containers:
      - name: order
        image: order-service:2.0.0
```

---

## Anti-Patterns

### ❌ Distributed Monolith
Services tightly coupled through synchronous calls and shared databases.

**Solution**: Use events, database per service, and loose coupling.

### ❌ Nanoservices
Too many tiny services (one per function).

**Solution**: Group related functionality into bounded contexts.

### ❌ Shared Database
Multiple services accessing the same database tables.

**Solution**: Database per service pattern.

### ❌ Chatty Services
Excessive inter-service communication.

**Solution**: API gateway, BFF pattern, CQRS.

### ❌ No Observability
Can't trace requests across services.

**Solution**: Distributed tracing, structured logging, metrics.

---

## Related Modules

- **API_DESIGN** - API design for service interfaces
- **DATABASE_SCHEMA** - Data management strategies
- **PERFORMANCE_OPTIMIZATION** - Caching and optimization in distributed systems

---

## Resources

**Books**:
- Building Microservices (Sam Newman)
- Microservices Patterns (Chris Richardson)

**Frameworks**:
- Spring Boot (Java)
- NestJS (Node.js)
- Go Kit (Go)

**Tools**:
- Kubernetes: Container orchestration
- Istio: Service mesh
- Jaeger: Distributed tracing
- Prometheus: Metrics and monitoring
