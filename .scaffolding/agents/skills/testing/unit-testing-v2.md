---
name: unit-testing
version: 2.0.0
description: Unit testing with Iron Laws enforcement - Jest/Vitest patterns, test structure, mocking strategies, assertions, AAA pattern, test organization for frontend and backend code.
origin: ECC-derived (testing expertise)
adapted_for: OpenCode
transformation: Superpowers Iron Laws integration
---

# Unit Testing v2.0

## Iron Laws (Superpowers Style)

### 1. NO TESTING PRIVATE METHODS (TEST PUBLIC API ONLY)

**❌ BAD**:
```typescript
// Testing private methods directly
class UserService {
  private validateEmail(email: string): boolean {
    return /\S+@\S+\.\S+/.test(email);
  }
  
  private hashPassword(password: string): string {
    return bcrypt.hashSync(password, 10);
  }
  
  public async createUser(email: string, password: string) {
    if (!this.validateEmail(email)) throw new Error('Invalid email');
    const hashedPassword = this.hashPassword(password);
    return await db.users.create({ email, password: hashedPassword });
  }
}

// ❌ BAD TEST: Accessing private methods
test('validateEmail returns true for valid email', () => {
  const service = new UserService();
  // @ts-ignore - Accessing private method
  expect(service.validateEmail('test@example.com')).toBe(true);
});

test('hashPassword returns hashed string', () => {
  const service = new UserService();
  // @ts-ignore - Testing implementation detail
  const hash = service.hashPassword('password123');
  expect(hash).toMatch(/^\$2[aby]\$/);
});
```

**✅ GOOD**:
```typescript
// Test through public API
class UserService {
  private validateEmail(email: string): boolean {
    return /\S+@\S+\.\S+/.test(email);
  }
  
  private hashPassword(password: string): string {
    return bcrypt.hashSync(password, 10);
  }
  
  public async createUser(email: string, password: string) {
    if (!this.validateEmail(email)) throw new Error('Invalid email');
    const hashedPassword = this.hashPassword(password);
    return await db.users.create({ email, password: hashedPassword });
  }
}

// ✅ GOOD TEST: Test public behavior
test('createUser succeeds with valid email', async () => {
  const service = new UserService();
  const user = await service.createUser('test@example.com', 'password123');
  
  expect(user.email).toBe('test@example.com');
  expect(user.password).not.toBe('password123'); // Hashed
  expect(user.password).toMatch(/^\$2[aby]\$/); // bcrypt format
});

test('createUser throws error with invalid email', async () => {
  const service = new UserService();
  
  await expect(
    service.createUser('invalid-email', 'password123')
  ).rejects.toThrow('Invalid email');
});

test('createUser stores hashed password in database', async () => {
  const service = new UserService();
  const user = await service.createUser('test@example.com', 'password123');
  
  // Verify password is hashed (not plaintext)
  const isValidPassword = await bcrypt.compare('password123', user.password);
  expect(isValidPassword).toBe(true);
});
```

**Violation Handling**: Rewrite tests to call public methods only, verify behavior through observable outcomes

**No Excuses**:
- ❌ "I need to test this helper function"
- ❌ "The private method is complex"
- ❌ "It's easier to test directly"

**Enforcement**: Code review, avoid @ts-ignore, test only exported functions

---

### 2. NO MOCKING WHAT YOU DON'T OWN (TEST REAL DEPENDENCIES)

**❌ BAD**:
```typescript
// Mocking third-party library internals
test('Stripe payment succeeds', async () => {
  const stripeMock = {
    charges: {
      create: jest.fn().mockResolvedValue({ 
        id: 'ch_123', 
        status: 'succeeded' 
      })
    }
  };
  
  const paymentService = new PaymentService(stripeMock);
  const result = await paymentService.charge(100);
  expect(result.status).toBe('succeeded');
  // Test passes but doesn't verify actual Stripe integration
});

// Mocking Node.js built-ins
jest.mock('fs', () => ({
  readFileSync: jest.fn().mockReturnValue('mocked content')
}));

test('Read config file', () => {
  const config = loadConfig();
  expect(config).toBeDefined();
  // Doesn't test real file reading
});

// Mocking database client
jest.mock('pg', () => ({
  Client: jest.fn().mockImplementation(() => ({
    connect: jest.fn(),
    query: jest.fn().mockResolvedValue({ rows: [{ id: 1 }] })
  }))
}));
```

