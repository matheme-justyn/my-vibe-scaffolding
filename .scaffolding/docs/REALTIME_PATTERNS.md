# REALTIME_PATTERNS

**Status**: Active | Domain: Feature  
**Related Modules**: API_DESIGN, BACKEND_PATTERNS, PERFORMANCE_OPTIMIZATION, DATABASE_SCHEMA

## Purpose

This module provides comprehensive guidance for implementing real-time communication patterns in applications. It covers WebSocket, Server-Sent Events (SSE), long polling, pub/sub architectures, and frameworks like Socket.IO. Use this module to build scalable, bidirectional communication systems for chat, notifications, live updates, collaborative editing, and real-time dashboards.

## When to Use This Module

Reference this module when:
- Building chat or messaging systems
- Implementing live notifications or alerts
- Creating collaborative editing features (like Google Docs)
- Building real-time dashboards with live data updates
- Implementing multiplayer games or interactive features
- Streaming data from servers to clients
- Migrating from polling-based to real-time architectures
- Troubleshooting connection stability or message delivery issues
- Scaling real-time systems horizontally

## Real-Time Communication Methods

### WebSocket

**Native WebSocket (Browser):**

```typescript
// Client-side WebSocket connection
class WebSocketClient {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectDelay = 1000; // Start with 1 second
  
  connect(url: string): void {
    this.ws = new WebSocket(url);
    
    this.ws.onopen = () => {
      console.log('WebSocket connected');
      this.reconnectAttempts = 0;
      this.reconnectDelay = 1000;
    };
    
    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.handleMessage(data);
    };
    
    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
    
    this.ws.onclose = () => {
      console.log('WebSocket disconnected');
      this.attemptReconnect(url);
    };
  }
  
  private attemptReconnect(url: string): void {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      console.log(`Reconnecting... (attempt ${this.reconnectAttempts})`);
      
      setTimeout(() => {
        this.connect(url);
      }, this.reconnectDelay);
      
      // Exponential backoff
      this.reconnectDelay = Math.min(this.reconnectDelay * 2, 30000);
    }
  }
  
  send(message: any): void {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(message));
    } else {
      console.error('WebSocket not connected');
    }
  }
  
  private handleMessage(data: any): void {
    // Handle different message types
    switch (data.type) {
      case 'notification':
        this.showNotification(data.payload);
        break;
      case 'chat':
        this.displayChatMessage(data.payload);
        break;
      default:
        console.log('Unknown message type:', data);
    }
  }
  
  disconnect(): void {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }
}

// Usage
const client = new WebSocketClient();
client.connect('wss://api.example.com/ws');

// Send message
client.send({
  type: 'chat',
  payload: { message: 'Hello!', userId: '123' }
});
```

**Node.js WebSocket Server:**

```typescript
import { WebSocketServer, WebSocket } from 'ws';
import { createServer } from 'http';
import jwt from 'jsonwebtoken';

const server = createServer();
const wss = new WebSocketServer({ server });

// Store active connections
const clients = new Map<string, WebSocket>();

wss.on('connection', async (ws: WebSocket, req) => {
  // Authenticate client
  const token = new URL(req.url!, `http://${req.headers.host}`).searchParams.get('token');
  
  if (!token) {
    ws.close(1008, 'Authentication required');
    return;
  }
  
  try {
    const user = jwt.verify(token, process.env.JWT_SECRET!) as { userId: string };
    const userId = user.userId;
    
    // Store connection
    clients.set(userId, ws);
    console.log(`User ${userId} connected`);
    
    // Send welcome message
    ws.send(JSON.stringify({
      type: 'system',
      payload: { message: 'Connected successfully' }
    }));
    
    // Handle incoming messages
    ws.on('message', (data: Buffer) => {
      try {
        const message = JSON.parse(data.toString());
        handleClientMessage(userId, message);
      } catch (error) {
        console.error('Invalid message format:', error);
      }
    });
    
    // Handle disconnection
    ws.on('close', () => {
      clients.delete(userId);
      console.log(`User ${userId} disconnected`);
    });
    
    // Handle errors
    ws.on('error', (error) => {
      console.error(`WebSocket error for user ${userId}:`, error);
    });
    
  } catch (error) {
    ws.close(1008, 'Invalid token');
  }
});

