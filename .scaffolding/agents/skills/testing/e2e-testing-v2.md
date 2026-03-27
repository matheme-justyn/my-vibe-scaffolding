---
name: e2e-testing
version: 2.0.0
description: End-to-end testing with Iron Laws enforcement - Playwright patterns, page objects, test organization, user flows, CI/CD integration, and flake prevention strategies.
origin: ECC-derived (testing expertise)
adapted_for: OpenCode
transformation: Superpowers Iron Laws integration
---

# End-to-End Testing v2.0

## Iron Laws (Superpowers Style)

### 1. NO HARDCODED WAITS (USE EXPLICIT WAITS FOR CONDITIONS)

**❌ BAD**:
```typescript
// Fixed delay (flaky - might be too short or unnecessarily long)
await page.click('[data-testid="submit"]');
await page.waitForTimeout(3000); // Hope 3s is enough
expect(page.locator('.success-message')).toBeVisible();

// Multiple hardcoded waits
await page.fill('#email', 'user@test.com');
await page.waitForTimeout(500); // Wait for validation
await page.fill('#password', 'password123');
await page.waitForTimeout(500); // Wait for button enable
await page.click('button[type="submit"]');
await page.waitForTimeout(2000); // Wait for API

// Sleep after navigation
await page.goto('/dashboard');
await page.waitForTimeout(1000); // Wait for load
```

**✅ GOOD**:
```typescript
// Wait for specific condition
await page.click('[data-testid="submit"]');
await page.waitForSelector('.success-message', { 
  state: 'visible',
  timeout: 5000 
});
expect(page.locator('.success-message')).toBeVisible();

// Wait for network idle
await page.fill('#email', 'user@test.com');
await page.waitForLoadState('networkidle');
await page.fill('#password', 'password123');
await page.waitForSelector('button[type="submit"]:not([disabled])');
await page.click('button[type="submit"]');
await page.waitForResponse(resp => 
  resp.url().includes('/api/login') && resp.status() === 200
);

// Wait for navigation to complete
await page.goto('/dashboard', { waitUntil: 'domcontentloaded' });
await page.waitForSelector('[data-testid="dashboard-loaded"]');

// Auto-waiting (Playwright built-in)
await page.click('button'); // Waits for actionability automatically
await expect(page.locator('.success')).toBeVisible(); // Waits for assertion
```

**Violation Handling**: Replace ALL `waitForTimeout` with condition-based waits (`waitForSelector`, `waitForResponse`, `waitForLoadState`)

**No Excuses**:
- ❌ "It's just 1 second"
- ❌ "The element loads quickly"
- ❌ "Conditional waits are more complex"

**Enforcement**: ESLint rule banning `waitForTimeout`, code review, flaky test detection in CI

---

### 2. NO TESTING IMPLEMENTATION DETAILS (TEST USER BEHAVIOR)

**❌ BAD**:
```typescript
// Testing internal state
await page.evaluate(() => {
  return window.appState.isLoggedIn === true;
});

// Testing CSS classes
expect(await page.locator('.button').getAttribute('class'))
  .toContain('btn-primary');

// Testing internal API calls
await page.waitForRequest(req => 
  req.url().includes('/internal/analytics')
);

// Testing component props
await page.evaluate(() => {
  const component = document.querySelector('.user-profile');
  return component.__reactProps$$.userId === 123;
});
```

**✅ GOOD**:
```typescript
// Test what user sees
await page.goto('/login');
await page.fill('[placeholder="Email"]', 'user@test.com');
await page.fill('[placeholder="Password"]', 'password123');
await page.click('button:has-text("Login")');

// Verify user is logged in (by seeing dashboard)
await expect(page.locator('h1')).toHaveText('Dashboard');
await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();

// Test visual feedback
await page.click('[data-testid="delete-button"]');
await expect(page.locator('.toast-message')).toHaveText('Item deleted');

// Test user flow outcome
await page.goto('/cart');
await page.click('[data-testid="checkout"]');
await page.fill('[name="cardNumber"]', '4242424242424242');
await page.click('button:has-text("Pay")');
// Verify successful purchase (user-visible outcome)
await expect(page.locator('.order-confirmation')).toBeVisible();
await expect(page.locator('.order-id')).toContainText(/^ORD-\d+$/);
```