**✅ GOOD**:
```typescript
// Wrap third-party library in your own interface
interface PaymentGateway {
  charge(amount: number, token: string): Promise<ChargeResult>;
}

class StripeGateway implements PaymentGateway {
  constructor(private stripe: Stripe) {}
  
  async charge(amount: number, token: string): Promise<ChargeResult> {
    const charge = await this.stripe.charges.create({
      amount,
      currency: 'usd',
      source: token,
    });
    return { id: charge.id, status: charge.status };
  }
}

class PaymentService {
  constructor(private gateway: PaymentGateway) {}
  
  async processPayment(amount: number, token: string) {
    return await this.gateway.charge(amount, token);
  }
}

// ✅ Test with mock of YOUR interface
class MockPaymentGateway implements PaymentGateway {
  async charge(amount: number, token: string): Promise<ChargeResult> {
    return { id: 'mock_charge', status: 'succeeded' };
  }
}

test('PaymentService processes payment through gateway', async () => {
  const mockGateway = new MockPaymentGateway();
  const service = new PaymentService(mockGateway);
  
  const result = await service.processPayment(100, 'tok_visa');
  expect(result.status).toBe('succeeded');
});

// ✅ Integration test with real library (test container)
test('StripeGateway charges customer', async () => {
  const stripe = new Stripe(process.env.STRIPE_TEST_KEY);
  const gateway = new StripeGateway(stripe);
  
  const result = await gateway.charge(100, 'tok_visa'); // Stripe test token
  expect(result.status).toBe('succeeded');
});

// ✅ Use in-memory database for testing
import { createTestDatabase } from './test-helpers';

test('UserRepository creates user', async () => {
  const db = await createTestDatabase(); // Real SQLite in-memory
  const repo = new UserRepository(db);
  
  const user = await repo.create({ 
    email: 'test@example.com', 
    password: 'hashed' 
  });
  
  expect(user.id).toBeDefined();
  expect(user.email).toBe('test@example.com');
});
```

**Violation Handling**: Create wrapper interfaces around third-party code, mock YOUR interfaces only

**No Excuses**:
- ❌ "It's too slow to use the real library"
- ❌ "I don't have test credentials"
- ❌ "Mocking is simpler"

**Enforcement**: Integration tests with real dependencies, test containers (Testcontainers), code review

---

### 3. NO ASSERTION ROULETTE (ONE CONCEPT PER TEST)

**❌ BAD**:
```typescript
// Multiple unrelated assertions
test('User CRUD operations', async () => {
  // Create
  const user = await userService.create({ 
    email: 'test@example.com', 
    password: 'password123' 
  });
  expect(user.id).toBeDefined();
  expect(user.email).toBe('test@example.com');
  
  // Update
  const updated = await userService.update(user.id, { name: 'John' });
  expect(updated.name).toBe('John');
  expect(updated.email).toBe('test@example.com');
  
  // List
  const users = await userService.list();
  expect(users.length).toBeGreaterThan(0);
  
  // Delete
  await userService.delete(user.id);
  const deleted = await userService.findById(user.id);
  expect(deleted).toBeNull();
  
  // Which assertion failed? Which operation broke?
});

// Too many assertions (testing multiple concepts)
test('Login validation', async () => {
  await expect(login('', 'password')).rejects.toThrow('Email required');
  await expect(login('invalid', 'password')).rejects.toThrow('Invalid email');
  await expect(login('test@example.com', '')).rejects.toThrow('Password required');
  await expect(login('test@example.com', '123')).rejects.toThrow('Password too short');
  // 4 different validation rules in one test
});
```