// Handle client messages
function handleClientMessage(userId: string, message: any): void {
  switch (message.type) {
    case 'chat':
      // Broadcast to all users
      broadcast({
        type: 'chat',
        payload: {
          userId,
          message: message.payload.message,
          timestamp: new Date()
        }
      });
      break;
      
    case 'direct_message':
      // Send to specific user
      const recipientWs = clients.get(message.payload.recipientId);
      if (recipientWs && recipientWs.readyState === WebSocket.OPEN) {
        recipientWs.send(JSON.stringify({
          type: 'direct_message',
          payload: {
            senderId: userId,
            message: message.payload.message,
            timestamp: new Date()
          }
        }));
      }
      break;
  }
}

// Broadcast to all connected clients
function broadcast(message: any): void {
  const messageStr = JSON.stringify(message);
  
  clients.forEach((ws, userId) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(messageStr);
    }
  });
}

// Send to specific user
function sendToUser(userId: string, message: any): void {
  const ws = clients.get(userId);
  
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(message));
  }
}

// Heartbeat to detect broken connections
setInterval(() => {
  clients.forEach((ws, userId) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.ping();
    } else {
      clients.delete(userId);
    }
  });
}, 30000); // Every 30 seconds

server.listen(3000, () => {
  console.log('WebSocket server running on port 3000');
});
```

### Server-Sent Events (SSE)

**SSE is ideal for one-way server-to-client streaming:**

```typescript
// Server-side (Express)
import express from 'express';

const app = express();

// SSE endpoint
app.get('/events', (req, res) => {
  // Set SSE headers
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.setHeader('Access-Control-Allow-Origin', '*');
  
  // Send initial connection message
  res.write(`data: ${JSON.stringify({ type: 'connected' })}\n\n`);
  
  // Store response object for this client
  const clientId = Date.now().toString();
  sseClients.set(clientId, res);
  
  // Handle client disconnect
  req.on('close', () => {
    sseClients.delete(clientId);
    console.log(`Client ${clientId} disconnected`);
  });
});

// Store active SSE connections
const sseClients = new Map<string, express.Response>();

// Send event to all SSE clients
function sendSSEEvent(event: string, data: any): void {
  const message = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
  
  sseClients.forEach((res, clientId) => {
    res.write(message);
  });
}

// Example: Send notifications
setInterval(() => {
  sendSSEEvent('notification', {
    message: 'Server update',
    timestamp: new Date()
  });
}, 10000); // Every 10 seconds

// Client-side
class SSEClient {
  private eventSource: EventSource | null = null;
  
  connect(url: string): void {
    this.eventSource = new EventSource(url);
    
    this.eventSource.onopen = () => {
      console.log('SSE connected');
    };
    
    // Handle generic messages
    this.eventSource.onmessage = (event) => {
      const data = JSON.parse(event.data);
      console.log('Received:', data);
    };
    
    // Handle custom events
    this.eventSource.addEventListener('notification', (event) => {
      const data = JSON.parse(event.data);
      this.showNotification(data);
    });
    
    this.eventSource.onerror = (error) => {
      console.error('SSE error:', error);
      // Browser automatically reconnects
    };
  }
  
  private showNotification(data: any): void {
    // Display notification to user
    console.log('Notification:', data.message);
  }
  
  disconnect(): void {
    if (this.eventSource) {
      this.eventSource.close();
      this.eventSource = null;
    }
  }
}

// Usage
const sseClient = new SSEClient();
sseClient.connect('http://localhost:3000/events');
```

### Socket.IO

**Socket.IO provides abstraction over WebSocket with fallback:**

```typescript
// Server-side
import { Server } from 'socket.io';
import { createServer } from 'http';
import express from 'express';

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: 'http://localhost:3000',
    methods: ['GET', 'POST']
  }
});

// Authentication middleware
io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  
  if (!token) {
    return next(new Error('Authentication required'));
  }
  
  try {
    const user = jwt.verify(token, process.env.JWT_SECRET!) as { userId: string };
    socket.data.userId = user.userId;
    next();
  } catch (error) {
    next(new Error('Invalid token'));
  }
});

