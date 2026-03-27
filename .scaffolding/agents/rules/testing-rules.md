# Testing Rules

**Purpose**: Ensure comprehensive, reliable test coverage and maintainable test code.

## Universal Testing Rules

### Rule 1: Write Tests BEFORE Code (TDD)

**Severity**: HIGH 🟠

**Red-Green-Refactor Cycle**:
1. **Red**: Write failing test
2. **Green**: Write minimal code to pass
3. **Refactor**: Improve code while keeping tests green

```typescript
// 1. RED - Write test first
test('calculates order total with tax', () => {
  expect(calculateTotal([{ price: 10, qty: 2 }], 0.1)).toBe(22)
})

// 2. GREEN - Implement minimal code
function calculateTotal(items, taxRate) {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.qty, 0)
  return subtotal * (1 + taxRate)
}

// 3. REFACTOR - Improve (tests still pass)
function calculateTotal(items: OrderItem[], taxRate: number): number {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.qty, 0)
  const tax = subtotal * taxRate
  return subtotal + tax
}
```

---

### Rule 2: Minimum 80% Test Coverage

**Severity**: HIGH 🟠

**Coverage Requirements**:
- Overall: ≥ 80%
- Critical paths: 100%
- Business logic: ≥ 90%
- Utilities: ≥ 85%
- UI components: ≥ 80%

```bash
# Check coverage
npm test -- --coverage

# Fail build if coverage < 80%
npm test -- --coverage --coverageThreshold='{"global":{"lines":80}}'
```

---

### Rule 3: Test Behavior, Not Implementation

**Severity**: MEDIUM 🟡

```typescript
// ❌ BAD: Testing implementation details
test('calls database.query with correct SQL', () => {
  const spy = jest.spyOn(database, 'query')
  getUser('123')
  expect(spy).toHaveBeenCalledWith('SELECT * FROM users WHERE id = $1', ['123'])
})

// ✅ GOOD: Testing behavior
test('returns user object for valid ID', () => {
  const user = getUser('123')
  expect(user).toEqual({ id: '123', name: 'John' })
})

test('throws NotFoundError for invalid ID', () => {
  expect(() => getUser('invalid')).toThrow(NotFoundError)
})
```

---

### Rule 4: One Assertion Per Test (Preferred)

**Severity**: LOW 🟢

```typescript
// ❌ DISCOURAGED: Multiple unrelated assertions
test('user validation', () => {
  expect(validateEmail('test@example.com')).toBe(true)
  expect(validateAge(25)).toBe(true)
  expect(validateName('John')).toBe(true)
})

// ✅ GOOD: One concept per test
test('validates correct email format', () => {
  expect(validateEmail('test@example.com')).toBe(true)
})

test('accepts legal age', () => {
  expect(validateAge(25)).toBe(true)
})

test('accepts valid name', () => {
  expect(validateName('John')).toBe(true)
})
```

---

### Rule 5: Tests Must Be Deterministic

**Severity**: CRITICAL 🔴

**No Flaky Tests**:
```typescript
// ❌ BAD: Non-deterministic (uses current time)
test('returns items from last 24 hours', () => {
  const items = getRecentItems()
  expect(items.length).toBeGreaterThan(0)  // Fails if no items today
})

// ✅ GOOD: Deterministic (mocked time)
test('returns items from last 24 hours', () => {
  jest.useFakeTimers().setSystemTime(new Date('2025-03-12'))
  const items = getRecentItems()
  expect(items).toEqual([/* expected items */])
})
```

---

## Unit Testing Rules

### Rule 6: Mock External Dependencies

**Severity**: HIGH 🟠

```typescript
// ✅ GOOD: Mock database
jest.mock('./database', () => ({
  query: jest.fn().mockResolvedValue({ id: '123', name: 'John' })
}))

test('fetches user from database', async () => {
  const user = await getUser('123')
  expect(user.name).toBe('John')
})
```

**What to Mock**:
- Database calls
- API requests
- File system operations
- External services
- Current time/date

---

### Rule 7: Test Edge Cases

**Severity**: HIGH 🟠

**Always Test**:
- Empty inputs (empty array, empty string, null, undefined)
- Boundary values (0, -1, MAX_INT)
- Invalid inputs (wrong type, malformed data)
- Error conditions (network failure, timeout)

```typescript
describe('divide', () => {
  test('divides positive numbers', () => {
    expect(divide(10, 2)).toBe(5)
  })
  
  test('divides negative numbers', () => {
    expect(divide(-10, 2)).toBe(-5)
  })
  
  test('handles division by zero', () => {
    expect(divide(10, 0)).toBe(Infinity)
  })
  
  test('handles decimal results', () => {
    expect(divide(5, 2)).toBe(2.5)
  })
  
  test('throws on non-numeric inputs', () => {
    expect(() => divide('10', 2)).toThrow()
  })
})
```

---

## Integration Testing Rules

### Rule 8: Test API Contracts

**Severity**: HIGH 🟠