**✅ GOOD**:
```typescript
// One concept per test
describe('UserService', () => {
  test('creates user with valid data', async () => {
    const user = await userService.create({ 
      email: 'test@example.com', 
      password: 'password123' 
    });
    
    expect(user.id).toBeDefined();
    expect(user.email).toBe('test@example.com');
  });
  
  test('updates user name', async () => {
    const user = await createTestUser();
    
    const updated = await userService.update(user.id, { name: 'John' });
    
    expect(updated.name).toBe('John');
    expect(updated.email).toBe(user.email); // Email unchanged
  });
  
  test('lists all users', async () => {
    await createTestUser({ email: 'user1@example.com' });
    await createTestUser({ email: 'user2@example.com' });
    
    const users = await userService.list();
    
    expect(users.length).toBe(2);
  });
  
  test('deletes user by id', async () => {
    const user = await createTestUser();
    
    await userService.delete(user.id);
    
    const deleted = await userService.findById(user.id);
    expect(deleted).toBeNull();
  });
});

// Separate test for each validation rule
describe('Login validation', () => {
  test('throws error when email is empty', async () => {
    await expect(
      login('', 'password123')
    ).rejects.toThrow('Email required');
  });
  
  test('throws error when email is invalid format', async () => {
    await expect(
      login('invalid-email', 'password123')
    ).rejects.toThrow('Invalid email');
  });
  
  test('throws error when password is empty', async () => {
    await expect(
      login('test@example.com', '')
    ).rejects.toThrow('Password required');
  });
  
  test('throws error when password is too short', async () => {
    await expect(
      login('test@example.com', '123')
    ).rejects.toThrow('Password too short');
  });
});
```

**Violation Handling**: Split multi-concept tests into focused tests, one assertion per test (or related assertions)

**No Excuses**:
- ❌ "It's testing the same feature"
- ❌ "More tests mean slower execution"
- ❌ "Setup is expensive"

**Enforcement**: Max 3 assertions per test, code review, test naming conventions

---

### 4. NO TEST INTERDEPENDENCE (ISOLATED TESTS ONLY)

**❌ BAD**:
```typescript
// Tests depend on execution order
describe('Shopping cart', () => {
  let cart: Cart;
  
  test('1. Create cart', () => {
    cart = new Cart();
    expect(cart.items).toHaveLength(0);
  });
  
  test('2. Add item to cart', () => {
    // Depends on cart from previous test
    cart.addItem({ id: 1, name: 'Product', price: 10 });
    expect(cart.items).toHaveLength(1);
  });
  
  test('3. Calculate total', () => {
    // Depends on cart from previous tests
    expect(cart.getTotal()).toBe(10);
  });
  
  test('4. Remove item from cart', () => {
    // Depends on cart state
    cart.removeItem(1);
    expect(cart.items).toHaveLength(0);
  });
});

// Shared mutable state
const testUsers = [
  { id: 1, name: 'Alice' },
  { id: 2, name: 'Bob' }
];

test('Add user', () => {
  testUsers.push({ id: 3, name: 'Charlie' });
  expect(testUsers).toHaveLength(3);
});

test('List users', () => {
  // Depends on previous test running first
  expect(testUsers).toHaveLength(3);
});
```

**✅ GOOD**:
```typescript
// Each test is independent
describe('Shopping cart', () => {
  test('new cart is empty', () => {
    const cart = new Cart();
    expect(cart.items).toHaveLength(0);
  });
  
  test('adding item increases cart size', () => {
    const cart = new Cart();
    
    cart.addItem({ id: 1, name: 'Product', price: 10 });
    
    expect(cart.items).toHaveLength(1);
  });
  
  test('calculates total of items in cart', () => {
    const cart = new Cart();
    cart.addItem({ id: 1, name: 'Product 1', price: 10 });
    cart.addItem({ id: 2, name: 'Product 2', price: 20 });
    
    const total = cart.getTotal();
    
    expect(total).toBe(30);
  });
  
  test('removing item decreases cart size', () => {
    const cart = new Cart();
    cart.addItem({ id: 1, name: 'Product', price: 10 });
    
    cart.removeItem(1);
    
    expect(cart.items).toHaveLength(0);
  });
});

// Use beforeEach for fresh state
describe('User service', () => {
  let userService: UserService;
  
  beforeEach(() => {
    userService = new UserService();
  });
  
  test('creates user', async () => {
    const user = await userService.create({ email: 'test@example.com' });
    expect(user.id).toBeDefined();
  });
  
  test('finds user by email', async () => {
    await userService.create({ email: 'test@example.com' });
    
    const found = await userService.findByEmail('test@example.com');
    
    expect(found).toBeDefined();
  });
});

// Factory functions for test data
function createTestCart(items: CartItem[] = []): Cart {
  const cart = new Cart();
  items.forEach(item => cart.addItem(item));
  return cart;
}

test('cart total with multiple items', () => {
  const cart = createTestCart([
    { id: 1, name: 'A', price: 10 },
    { id: 2, name: 'B', price: 20 }
  ]);
  
  expect(cart.getTotal()).toBe(30);
});
```