// Handle connections
io.on('connection', (socket) => {
  const userId = socket.data.userId;
  console.log(`User ${userId} connected`);
  
  // Join user-specific room
  socket.join(`user:${userId}`);
  
  // Handle events
  socket.on('chat:message', (data) => {
    // Broadcast to all users in the same room
    io.to(data.roomId).emit('chat:message', {
      userId,
      message: data.message,
      timestamp: new Date()
    });
  });
  
  socket.on('chat:typing', (data) => {
    // Broadcast typing indicator
    socket.to(data.roomId).emit('chat:typing', { userId });
  });
  
  socket.on('join:room', (roomId) => {
    socket.join(roomId);
    socket.emit('room:joined', { roomId });
  });
  
  socket.on('leave:room', (roomId) => {
    socket.leave(roomId);
    socket.emit('room:left', { roomId });
  });
  
  socket.on('disconnect', () => {
    console.log(`User ${userId} disconnected`);
  });
});

// Send notification to specific user
function notifyUser(userId: string, notification: any): void {
  io.to(`user:${userId}`).emit('notification', notification);
}

// Broadcast to all connected clients
function broadcastToAll(event: string, data: any): void {
  io.emit(event, data);
}

server.listen(3000, () => {
  console.log('Socket.IO server running on port 3000');
});

// Client-side
import { io, Socket } from 'socket.io-client';

class SocketIOClient {
  private socket: Socket | null = null;
  
  connect(url: string, token: string): void {
    this.socket = io(url, {
      auth: { token },
      reconnection: true,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
      reconnectionAttempts: 5
    });
    
    this.socket.on('connect', () => {
      console.log('Connected to server');
    });
    
    this.socket.on('disconnect', (reason) => {
      console.log('Disconnected:', reason);
    });
    
    this.socket.on('connect_error', (error) => {
      console.error('Connection error:', error.message);
    });
    
    // Listen for events
    this.socket.on('chat:message', (data) => {
      this.displayMessage(data);
    });
    
    this.socket.on('notification', (data) => {
      this.showNotification(data);
    });
  }
  
  joinRoom(roomId: string): void {
    this.socket?.emit('join:room', roomId);
  }
  
  sendMessage(roomId: string, message: string): void {
    this.socket?.emit('chat:message', { roomId, message });
  }
  
  disconnect(): void {
    this.socket?.disconnect();
  }
  
  private displayMessage(data: any): void {
    console.log(`${data.userId}: ${data.message}`);
  }
  
  private showNotification(data: any): void {
    console.log('Notification:', data);
  }
}

// Usage
const client = new SocketIOClient();
client.connect('http://localhost:3000', 'your-jwt-token');
client.joinRoom('general');
client.sendMessage('general', 'Hello, everyone!');
```

## Pub/Sub Architecture

### Redis Pub/Sub for Horizontal Scaling

**Problem**: WebSocket connections are stateful. When scaling horizontally, a user might connect to Server A, but a message for them arrives at Server B.

**Solution**: Use Redis Pub/Sub to broadcast messages across all server instances.

```typescript
// server.ts
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';

const server = createServer();
const io = new SocketIOServer(server);

// Redis clients for pub/sub
const pubClient = createClient({ url: 'redis://localhost:6379' });
const subClient = pubClient.duplicate();

Promise.all([pubClient.connect(), subClient.connect()]).then(() => {
  // Use Redis adapter for Socket.IO
  io.adapter(createAdapter(pubClient, subClient));
  
  console.log('Redis adapter initialized');
});

io.on('connection', (socket) => {
  const userId = socket.data.userId;
  
  // Subscribe to user-specific channel
  socket.join(`user:${userId}`);
  
  socket.on('chat:message', async (data) => {
    // Publish message to Redis
    await pubClient.publish('chat:messages', JSON.stringify({
      roomId: data.roomId,
      userId,
      message: data.message,
      timestamp: new Date()
    }));
  });
});

// Subscribe to Redis channels
subClient.subscribe('chat:messages', (message) => {
  const data = JSON.parse(message);
  
  // Broadcast to all clients in the room
  io.to(data.roomId).emit('chat:message', data);
});

server.listen(3000);
```

## Presence and Typing Indicators

### Online/Offline Status

```typescript
// Server-side
const onlineUsers = new Map<string, Date>();

io.on('connection', (socket) => {
  const userId = socket.data.userId;
  
  // Mark user as online
  onlineUsers.set(userId, new Date());
  io.emit('user:online', { userId });
  
  // Update last seen timestamp periodically
  const heartbeatInterval = setInterval(() => {
    onlineUsers.set(userId, new Date());
  }, 30000);
  
  socket.on('disconnect', () => {
    clearInterval(heartbeatInterval);
    onlineUsers.delete(userId);
    io.emit('user:offline', { userId, lastSeen: new Date() });
  });
});