**Violation Handling**: Rewrite tests to interact with UI as users do, verify visible outcomes only

**No Excuses**:
- ❌ "I need to check internal state"
- ❌ "It's faster to test props directly"
- ❌ "The UI might change but logic stays same"

**Enforcement**: Code review, testing library principles, avoid `page.evaluate` for assertions

---

### 3. NO SHARED STATE BETWEEN TESTS (ISOLATION REQUIRED)

**❌ BAD**:
```typescript
// Tests depend on execution order
test.describe('User workflow', () => {
  let userId: number;
  
  test('1. Create user', async ({ page }) => {
    await page.goto('/register');
    await page.fill('[name="email"]', 'test@example.com');
    await page.click('button:has-text("Register")');
    userId = await page.locator('[data-testid="user-id"]').textContent();
  });
  
  test('2. Login user', async ({ page }) => {
    // Depends on userId from previous test
    await page.goto(`/users/${userId}/profile`);
  });
  
  test('3. Update profile', async ({ page }) => {
    // Depends on previous tests running first
    await page.fill('[name="bio"]', 'New bio');
    await page.click('button:has-text("Save")');
  });
});

// Shared database state
test('Create order', async ({ page }) => {
  await createOrder({ userId: 1, productId: 1 });
  // Next test will see this order
});

test('List orders', async ({ page }) => {
  await page.goto('/orders');
  const count = await page.locator('.order-item').count();
  expect(count).toBe(5); // Assumes previous tests created 4 orders
});
```

**✅ GOOD**:
```typescript
// Each test is independent
test.describe('User workflow', () => {
  test('Create and verify user', async ({ page }) => {
    await page.goto('/register');
    await page.fill('[name="email"]', `test-${Date.now()}@example.com`);
    await page.fill('[name="password"]', 'password123');
    await page.click('button:has-text("Register")');
    
    // Verify in same test
    await expect(page.locator('.success-message')).toBeVisible();
    await expect(page).toHaveURL(/\/dashboard/);
  });
  
  test('Login existing user', async ({ page }) => {
    // Setup: Create user via API
    const user = await createTestUser();
    
    // Test: Login flow
    await page.goto('/login');
    await page.fill('[name="email"]', user.email);
    await page.fill('[name="password"]', 'password123');
    await page.click('button:has-text("Login")');
    
    await expect(page).toHaveURL(/\/dashboard/);
  });
  
  test('Update profile', async ({ page }) => {
    // Setup: Create and login user
    const user = await createTestUser();
    await loginUser(page, user);
    
    // Test: Update profile
    await page.goto('/profile');
    await page.fill('[name="bio"]', 'Updated bio');
    await page.click('button:has-text("Save")');
    
    await expect(page.locator('.success-message')).toBeVisible();
  });
});

// Database isolation with fixtures
test.beforeEach(async ({ page }) => {
  // Clean slate for each test
  await resetDatabase();
  await seedTestData();
});

// Playwright's built-in isolation
test('Create order', async ({ page, context }) => {
  // Fresh browser context per test
  const user = await createTestUser();
  await loginUser(page, user);
  
  await page.goto('/products/1');
  await page.click('button:has-text("Add to Cart")');
  await page.goto('/checkout');
  await page.click('button:has-text("Place Order")');
  
  await expect(page.locator('.order-confirmation')).toBeVisible();
});
```

**Violation Handling**: Refactor tests to be independent, use beforeEach for setup, clean database between tests

**No Excuses**:
- ❌ "Tests are faster when sharing state"
- ❌ "It's the same user journey"
- ❌ "Database reset is slow"