**Violation Handling**: Remove shared state, use beforeEach for setup, create fresh instances per test

**No Excuses**:
- ❌ "Tests are faster with shared state"
- ❌ "It's the same user journey"
- ❌ "Setup is expensive"

**Enforcement**: Run tests in random order, parallel execution, test isolation checks

---

### 5. NO MISSING EDGE CASES (BOUNDARY CONDITIONS REQUIRED)

**❌ BAD**:
```typescript
// Only testing happy path
test('divide returns correct result', () => {
  expect(divide(10, 2)).toBe(5);
});

// Missing boundary conditions
test('validate age', () => {
  expect(isValidAge(25)).toBe(true);
  expect(isValidAge(-5)).toBe(false);
  // Missing: 0, 18 (min), 120 (max), decimals, strings
});

// Missing error cases
test('parse JSON', () => {
  const result = parseJSON('{"name": "John"}');
  expect(result.name).toBe('John');
  // Missing: invalid JSON, empty string, null
});
```

**✅ GOOD**:
```typescript
// Test all paths including edge cases
describe('divide', () => {
  test('returns correct result for positive numbers', () => {
    expect(divide(10, 2)).toBe(5);
  });
  
  test('returns negative result when dividing by negative', () => {
    expect(divide(10, -2)).toBe(-5);
  });
  
  test('throws error when dividing by zero', () => {
    expect(() => divide(10, 0)).toThrow('Division by zero');
  });
  
  test('handles decimal results', () => {
    expect(divide(10, 3)).toBeCloseTo(3.333, 3);
  });
  
  test('returns zero when dividend is zero', () => {
    expect(divide(0, 5)).toBe(0);
  });
});

// Test boundary conditions
describe('isValidAge', () => {
  test('returns true for valid age', () => {
    expect(isValidAge(25)).toBe(true);
  });
  
  test('returns false for negative age', () => {
    expect(isValidAge(-1)).toBe(false);
  });
  
  test('returns false for zero', () => {
    expect(isValidAge(0)).toBe(false);
  });
  
  test('returns true for minimum valid age', () => {
    expect(isValidAge(18)).toBe(true);
  });
  
  test('returns true for age just below minimum', () => {
    expect(isValidAge(17)).toBe(false);
  });
  
  test('returns true for maximum valid age', () => {
    expect(isValidAge(120)).toBe(true);
  });
  
  test('returns false for age above maximum', () => {
    expect(isValidAge(121)).toBe(false);
  });
  
  test('handles decimal ages', () => {
    expect(isValidAge(25.5)).toBe(true);
  });
});

// Test error paths
describe('parseJSON', () => {
  test('parses valid JSON object', () => {
    const result = parseJSON('{"name": "John"}');
    expect(result).toEqual({ name: 'John' });
  });
  
  test('parses valid JSON array', () => {
    const result = parseJSON('[1, 2, 3]');
    expect(result).toEqual([1, 2, 3]);
  });
  
  test('throws error for invalid JSON', () => {
    expect(() => parseJSON('{invalid}')).toThrow('Invalid JSON');
  });
  
  test('throws error for empty string', () => {
    expect(() => parseJSON('')).toThrow('Empty input');
  });
  
  test('throws error for null input', () => {
    expect(() => parseJSON(null)).toThrow('Null input');
  });
  
  test('throws error for undefined input', () => {
    expect(() => parseJSON(undefined)).toThrow('Undefined input');
  });
});
```