// Get online users
app.get('/api/users/online', (req, res) => {
  const online = Array.from(onlineUsers.keys());
  res.json({ users: online });
});

// Client-side
socket.on('user:online', (data) => {
  updateUserStatus(data.userId, 'online');
});

socket.on('user:offline', (data) => {
  updateUserStatus(data.userId, 'offline');
});
```

### Typing Indicators

```typescript
// Server-side
io.on('connection', (socket) => {
  socket.on('typing:start', (data) => {
    socket.to(data.roomId).emit('typing:user', {
      userId: socket.data.userId,
      isTyping: true
    });
  });
  
  socket.on('typing:stop', (data) => {
    socket.to(data.roomId).emit('typing:user', {
      userId: socket.data.userId,
      isTyping: false
    });
  });
});

// Client-side with debouncing
class TypingIndicator {
  private typingTimeout: NodeJS.Timeout | null = null;
  private isTyping = false;
  
  constructor(private socket: Socket, private roomId: string) {}
  
  onUserTyping(): void {
    if (!this.isTyping) {
      this.isTyping = true;
      this.socket.emit('typing:start', { roomId: this.roomId });
    }
    
    // Clear existing timeout
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout);
    }
    
    // Stop typing after 3 seconds of inactivity
    this.typingTimeout = setTimeout(() => {
      this.isTyping = false;
      this.socket.emit('typing:stop', { roomId: this.roomId });
    }, 3000);
  }
}

// Usage
const typingIndicator = new TypingIndicator(socket, 'general');

document.getElementById('messageInput')?.addEventListener('input', () => {
  typingIndicator.onUserTyping();
});
```

## Performance Optimization

### Message Batching

```typescript
class MessageBatcher {
  private queue: any[] = [];
  private flushTimeout: NodeJS.Timeout | null = null;
  private readonly maxBatchSize = 100;
  private readonly flushInterval = 100; // ms
  
  add(message: any): void {
    this.queue.push(message);
    
    if (this.queue.length >= this.maxBatchSize) {
      this.flush();
    } else {
      this.scheduleFlush();
    }
  }
  
  private scheduleFlush(): void {
    if (this.flushTimeout) return;
    
    this.flushTimeout = setTimeout(() => {
      this.flush();
    }, this.flushInterval);
  }
  
  private flush(): void {
    if (this.queue.length === 0) return;
    
    // Send batched messages
    this.sendBatch(this.queue);
    
    this.queue = [];
    this.flushTimeout = null;
  }
  
  private sendBatch(messages: any[]): void {
    io.emit('messages:batch', messages);
  }
}

// Usage
const batcher = new MessageBatcher();

io.on('connection', (socket) => {
  socket.on('chat:message', (data) => {
    batcher.add({
      userId: socket.data.userId,
      message: data.message,
      timestamp: new Date()
    });
  });
});
```

### Compression

```typescript
// Enable compression for Socket.IO
const io = new Server(server, {
  perMessageDeflate: {
    threshold: 1024, // Compress messages > 1KB
    zlibDeflateOptions: {
      chunkSize: 8 * 1024,
      memLevel: 7,
      level: 3
    }
  }
});

// WebSocket compression
const wss = new WebSocketServer({
  perMessageDeflate: {
    zlibDeflateOptions: {
      chunkSize: 1024,
      memLevel: 7,
      level: 3
    },
    threshold: 1024
  }
});
```

## Error Handling and Resilience

### Automatic Reconnection

```typescript
class ResilientWebSocket {
  private ws: WebSocket | null = null;
  private url: string;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = Infinity;
  private reconnectDelay = 1000;
  private messageQueue: any[] = [];
  
  constructor(url: string) {
    this.url = url;
    this.connect();
  }
  
  private connect(): void {
    this.ws = new WebSocket(this.url);
    
    this.ws.onopen = () => {
      console.log('Connected');
      this.reconnectAttempts = 0;
      this.reconnectDelay = 1000;
      this.flushQueue();
    };
    
    this.ws.onmessage = (event) => {
      this.handleMessage(JSON.parse(event.data));
    };
    
    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
    
    this.ws.onclose = () => {
      this.reconnect();
    };
  }
  