**Enforcement**: Run tests in random order, parallel execution, test isolation checks

---

### 4. NO MISSING TEST DATA CLEANUP (TEARDOWN REQUIRED)

**❌ BAD**:
```typescript
// No cleanup after test
test('Upload file', async ({ page }) => {
  await page.goto('/upload');
  await page.setInputFiles('[type="file"]', 'test-file.pdf');
  await page.click('button:has-text("Upload")');
  // File remains in storage after test
});

// Cleanup only on success
test('Create user', async ({ page }) => {
  const userId = await createUser({ email: 'test@example.com' });
  
  await page.goto(`/users/${userId}`);
  expect(await page.locator('h1').textContent()).toBe('Test User');
  
  await deleteUser(userId); // Not called if assertion fails
});

// Missing API cleanup
test('Create order', async ({ page }) => {
  await page.goto('/products/1');
  await page.click('button:has-text("Buy Now")');
  // Order created in database, never cleaned up
});
```

**✅ GOOD**:
```typescript
// Cleanup in afterEach
test.describe('File uploads', () => {
  const uploadedFiles: string[] = [];
  
  test.afterEach(async () => {
    // Clean up all uploaded files
    for (const fileId of uploadedFiles) {
      await deleteFile(fileId);
    }
    uploadedFiles.length = 0;
  });
  
  test('Upload file', async ({ page }) => {
    await page.goto('/upload');
    await page.setInputFiles('[type="file"]', 'test-file.pdf');
    await page.click('button:has-text("Upload")');
    
    const fileId = await page.locator('[data-testid="file-id"]').textContent();
    uploadedFiles.push(fileId);
    
    await expect(page.locator('.success-message')).toBeVisible();
  });
});

// Cleanup with try/finally
test('Create user', async ({ page }) => {
  const user = await createUser({ email: `test-${Date.now()}@example.com` });
  
  try {
    await page.goto(`/users/${user.id}`);
    await expect(page.locator('h1')).toHaveText(user.name);
  } finally {
    // Always runs, even if test fails
    await deleteUser(user.id);
  }
});

// Fixture-based cleanup (Playwright)
import { test as base } from '@playwright/test';

const test = base.extend<{ testUser: User }>({
  testUser: async ({}, use) => {
    // Setup
    const user = await createUser({ 
      email: `test-${Date.now()}@example.com` 
    });
    
    // Provide to test
    await use(user);
    
    // Cleanup (always runs)
    await deleteUser(user.id);
  },
});

test('User profile', async ({ page, testUser }) => {
  await loginUser(page, testUser);
  await page.goto('/profile');
  await expect(page.locator('[data-testid="email"]')).toHaveText(testUser.email);
  // testUser automatically cleaned up
});

// Database transaction rollback
test.beforeEach(async () => {
  await db.beginTransaction();
});

test.afterEach(async () => {
  await db.rollbackTransaction(); // Undo all changes
});
```

**Violation Handling**: Add afterEach cleanup, use fixtures, implement database transaction rollback

**No Excuses**:
- ❌ "Test environment is reset daily"
- ❌ "It's just test data"
- ❌ "Cleanup is too complex"

**Enforcement**: Storage quota monitoring, test data audit, CI warnings for orphaned data

---

### 5. NO FLAKY SELECTORS (USE DATA-TESTID)

**❌ BAD**:
```typescript
// CSS class selector (fragile - CSS changes break tests)
await page.click('.btn-primary.large.submit-button');

// Text content selector (breaks on i18n, copy changes)
await page.click('button:has-text("Submit")');

// nth-child selector (breaks when UI order changes)
await page.click('.form-row:nth-child(3) input');

// XPath (fragile and hard to read)
await page.click('//div[@class="container"]//button[contains(text(), "Save")]');

// ID selector (might conflict, changes with framework)
await page.click('#button-1234567890');
```