**Violation Handling**: Add tests for boundary values, error cases, null/undefined, empty collections

**No Excuses**:
- ❌ "The happy path is most important"
- ❌ "Edge cases are rare"
- ❌ "Too many tests to write"

**Enforcement**: Code coverage tools, mutation testing, boundary value analysis

---

## Implementation Details (Original ECC Domain Knowledge)

### Test Structure (AAA Pattern)

```typescript
// Arrange-Act-Assert pattern
test('adds item to cart', () => {
  // Arrange: Set up test data and dependencies
  const cart = new Cart();
  const item = { id: 1, name: 'Product', price: 10 };
  
  // Act: Execute the behavior being tested
  cart.addItem(item);
  
  // Assert: Verify the expected outcome
  expect(cart.items).toHaveLength(1);
  expect(cart.items[0]).toEqual(item);
});

// Given-When-Then (BDD style)
test('user receives welcome email after registration', async () => {
  // Given: A new user with valid data
  const userData = { email: 'test@example.com', password: 'password123' };
  
  // When: The user registers
  await userService.register(userData);
  
  // Then: A welcome email is sent
  expect(emailService.send).toHaveBeenCalledWith({
    to: 'test@example.com',
    subject: 'Welcome!',
    template: 'welcome'
  });
});
```

### Mocking Strategies

```typescript
// Jest mocks
jest.mock('./emailService');

test('sends notification email', async () => {
  const emailService = require('./emailService');
  emailService.send.mockResolvedValue({ success: true });
  
  await notificationService.notifyUser(user, 'Welcome!');
  
  expect(emailService.send).toHaveBeenCalledWith({
    to: user.email,
    subject: 'Welcome!',
    body: expect.any(String)
  });
});

// Spy on existing implementation
test('logs error when email fails', async () => {
  const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
  emailService.send.mockRejectedValue(new Error('SMTP error'));
  
  await notificationService.notifyUser(user, 'Welcome!');
  
  expect(consoleErrorSpy).toHaveBeenCalledWith('Failed to send email:', expect.any(Error));
  
  consoleErrorSpy.mockRestore();
});

// Dependency injection for testability
class OrderService {
  constructor(
    private db: Database,
    private paymentGateway: PaymentGateway,
    private emailService: EmailService
  ) {}
  
  async createOrder(orderData: OrderData) {
    const order = await this.db.orders.create(orderData);
    await this.paymentGateway.charge(order.total);
    await this.emailService.send(order.userEmail, 'Order confirmation');
    return order;
  }
}

// Test with mock dependencies
test('creates order and charges payment', async () => {
  const mockDb = { orders: { create: jest.fn().mockResolvedValue({ id: 1, total: 100 }) } };
  const mockPayment = { charge: jest.fn().mockResolvedValue({ success: true }) };
  const mockEmail = { send: jest.fn().mockResolvedValue({}) };
  
  const service = new OrderService(mockDb, mockPayment, mockEmail);
  
  const order = await service.createOrder({ items: [], total: 100 });
  
  expect(mockPayment.charge).toHaveBeenCalledWith(100);
  expect(mockEmail.send).toHaveBeenCalled();
});
```

### Async Testing

```typescript
// async/await (preferred)
test('fetches user data', async () => {
  const user = await userService.fetchUser(1);
  expect(user.name).toBe('John');
});

// Testing promises
test('fetches user data', () => {
  return userService.fetchUser(1).then(user => {
    expect(user.name).toBe('John');
  });
});

// Testing rejections
test('throws error for invalid user ID', async () => {
  await expect(
    userService.fetchUser(-1)
  ).rejects.toThrow('Invalid user ID');
});

// Testing with done callback (legacy)
test('fetches user data', (done) => {
  userService.fetchUser(1).then(user => {
    expect(user.name).toBe('John');
    done();
  });
});
```

### Component Testing (React)

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

// Rendering and querying
test('displays username', () => {
  render(<UserProfile user={{ name: 'John' }} />);
  
  expect(screen.getByText('John')).toBeInTheDocument();
});