  private reconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error('Max reconnection attempts reached');
      return;
    }
    
    this.reconnectAttempts++;
    const delay = Math.min(
      this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1),
      30000
    );
    
    console.log(`Reconnecting in ${delay}ms...`);
    
    setTimeout(() => {
      this.connect();
    }, delay);
  }
  
  send(message: any): void {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(message));
    } else {
      // Queue message for later
      this.messageQueue.push(message);
    }
  }
  
  private flushQueue(): void {
    while (this.messageQueue.length > 0) {
      const message = this.messageQueue.shift();
      this.send(message);
    }
  }
  
  private handleMessage(data: any): void {
    // Handle received message
  }
}
```

## Testing Real-Time Systems

### Unit Tests

```typescript
import { describe, it, expect, vi } from 'vitest';
import { WebSocket } from 'ws';

describe('WebSocket Client', () => {
  it('should connect and receive messages', (done) => {
    const client = new WebSocketClient();
    
    client.onMessage = (data) => {
      expect(data.type).toBe('welcome');
      done();
    };
    
    client.connect('ws://localhost:3000');
  });
  
  it('should reconnect on disconnection', async () => {
    const client = new WebSocketClient();
    const reconnectSpy = vi.spyOn(client as any, 'attemptReconnect');
    
    client.connect('ws://localhost:3000');
    
    // Simulate disconnection
    client['ws']?.close();
    
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    expect(reconnectSpy).toHaveBeenCalled();
  });
});
```

### Integration Tests

```typescript
import { io as ioClient, Socket } from 'socket.io-client';
import { createServer } from './server';

describe('Socket.IO Integration', () => {
  let server: any;
  let client1: Socket;
  let client2: Socket;
  
  beforeAll((done) => {
    server = createServer();
    server.listen(() => {
      const port = server.address().port;
      
      client1 = ioClient(`http://localhost:${port}`, {
        auth: { token: 'user1-token' }
      });
      
      client2 = ioClient(`http://localhost:${port}`, {
        auth: { token: 'user2-token' }
      });
      
      Promise.all([
        new Promise(r => client1.on('connect', r)),
        new Promise(r => client2.on('connect', r))
      ]).then(() => done());
    });
  });
  
  afterAll(() => {
    client1.disconnect();
    client2.disconnect();
    server.close();
  });
  
  it('should broadcast messages to room members', (done) => {
    const roomId = 'test-room';
    
    client2.on('chat:message', (data) => {
      expect(data.message).toBe('Hello, room!');
      done();
    });
    
    client1.emit('join:room', roomId);
    client2.emit('join:room', roomId);
    
    setTimeout(() => {
      client1.emit('chat:message', {
        roomId,
        message: 'Hello, room!'
      });
    }, 100);
  });
});
```

## Anti-Patterns

### ❌ No Reconnection Logic

```typescript
// NEVER DO THIS
const ws = new WebSocket('ws://api.example.com');
ws.onclose = () => {
  console.log('Disconnected'); // No reconnection
};
```

**Why it's wrong**: Network issues cause permanent disconnection.

**Do this instead**: Implement exponential backoff reconnection.

### ❌ Storing State Only in Memory

```typescript
// NEVER DO THIS
const userSessions = new Map<string, WebSocket>();

// When server restarts, all sessions are lost
```

**Why it's wrong**: Server restarts or scaling breaks user sessions.

**Do this instead**: Use Redis or database to persist session state.

### ❌ No Message Acknowledgment

```typescript
// NEVER DO THIS
ws.send(JSON.stringify(message)); // Fire and forget
```

**Why it's wrong**: No guarantee message was delivered.

**Do this instead**: Implement message IDs and acknowledgment system.

### ❌ Sending Large Payloads

```typescript
// NEVER DO THIS
ws.send(JSON.stringify({ data: largeArray })); // 10MB payload
```

**Why it's wrong**: Blocks event loop, increases latency.

**Do this instead**: Paginate data or use compression.

### ❌ No Rate Limiting

```typescript
// NEVER DO THIS
socket.on('chat:message', (data) => {
  io.emit('chat:message', data); // No rate limit
});
```

**Why it's wrong**: Vulnerable to spam and DoS attacks.

**Do this instead**: Implement per-user rate limiting.

## Related Modules

- **API_DESIGN** - REST API fallback patterns
- **BACKEND_PATTERNS** - Server architecture
- **PERFORMANCE_OPTIMIZATION** - Scaling and optimization
- **DATABASE_SCHEMA** - Message persistence
- **AUTH_IMPLEMENTATION** - WebSocket authentication
- **PRODUCTION_READINESS** - Monitoring and observability
