---
description: Refactor code for better maintainability and performance
agent: architect
subtask: true
---

# Refactor Command

Systematic code refactoring: $ARGUMENTS

## Your Task

1. **Identify refactoring target** - Function, class, or module
2. **Ensure test coverage** - Write tests if missing (TDD)
3. **Apply refactoring** - Use safe transformations
4. **Verify tests pass** - Run tests after each change

## Refactoring Safety Protocol

### Step 1: Baseline (MANDATORY)

```bash
# Run all tests BEFORE refactoring
npm test

# Record current state
git add .
git commit -m "Baseline before refactoring $TARGET"
```

**CRITICAL**: Never refactor without passing tests!

### Step 2: Add Missing Tests

If target code lacks tests:

```typescript
// BEFORE refactoring, write comprehensive tests
describe('UserService.processUser', () => {
  it('handles valid user data', () => { /* ... */ })
  it('throws on invalid email', () => { /* ... */ })
  it('handles edge case: empty name', () => { /* ... */ })
})
```

**Requirement**: > 80% coverage before refactoring

### Step 3: Refactor in Small Steps

**ONE change at a time**:

1. Extract variable
2. Run tests ✅
3. Extract function
4. Run tests ✅
5. Rename variable
6. Run tests ✅
7. ...

**NEVER**: Make multiple changes, then test

### Step 4: Verify After Each Step

```bash
# After EVERY refactoring step
npm test

# If tests fail, revert immediately
git checkout .
```

## Common Refactoring Patterns

### 1. Extract Function

**Before**:
```typescript
function processOrder(order: Order) {
  // Validate
  if (!order.id) throw new Error('Missing ID')
  if (!order.items.length) throw new Error('Empty order')
  
  // Calculate total
  const subtotal = order.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  const tax = subtotal * 0.1
  const total = subtotal + tax
  
  // Save
  db.orders.create({ ...order, total })
}
```

**After**:
```typescript
function processOrder(order: Order) {
  validateOrder(order)
  const total = calculateTotal(order.items)
  saveOrder(order, total)
}

function validateOrder(order: Order) {
  if (!order.id) throw new Error('Missing ID')
  if (!order.items.length) throw new Error('Empty order')
}

function calculateTotal(items: OrderItem[]): number {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  const tax = subtotal * 0.1
  return subtotal + tax
}

function saveOrder(order: Order, total: number) {
  db.orders.create({ ...order, total })
}
```

### 2. Replace Conditional with Polymorphism

**Before**:
```typescript
function getPrice(user: User) {
  if (user.type === 'regular') {
    return basePrice
  } else if (user.type === 'premium') {
    return basePrice * 0.9
  } else if (user.type === 'vip') {
    return basePrice * 0.7
  }
}
```

**After**:
```typescript
interface PricingStrategy {
  getPrice(basePrice: number): number
}

class RegularPricing implements PricingStrategy {
  getPrice(basePrice: number) { return basePrice }
}

class PremiumPricing implements PricingStrategy {
  getPrice(basePrice: number) { return basePrice * 0.9 }
}

class VIPPricing implements PricingStrategy {
  getPrice(basePrice: number) { return basePrice * 0.7 }
}

function getPrice(user: User) {
  return user.pricingStrategy.getPrice(basePrice)
}
```

### 3. Introduce Parameter Object

**Before**:
```typescript
function createUser(
  name: string,
  email: string,
  age: number,
  address: string,
  phone: string,
  country: string
) {
  // ...
}
```

**After**:
```typescript
interface UserData {
  name: string
  email: string
  age: number
  address: string
  phone: string
  country: string
}

function createUser(data: UserData) {
  // ...
}
```

### 4. Remove Duplication

**Before**:
```typescript
function validateUserEmail(email: string) {
  if (!email) throw new Error('Email required')
  if (!email.includes('@')) throw new Error('Invalid email')
}

function validateAdminEmail(email: string) {
  if (!email) throw new Error('Email required')
  if (!email.includes('@')) throw new Error('Invalid email')
  if (!email.endsWith('@company.com')) throw new Error('Must use company email')
}
```

**After**:
```typescript
function validateEmail(email: string) {
  if (!email) throw new Error('Email required')
  if (!email.includes('@')) throw new Error('Invalid email')
}

function validateUserEmail(email: string) {
  validateEmail(email)
}

function validateAdminEmail(email: string) {
  validateEmail(email)
  if (!email.endsWith('@company.com')) {
    throw new Error('Must use company email')
  }
}
```

### 5. Simplify Complex Conditionals

**Before**:
```typescript
if (user.age > 18 && user.country === 'US' && user.hasLicense && !user.isBanned) {
  allowDriving(user)
}
```

**After**:
```typescript
function canDrive(user: User): boolean {
  return user.age > 18 
    && user.country === 'US' 
    && user.hasLicense 
    && !user.isBanned
}

if (canDrive(user)) {
  allowDriving(user)
}
```

## Refactoring Checklist

**Before Starting**:
- [ ] All tests pass
- [ ] Commit current state
- [ ] Target has > 80% test coverage

**During Refactoring**:
- [ ] One small change at a time
- [ ] Run tests after each change
- [ ] Commit after each successful change
- [ ] Revert immediately if tests fail

**After Completion**:
- [ ] All tests still pass
- [ ] No new lint errors
- [ ] Code is more readable
- [ ] Complexity reduced
- [ ] Duplication removed

## Tools

**Automated Refactoring**:
- VSCode: Rename symbol (F2), Extract function (Ctrl+Shift+R)
- IntelliJ: Refactor menu (Ctrl+Alt+Shift+T)
- ESLint: Auto-fix rules

**Analysis**:
- `eslint --fix` - Auto-fix style issues
- `prettier` - Code formatting
- `jscodeshift` - Automated refactoring scripts

## When NOT to Refactor

❌ **Don't refactor when**:
- Tests are failing
- Code has no tests
- Under time pressure (ship first, refactor later)
- You don't understand the code
- Code is working and rarely changes

✅ **DO refactor when**:
- Adding new feature to messy code
- Code is hard to understand
- Duplication is high
- Complexity is high
- Before major changes

---

**IMPORTANT**: Refactoring changes structure, not behavior. Tests must pass before AND after!
