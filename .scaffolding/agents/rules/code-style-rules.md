# Code Style Rules

**Purpose**: Maintain consistent, readable code across the codebase.

## Naming Conventions

### Rule 1: Use Meaningful Names

```typescript
// ❌ BAD
const d = new Date()
const arr = [1, 2, 3]
function calc(a, b) { return a + b }

// ✅ GOOD
const currentDate = new Date()
const userIds = [1, 2, 3]
function calculateTotal(subtotal, tax) { return subtotal + tax }
```

### Rule 2: Follow Language Conventions

**TypeScript/JavaScript**:
- Variables/functions: `camelCase`
- Classes/types: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Private fields: `_prefixedCamelCase` or `#privateField`

**Python**:
- Variables/functions: `snake_case`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`

**Go**:
- Exported: `PascalCase`
- Unexported: `camelCase`

## Function Rules

### Rule 3: Keep Functions Small (< 50 Lines)

```typescript
// ❌ BAD: 100+ line function
function processOrder(order) {
  // ... 100 lines of logic
}

// ✅ GOOD: Split into smaller functions
function processOrder(order) {
  validateOrder(order)
  const total = calculateTotal(order.items)
  const payment = processPayment(order, total)
  sendConfirmation(order, payment)
}
```

### Rule 4: One Thing Per Function

```typescript
// ❌ BAD: Does multiple things
function saveUserAndSendEmail(user) {
  db.save(user)
  email.send(user.email, 'Welcome!')
}

// ✅ GOOD: Separate concerns
function saveUser(user) {
  db.save(user)
}

function sendWelcomeEmail(user) {
  email.send(user.email, 'Welcome!')
}
```

### Rule 5: Limit Parameters (Max 3)

```typescript
// ❌ BAD: Too many parameters
function createUser(name, email, age, address, phone, country) { }

// ✅ GOOD: Use object parameter
function createUser(userData: UserData) { }
```

## File Organization Rules

### Rule 6: Limit File Size (< 800 Lines)

### Rule 7: Group Related Code

```typescript
// File structure
export interface User { }        // Types first
export class UserService { }     // Classes
export function getUser() { }    // Functions
export const config = { }        // Constants
```

### Rule 8: Use Barrel Exports

```typescript
// index.ts (barrel file)
export * from './User'
export * from './Order'
export * from './Product'

// Usage
import { User, Order, Product } from './models'
```

## Code Quality Rules

### Rule 9: Avoid Nesting > 4 Levels

```typescript
// ❌ BAD: Deep nesting
if (user) {
  if (user.isActive) {
    if (user.hasPermission) {
      if (resource.isAvailable) {
        // ...
      }
    }
  }
}

// ✅ GOOD: Early returns
if (!user) return
if (!user.isActive) return
if (!user.hasPermission) return
if (!resource.isAvailable) return
// ...
```

### Rule 10: Remove Dead Code

```typescript
// ❌ BAD: Commented-out code
// function oldImplementation() {
//   // ... 50 lines of old code
// }

// ✅ GOOD: Delete it (use git history if needed)
```

### Rule 11: No Magic Numbers

```typescript
// ❌ BAD
if (user.age > 18) { }
setTimeout(() => {}, 5000)

// ✅ GOOD
const LEGAL_AGE = 18
if (user.age > LEGAL_AGE) { }

const FIVE_SECONDS = 5000
setTimeout(() => {}, FIVE_SECONDS)
```

## TypeScript Specific Rules

### Rule 12: Use Strict TypeScript

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true
  }
}
```

### Rule 13: Never Use `any`

```typescript
// ❌ BAD
function process(data: any) { }

// ✅ GOOD
function process<T>(data: T) { }
function process(data: unknown) { }
```

### Rule 14: Prefer Interfaces Over Types

```typescript
// ✅ PREFERRED
interface User {
  id: string
  name: string
}

// ⚠️ USE SPARINGLY
type UserId = string
type UserMap = Record<string, User>
```

## Formatting Rules

### Rule 15: Use Prettier/Auto-Formatter

```json
// .prettierrc
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
```

### Rule 16: Consistent Indentation (2 Spaces)

### Rule 17: Max Line Length (100 Characters)

## Comment Rules

### Rule 18: Write Comments for WHY, Not WHAT

```typescript
// ❌ BAD: Obvious comment
// Get user by ID
function getUser(id: string) { }

// ✅ GOOD: Explains reasoning
// Cache user data for 5 minutes to reduce database load
// (Saves ~1000 queries per second in production)
const cachedUser = cache.get(userId, { ttl: 300 })
```

### Rule 19: Keep Comments Up to Date

```typescript
// ❌ BAD: Outdated comment
// Returns array of users (WRONG: now returns Promise)
async function getUsers() { }

// ✅ GOOD: Accurate comment
// Returns promise that resolves to array of users
async function getUsers(): Promise<User[]> { }
```

## Import/Export Rules

### Rule 20: Group and Sort Imports

```typescript
// 1. External dependencies
import React from 'react'
import { useEffect, useState } from 'react'

// 2. Internal modules
import { Button } from '@/components/Button'
import { useAuth } from '@/hooks/useAuth'

// 3. Types
import type { User } from '@/types'
```

## Quick Checklist

- [ ] Names are meaningful and follow conventions
- [ ] Functions < 50 lines, files < 800 lines
- [ ] No nesting > 4 levels
- [ ] No dead code or commented-out blocks
- [ ] No magic numbers
- [ ] TypeScript strict mode enabled
- [ ] No `any` types
- [ ] Prettier formatting applied
- [ ] Comments explain WHY, not WHAT
- [ ] Imports grouped and sorted

## References

- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- [Clean Code by Robert Martin](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