// User interactions
test('submits form on button click', async () => {
  const handleSubmit = jest.fn();
  render(<LoginForm onSubmit={handleSubmit} />);
  
  await userEvent.type(screen.getByLabelText('Email'), 'test@example.com');
  await userEvent.type(screen.getByLabelText('Password'), 'password123');
  await userEvent.click(screen.getByRole('button', { name: 'Login' }));
  
  expect(handleSubmit).toHaveBeenCalledWith({
    email: 'test@example.com',
    password: 'password123'
  });
});

// Testing hooks
import { renderHook, act } from '@testing-library/react';

test('useCounter increments count', () => {
  const { result } = renderHook(() => useCounter());
  
  act(() => {
    result.current.increment();
  });
  
  expect(result.current.count).toBe(1);
});
```

### Snapshot Testing

```typescript
// Component snapshot
test('renders correctly', () => {
  const { container } = render(<Button variant="primary">Click me</Button>);
  expect(container).toMatchSnapshot();
});

// Inline snapshot
test('formats user data', () => {
  const formatted = formatUser({ name: 'John', age: 30 });
  
  expect(formatted).toMatchInlineSnapshot(`
    {
      "age": 30,
      "name": "John",
    }
  `);
});

// Update snapshots: npm test -- -u
```

### Test Coverage

```typescript
// Run with coverage
// npm test -- --coverage

// Coverage thresholds in package.json
{
  "jest": {
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}

// Ignore files from coverage
{
  "jest": {
    "coveragePathIgnorePatterns": [
      "/node_modules/",
      "/test/",
      "/*.config.js"
    ]
  }
}
```

---

## OpenCode Integration

### When to Use This Skill

**Auto-load when detecting**:
- Unit test failures ("test failed", "assertion error")
- Missing test coverage ("no tests for function")
- Flaky tests ("test passes sometimes")
- Mocking issues ("mock not working")
- Test organization issues ("tests are hard to maintain")

**Manual invocation**:
```
@use unit-testing
User: "Write unit tests for UserService"
```

### Workflow Integration

**1. Test planning**:
```typescript
// Identify units to test
- Pure functions (business logic)
- Class methods (services, repositories)
- React components (UI logic)
- Custom hooks (stateful logic)
```

**2. Test implementation**:
- Write test cases for happy path
- Add tests for edge cases (boundary values, null, empty)
- Test error handling paths
- Verify test isolation (run in any order)
- Check test coverage (aim for 80%+)

**3. Test maintenance**:
```bash
# Run tests on file change
npm test -- --watch

# Run specific test file
npm test -- UserService.test.ts

# Run tests matching pattern
npm test -- --testNamePattern="creates user"
```

### Skills Combination

**Works well with**:
- `test-driven-development` - TDD workflow for unit tests
- `systematic-debugging` - Debug failing tests
- `backend-patterns` - Test async code, error handling
- `frontend-patterns` - Test React components, hooks

**Example workflow**:
```
1. @use test-driven-development → Write failing test first
2. @use unit-testing → Implement test following Iron Laws
3. Implement production code
4. @use verification-before-completion → Verify test coverage
```

---

## Verification Checklist

Before marking unit testing complete:

- [ ] No tests targeting private methods (public API only)
- [ ] No mocking of third-party libraries (wrap and mock YOUR interfaces)
- [ ] One concept per test (no assertion roulette)
- [ ] All tests are isolated (no interdependence)
- [ ] Edge cases covered (boundary values, null, errors)
- [ ] AAA pattern used (Arrange-Act-Assert)
- [ ] Test coverage > 80%
- [ ] Tests run in any order successfully
- [ ] No flaky tests (pass consistently)
- [ ] Test names describe behavior, not implementation

**Unit test health metrics**:
- Test execution time < 10 seconds (full suite)
- Test coverage > 80% (lines, branches, functions)
- Average test length < 20 lines
- Max assertions per test < 3
- Zero test interdependencies

---

**This skill enforces maintainable unit testing practices with zero tolerance for brittle tests, excessive mocking, and missing edge cases.**