```typescript
describe('POST /api/users', () => {
  test('creates user with valid data', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', name: 'John' })
    
    expect(response.status).toBe(201)
    expect(response.body.data).toMatchObject({
      email: 'test@example.com',
      name: 'John'
    })
  })
  
  test('returns 400 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'invalid', name: 'John' })
    
    expect(response.status).toBe(400)
    expect(response.body.error.code).toBe('VALIDATION_ERROR')
  })
})
```

---

### Rule 9: Clean Up After Tests

**Severity**: HIGH 🟠

```typescript
describe('UserService', () => {
  beforeEach(async () => {
    // Set up test database
    await db.migrate.latest()
    await db.seed.run()
  })
  
  afterEach(async () => {
    // Clean up
    await db('users').truncate()
  })
  
  afterAll(async () => {
    // Close connections
    await db.destroy()
  })
  
  test('creates user', async () => {
    // test implementation
  })
})
```

---

## E2E Testing Rules

### Rule 10: Test Critical User Flows Only

**Severity**: MEDIUM 🟡

**What to E2E Test**:
- ✅ User registration and login
- ✅ Checkout and payment
- ✅ Data submission forms
- ✅ Search functionality
- ❌ Every button click
- ❌ CSS styles
- ❌ Animations

```typescript
test('complete checkout flow', async ({ page }) => {
  // Login
  await page.goto('/login')
  await page.fill('[name=email]', 'test@example.com')
  await page.fill('[name=password]', 'password')
  await page.click('button[type=submit]')
  
  // Add to cart
  await page.goto('/products/123')
  await page.click('button:has-text("Add to Cart")')
  
  // Checkout
  await page.goto('/cart')
  await page.click('button:has-text("Checkout")')
  await page.fill('[name=cardNumber]', '4242424242424242')
  await page.click('button:has-text("Pay")')
  
  // Verify success
  await expect(page.locator('text=Order confirmed')).toBeVisible()
})
```

---

### Rule 11: Use Page Object Pattern

**Severity**: MEDIUM 🟡

```typescript
// pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}
  
  async goto() {
    await this.page.goto('/login')
  }
  
  async login(email: string, password: string) {
    await this.page.fill('[name=email]', email)
    await this.page.fill('[name=password]', password)
    await this.page.click('button[type=submit]')
  }
}

// tests/login.spec.ts
test('user can login', async ({ page }) => {
  const loginPage = new LoginPage(page)
  await loginPage.goto()
  await loginPage.login('test@example.com', 'password')
  
  await expect(page.locator('text=Welcome')).toBeVisible()
})
```

---

## Test Organization Rules

### Rule 12: Use Descriptive Test Names

**Severity**: MEDIUM 🟡

```typescript
// ❌ BAD
test('test 1', () => { /* ... */ })
test('works', () => { /* ... */ })

// ✅ GOOD
test('returns 404 when user not found', () => { /* ... */ })
test('validates email format before saving', () => { /* ... */ })
test('calculates shipping cost based on weight and distance', () => { /* ... */ })
```

---

### Rule 13: Group Related Tests

**Severity**: LOW 🟢

```typescript
describe('UserService', () => {
  describe('createUser', () => {
    test('creates user with valid data', () => { /* ... */ })
    test('throws on duplicate email', () => { /* ... */ })
    test('hashes password before saving', () => { /* ... */ })
  })
  
  describe('updateUser', () => {
    test('updates user fields', () => { /* ... */ })
    test('throws when user not found', () => { /* ... */ })
  })
})
```

---

## Performance Rules

### Rule 14: Tests Must Run Fast

**Severity**: MEDIUM 🟡

**Target Times**:
- Unit test: < 100ms each
- Integration test: < 1s each
- E2E test: < 30s each
- Full suite: < 5 minutes

**If Tests Are Slow**:
- Parallelize test execution
- Mock slow dependencies
- Use in-memory database for tests
- Reduce setup/teardown overhead

---

## Test Maintenance Rules

### Rule 15: Never Skip Failing Tests

**Severity**: CRITICAL 🔴

```typescript
// ❌ FORBIDDEN
test.skip('broken test', () => { /* ... */ })
xit('another broken test', () => { /* ... */ })

// ✅ FIX THE TEST OR DELETE IT
```

**If Test Fails**:
1. Fix the code (if bug)
2. Fix the test (if test is wrong)
3. Delete the test (if no longer needed)

**NEVER**: Skip or disable failing tests

---

### Rule 16: Delete Obsolete Tests

**Severity**: LOW 🟢

**When to Delete Tests**:
- Feature was removed
- Test duplicates another test
- Test doesn't provide value

---

## Pre-Commit Test Checklist

- [ ] All tests pass locally
- [ ] New code has tests
- [ ] Coverage ≥ 80%
- [ ] No skipped tests
- [ ] No `console.log` in tests
- [ ] Tests run fast (< 5 min for full suite)

---

## References

- [Jest Best Practices](https://jestjs.io/docs/getting-started)
- [Testing Library Guiding Principles](https://testing-library.com/docs/guiding-principles/)
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