**✅ GOOD**:
```typescript
// data-testid (stable, semantic, test-specific)
await page.click('[data-testid="submit-button"]');
await page.fill('[data-testid="email-input"]', 'user@test.com');
await expect(page.locator('[data-testid="success-message"]')).toBeVisible();

// Accessibility attributes (stable, semantic)
await page.click('button[aria-label="Submit form"]');
await page.fill('input[aria-label="Email address"]', 'user@test.com');

// Role-based selectors (accessibility + stability)
await page.click('role=button[name="Submit"]');
await page.fill('role=textbox[name="Email"]', 'user@test.com');

// Combination for uniqueness
await page.click('[data-testid="product-card"]:has-text("Product 1") >> button[aria-label="Add to cart"]');

// Component library with test IDs
<Button data-testid="submit-button" onClick={handleSubmit}>
  Submit
</Button>

<Input 
  data-testid="email-input"
  type="email"
  placeholder="Email"
/>

<Alert data-testid="success-message">
  Form submitted successfully
</Alert>
```

**Violation Handling**: Add data-testid to ALL interactive elements, use role-based selectors for accessibility

**No Excuses**:
- ❌ "data-testid pollutes production code"
- ❌ "CSS selectors are simpler"
- ❌ "Text selectors work fine"

**Enforcement**: ESLint rule requiring data-testid, code review, selector audit

---

## Implementation Details (Original ECC Domain Knowledge)

### Page Object Model

```typescript
// pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}
  
  // Locators (lazy evaluation)
  get emailInput() {
    return this.page.locator('[data-testid="email-input"]');
  }
  
  get passwordInput() {
    return this.page.locator('[data-testid="password-input"]');
  }
  
  get submitButton() {
    return this.page.locator('[data-testid="submit-button"]');
  }
  
  get errorMessage() {
    return this.page.locator('[data-testid="error-message"]');
  }
  
  // Actions
  async goto() {
    await this.page.goto('/login');
  }
  
  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
  
  async expectErrorMessage(message: string) {
    await expect(this.errorMessage).toHaveText(message);
  }
}

// Usage in test
test('Login with invalid credentials', async ({ page }) => {
  const loginPage = new LoginPage(page);
  
  await loginPage.goto();
  await loginPage.login('invalid@test.com', 'wrongpassword');
  await loginPage.expectErrorMessage('Invalid credentials');
});
```

### Test Organization

```typescript
// tests/auth/login.spec.ts
test.describe('Login Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
  });
  
  test('Successful login with valid credentials', async ({ page }) => {
    // Test implementation
  });
  
  test('Failed login with invalid email', async ({ page }) => {
    // Test implementation
  });
  
  test('Failed login with invalid password', async ({ page }) => {
    // Test implementation
  });
  
  test('Remember me checkbox persists session', async ({ page }) => {
    // Test implementation
  });
});

// tests/e2e/checkout.spec.ts
test.describe('E2E Checkout Flow', () => {
  test('Complete purchase flow', async ({ page }) => {
    // 1. Browse products
    await page.goto('/products');
    await page.click('[data-testid="product-1"] >> [data-testid="add-to-cart"]');
    
    // 2. View cart
    await page.click('[data-testid="cart-icon"]');
    await expect(page.locator('[data-testid="cart-item"]')).toHaveCount(1);
    
    // 3. Checkout
    await page.click('[data-testid="checkout-button"]');
    await page.fill('[data-testid="shipping-address"]', '123 Main St');
    
    // 4. Payment
    await page.fill('[data-testid="card-number"]', '4242424242424242');
    await page.click('[data-testid="pay-button"]');
    
    // 5. Confirmation
    await expect(page.locator('[data-testid="order-confirmation"]')).toBeVisible();
  });
});
```

### API Mocking

```typescript
// Mock API responses
test('Display products from API', async ({ page }) => {
  // Intercept and mock API call
  await page.route('/api/products', async route => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify([
        { id: 1, name: 'Product 1', price: 29.99 },
        { id: 2, name: 'Product 2', price: 39.99 },
      ]),
    });
  });
  
  await page.goto('/products');
  await expect(page.locator('[data-testid="product-item"]')).toHaveCount(2);
});

// Wait for specific API call
test('Submit form triggers API', async ({ page }) => {
  const responsePromise = page.waitForResponse(
    resp => resp.url().includes('/api/submit') && resp.status() === 200
  );
  
  await page.fill('[data-testid="form-field"]', 'Test data');
  await page.click('[data-testid="submit"]');
  
  const response = await responsePromise;
  const data = await response.json();
  expect(data.success).toBe(true);
});
```

### Visual Regression Testing

```typescript
// Screenshot comparison
test('Homepage visual regression', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png', {
    fullPage: true,
    maxDiffPixels: 100, // Allow minor differences
  });
});

// Component-level screenshot
test('Button styles', async ({ page }) => {
  await page.goto('/styleguide');
  const button = page.locator('[data-testid="primary-button"]');
  await expect(button).toHaveScreenshot('primary-button.png');
});
```

### Parallel Execution

```typescript
// playwright.config.ts
export default defineConfig({
  workers: 4, // Run 4 tests in parallel
  fullyParallel: true,
  retries: 2, // Retry flaky tests
  
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'mobile',
      use: { ...devices['iPhone 13'] },
    },
  ],
});

// Tag tests for selective execution
test.describe('Critical user flows @smoke', () => {
  test('Login', async ({ page }) => { /* ... */ });
  test('Checkout', async ({ page }) => { /* ... */ });
});

// Run only smoke tests
// npx playwright test --grep @smoke
```

---

## OpenCode Integration

### When to Use This Skill

**Auto-load when detecting**:
- E2E test failures ("Playwright test failed")
- Flaky tests ("test passed locally but failed in CI")
- Test timeout issues ("test exceeded timeout")
- Selector issues ("element not found", "selector error")
- Missing test coverage ("no E2E tests for feature")

**Manual invocation**:
```
@use e2e-testing
User: "Write E2E tests for checkout flow"
```

### Workflow Integration

**1. Test planning**:
```typescript
// Identify critical user flows
- User registration → Login → Dashboard
- Product browse → Add to cart → Checkout → Payment
- Create post → Edit post → Publish → View
```

**2. Test implementation**:
- Setup Page Object Models
- Write tests with data-testid selectors
- Add explicit waits (no hardcoded timeouts)
- Implement test data cleanup
- Verify test isolation

**3. CI/CD integration**:
```yaml
# .github/workflows/e2e.yml
name: E2E Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test
      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
```

### Skills Combination

**Works well with**:
- `test-driven-development` - TDD workflow for E2E tests
- `systematic-debugging` - Debug failing E2E tests
- `frontend-patterns` - Add data-testid to components
- `api-design` - Test API integration points

**Example workflow**:
```
1. @use brainstorming → Plan user flows to test
2. @use e2e-testing → Implement E2E tests
3. @use systematic-debugging → Debug failing tests
4. @use verification-before-completion → Verify test coverage
```

---

## Verification Checklist

Before marking E2E testing complete:

- [ ] No hardcoded waits (use explicit waits)
- [ ] Tests verify user-visible behavior (not implementation)
- [ ] All tests are isolated (no shared state)
- [ ] Test data cleanup implemented (afterEach/fixtures)
- [ ] All selectors use data-testid or ARIA attributes
- [ ] Page Object Model implemented for complex flows
- [ ] API mocking for external services
- [ ] Tests run in parallel successfully
- [ ] CI/CD integration configured
- [ ] Visual regression tests for critical pages

**E2E test health metrics**:
- Test execution time < 5 minutes (full suite)
- Flake rate < 1% (tests pass consistently)
- Test coverage > 80% of critical user flows
- Max test duration < 30 seconds per test
- Parallel execution enabled (4+ workers)

---

**This skill enforces reliable E2E testing practices with zero tolerance for flaky tests, hardcoded waits, and implementation detail testing.**
