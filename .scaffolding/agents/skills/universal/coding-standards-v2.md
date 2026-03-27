---
name: coding-standards
version: 2.0.0
description: Coding standards with Iron Laws enforcement - consistent code style, naming conventions, TypeScript/React patterns, error handling, and documentation standards for production codebases.
origin: ECC-derived (universal expertise)
adapted_for: OpenCode
transformation: Superpowers Iron Laws integration
---

# Coding Standards v2.0

## Iron Laws (Superpowers Style)

### 1. NO INCONSISTENT NAMING CONVENTIONS

**❌ BAD**:
```typescript
// Mixed naming styles
const UserData = { name: 'John' }; // PascalCase for variable
const user_id = 123; // snake_case
const getusername = () => {}; // no separation
class product_manager {} // snake_case for class
const APIKEY = 'secret'; // unclear abbreviation

// Inconsistent file names
UserProfile.tsx
user-settings.tsx
UserDashboard.jsx
user_list.tsx
```

**✅ GOOD**:
```typescript
// Consistent naming conventions
const userData = { name: 'John' }; // camelCase for variables
const userId = 123; // camelCase
const getUserName = () => {}; // camelCase for functions
class ProductManager {} // PascalCase for classes
const API_KEY = 'secret'; // SCREAMING_SNAKE_CASE for constants

// Consistent file names (kebab-case)
user-profile.tsx
user-settings.tsx
user-dashboard.tsx
user-list.tsx

// Or PascalCase (if project convention)
UserProfile.tsx
UserSettings.tsx
UserDashboard.tsx
UserList.tsx
```

**Naming Rules**:
```typescript
// Variables & Functions: camelCase
const userName = 'John';
function getUserData() {}

// Classes & Interfaces: PascalCase
class UserService {}
interface UserData {}

// Constants: SCREAMING_SNAKE_CASE
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = 'https://api.example.com';

// Private class members: _camelCase (optional convention)
class User {
  private _internalState: State;
  public name: string;
}

// Boolean variables: is/has/should prefix
const isActive = true;
const hasPermission = false;
const shouldRetry = true;

// Functions returning boolean: is/has/can prefix
function isValid(input: string): boolean {}
function hasAccess(user: User): boolean {}
function canEdit(resource: Resource): boolean {}
```

**Violation Handling**: Establish project naming conventions document, enforce with linters (ESLint naming-convention rule)

**No Excuses**:
- ❌ "It's just a local variable"
- ❌ "The old code uses different style"
- ❌ "Consistency doesn't matter"

**Enforcement**: ESLint `@typescript-eslint/naming-convention`, code review, automated formatting

---

### 2. NO MAGIC NUMBERS OR STRINGS (USE NAMED CONSTANTS)

**❌ BAD**:
```typescript
// Magic numbers
if (user.age >= 18) {
  // What's special about 18?
}

setTimeout(() => {}, 3000); // Why 3 seconds?

const discount = price * 0.15; // What's 0.15?

// Magic strings
if (user.role === 'admin') {} // Typo-prone
fetch('/api/users/123'); // Hardcoded endpoint

// Repeated magic values
if (status === 200) {
  // Success
} else if (status === 404) {
  // Not found
} else if (status === 500) {
  // Server error
}
```

**✅ GOOD**:
```typescript
// Named constants
const MINIMUM_AGE = 18;
if (user.age >= MINIMUM_AGE) {
  // Clear intent
}

const DEBOUNCE_DELAY_MS = 3000;
setTimeout(() => {}, DEBOUNCE_DELAY_MS);

const DISCOUNT_RATE = 0.15;
const discount = price * DISCOUNT_RATE;

// Enum for roles
enum UserRole {
  ADMIN = 'admin',
  USER = 'user',
  GUEST = 'guest'
}
if (user.role === UserRole.ADMIN) {}

// API endpoints as constants
const API_ENDPOINTS = {
  USERS: '/api/users',
  PRODUCTS: '/api/products',
} as const;
fetch(`${API_ENDPOINTS.USERS}/${userId}`);

// HTTP status codes
enum HttpStatus {
  OK = 200,
  NOT_FOUND = 404,
  INTERNAL_SERVER_ERROR = 500
}

if (status === HttpStatus.OK) {
  // Success
} else if (status === HttpStatus.NOT_FOUND) {
  // Not found
} else if (status === HttpStatus.INTERNAL_SERVER_ERROR) {
  // Server error
}

// Configuration constants
const CONFIG = {
  MAX_FILE_SIZE: 5 * 1024 * 1024, // 5MB
  TIMEOUT: 30000, // 30 seconds
  RETRY_ATTEMPTS: 3,
} as const;
```

**Violation Handling**: Extract ALL magic values to named constants at top of file or separate config file

**No Excuses**:
- ❌ "The number is self-explanatory"
- ❌ "I'll only use it once"
- ❌ "It's a well-known value"

**Enforcement**: ESLint `no-magic-numbers`, code review, SonarQube analysis

---

### 3. NO MISSING COMMENTS FOR COMPLEX LOGIC (WHY, NOT WHAT)

**❌ BAD**:
```typescript
// Useless comments (stating the obvious)
// Set x to 5
const x = 5;

// Loop through users
users.forEach(user => {});

// Return true
return true;

// Missing comments for complex logic
function calculateDiscount(price: number, user: User) {
  const base = price * 0.85;
  const adjusted = user.memberYears > 5 
    ? base * 0.9 
    : base * 0.95;
  return adjusted < price * 0.7 
    ? price * 0.7 
    : adjusted;
  // What are these magic numbers? Why these thresholds?
}

// No comment explaining non-obvious algorithm
function isValid(input: string) {
  return /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/.test(input);
  // What validation rules does this enforce?
}
```

**✅ GOOD**:
```typescript
// Comments explain WHY, not WHAT
function calculateDiscount(price: number, user: User) {
  // Base discount: 15% for all members
  const baseDiscount = price * 0.85;
  
  // Loyalty bonus: additional 5-10% based on membership length
  // - 5+ years: extra 10% off (total 23.5%)
  // - <5 years: extra 5% off (total 19.25%)
  const loyaltyDiscount = user.memberYears > 5 
    ? baseDiscount * 0.9 
    : baseDiscount * 0.95;
  
  // Cap maximum discount at 30% (business rule from sales team)
  const minAllowedPrice = price * 0.7;
  return loyaltyDiscount < minAllowedPrice 
    ? minAllowedPrice 
    : loyaltyDiscount;
}

// Explain regex validation rules
function isValidPassword(input: string): boolean {
  // Password requirements:
  // - At least 8 characters
  // - Must contain: uppercase, lowercase, digit, special char (@$!%*?&)
  // - OWASP recommendation for strong passwords
  const passwordPattern = /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
  return passwordPattern.test(input);
}

// Explain workarounds or non-obvious solutions
function fetchUserData(userId: string) {
  // WORKAROUND: API returns 404 for new users before profile creation
  // Treat 404 as empty profile rather than error
  return api.get(`/users/${userId}`)
    .catch(err => {
      if (err.status === 404) {
        return { id: userId, isNew: true };
      }
      throw err;
    });
}

// Document business logic decisions
function shouldSendNotification(user: User, event: Event): boolean {
  // Business rule: Only notify users with verified email
  // AND who haven't disabled notifications for this event type
  // See: https://company.atlassian.net/browse/PROJ-123
  return user.emailVerified 
    && !user.disabledNotifications.includes(event.type);
}
```

**JSDoc for public APIs**:
```typescript
/**
 * Calculates user's discount based on membership status and purchase history
 * 
 * @param price - Original product price in cents
 * @param user - User object with membership data
 * @returns Final discounted price (never below 70% of original)
 * 
 * @example
 * ```ts
 * const discountedPrice = calculateDiscount(10000, user); // $100 -> $76.50
 * ```
 */
function calculateDiscount(price: number, user: User): number {
  // Implementation...
}
```

**Violation Handling**: Add comments explaining WHY for any logic that isn't immediately obvious

**No Excuses**:
- ❌ "The code is self-documenting"
- ❌ "Good code doesn't need comments"
- ❌ "I'll remember why I wrote it"

**Enforcement**: Code review, require JSDoc for public APIs, document complex algorithms

---

### 4. NO INCONSISTENT CODE FORMATTING (USE AUTO-FORMATTER)

**❌ BAD**:
```typescript
// Inconsistent indentation (mix of 2/4 spaces, tabs)
function example() {
  if (condition) {
      doSomething();  // 4 spaces
    doOther();      // 2 spaces
  }
}

// Inconsistent quotes
const name = "John";
const age = '30';
const city = `Boston`;

// Inconsistent semicolons
const a = 1;
const b = 2
const c = 3;

// Inconsistent spacing
const obj={key:value,another:data};
function test(a,b,c){
  return a+b+c;
}

// Inconsistent line breaks
const longArray = [item1, item2, item3,
  item4, item5, item6, item7,
item8, item9];
```

**✅ GOOD**:
```typescript
// Consistent formatting (auto-formatted with Prettier)

// Consistent 2-space indentation
function example() {
  if (condition) {
    doSomething();
    doOther();
  }
}

// Consistent single quotes (project convention)
const name = 'John';
const age = '30';
const city = 'Boston';

// Consistent semicolons (present or absent, not mixed)
const a = 1;
const b = 2;
const c = 3;

// Consistent spacing
const obj = { key: value, another: data };
function test(a, b, c) {
  return a + b + c;
}

// Consistent line breaks (Prettier handles this)
const longArray = [
  item1,
  item2,
  item3,
  item4,
  item5,
  item6,
  item7,
  item8,
  item9,
];
```

**Prettier Configuration** (`.prettierrc`):
```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 80,
  "arrowParens": "avoid"
}
```

**ESLint Integration** (`.eslintrc.js`):
```javascript
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'prettier' // Must be last
  ],
  plugins: ['@typescript-eslint', 'prettier'],
  rules: {
    'prettier/prettier': 'error'
  }
};
```

**Pre-commit Hook** (Husky + lint-staged):
```json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": [
      "prettier --write",
      "eslint --fix"
    ]
  }
}
```

**Violation Handling**: Run `prettier --write .` on entire codebase, enforce with pre-commit hooks

**No Excuses**:
- ❌ "Formatting doesn't affect functionality"
- ❌ "I prefer my own style"
- ❌ "It's too much effort to set up"

**Enforcement**: Prettier + ESLint, pre-commit hooks, CI checks

---

### 5. NO UNDOCUMENTED PUBLIC APIs (JSDOC REQUIRED)

**❌ BAD**:
```typescript
// No documentation
export function processOrder(order, options) {
  // Complex logic...
  return result;
}

// Minimal documentation (not useful)
/**
 * Process order
 */
export function processOrder(order: Order, options: Options) {
  // What does this return? What options are available?
}

// Missing parameter descriptions
/**
 * Creates a new user
 */
export function createUser(data: UserData) {
  // What fields are required in UserData?
}

// No examples
export class PaymentProcessor {
  process(amount: number, method: string) {
    // How do I use this? What payment methods are supported?
  }
}
```

**✅ GOOD**:
```typescript
/**
 * Processes an order with optional payment and shipping customization
 * 
 * @param order - Order object containing items, customer info, and pricing
 * @param options - Processing options
 * @param options.paymentMethod - Payment method ('card' | 'paypal' | 'crypto')
 * @param options.expedited - Whether to use expedited shipping (default: false)
 * @param options.giftWrap - Add gift wrapping (default: false)
 * 
 * @returns Processed order with tracking number and estimated delivery
 * 
 * @throws {ValidationError} If order data is invalid
 * @throws {PaymentError} If payment processing fails
 * 
 * @example
 * ```ts
 * const result = await processOrder(order, {
 *   paymentMethod: 'card',
 *   expedited: true
 * });
 * console.log(`Order ${result.trackingNumber} will arrive on ${result.estimatedDelivery}`);
 * ```
 */
export async function processOrder(
  order: Order,
  options: ProcessOrderOptions
): Promise<ProcessedOrder> {
  // Implementation...
}

/**
 * Creates a new user account with email verification
 * 
 * @param data - User registration data
 * @param data.email - User's email (must be unique)
 * @param data.password - Password (min 8 chars, must include uppercase, number, special char)
 * @param data.name - Full name (2-100 characters)
 * @param data.phoneNumber - Optional phone for 2FA
 * 
 * @returns Created user object (password field omitted)
 * 
 * @throws {ValidationError} If email/password don't meet requirements
 * @throws {DuplicateEmailError} If email already exists
 * 
 * @example
 * ```ts
 * const user = await createUser({
 *   email: 'john@example.com',
 *   password: 'SecureP@ss123',
 *   name: 'John Doe',
 *   phoneNumber: '+1234567890'
 * });
 * ```
 */
export async function createUser(data: UserData): Promise<User> {
  // Implementation...
}

/**
 * Payment processor supporting multiple payment methods
 * 
 * @example
 * ```ts
 * const processor = new PaymentProcessor(config);
 * 
 * // Credit card payment
 * const result = await processor.process(1000, 'card', {
 *   cardNumber: '4242424242424242',
 *   expiry: '12/25',
 *   cvv: '123'
 * });
 * 
 * // PayPal payment
 * const result = await processor.process(1000, 'paypal', {
 *   paypalEmail: 'user@paypal.com'
 * });
 * ```
 */
export class PaymentProcessor {
  /**
   * Process a payment transaction
   * 
   * @param amount - Amount in cents (e.g., 1000 = $10.00)
   * @param method - Payment method ('card' | 'paypal' | 'crypto')
   * @param details - Payment method specific details
   * 
   * @returns Transaction result with ID and status
   * 
   * @throws {PaymentError} If payment fails
   */
  async process(
    amount: number,
    method: PaymentMethod,
    details: PaymentDetails
  ): Promise<TransactionResult> {
    // Implementation...
  }
}

/**
 * Type definitions for public API
 */
export interface ProcessOrderOptions {
  /** Payment method to use */
  paymentMethod: 'card' | 'paypal' | 'crypto';
  /** Use expedited shipping (additional cost) */
  expedited?: boolean;
  /** Add gift wrapping (additional cost) */
  giftWrap?: boolean;
}

export interface ProcessedOrder {
  /** Unique tracking number */
  trackingNumber: string;
  /** Estimated delivery date (ISO 8601) */
  estimatedDelivery: string;
  /** Total cost including fees */
  totalCost: number;
}
```

**Violation Handling**: Add JSDoc to ALL exported functions, classes, and interfaces before merging

**No Excuses**:
- ❌ "The types are self-explanatory"
- ❌ "Users can read the code"
- ❌ "JSDoc is too verbose"

**Enforcement**: ESLint `jsdoc/require-jsdoc`, CI checks, documentation generation (TypeDoc)

---

## Implementation Details (Original ECC Domain Knowledge)

### Project-Level Standards

#### .editorconfig
```ini
# EditorConfig for consistent coding styles
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{js,ts,jsx,tsx}]
indent_style = space
indent_size = 2

[*.{json,yml,yaml}]
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false
```

#### ESLint Configuration
```javascript
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'prettier'
  ],
  plugins: ['@typescript-eslint', 'react', 'import', 'jsdoc'],
  rules: {
    // Naming conventions
    '@typescript-eslint/naming-convention': [
      'error',
      {
        selector: 'variable',
        format: ['camelCase', 'UPPER_CASE']
      },
      {
        selector: 'function',
        format: ['camelCase']
      },
      {
        selector: 'typeLike',
        format: ['PascalCase']
      }
    ],
    
    // No magic numbers
    'no-magic-numbers': ['warn', {
      ignore: [0, 1, -1],
      ignoreArrayIndexes: true
    }],
    
    // Require JSDoc for exports
    'jsdoc/require-jsdoc': ['error', {
      require: {
        FunctionDeclaration: true,
        ClassDeclaration: true,
        MethodDefinition: true
      },
      publicOnly: true
    }],
    
    // Import order
    'import/order': ['error', {
      groups: [
        'builtin',
        'external',
        'internal',
        'parent',
        'sibling',
        'index'
      ],
      'newlines-between': 'always',
      alphabetize: { order: 'asc' }
    }]
  }
};
```

### File Organization

```
src/
├── components/          # React components
│   ├── common/          # Reusable components
│   ├── features/        # Feature-specific components
│   └── layouts/         # Layout components
├── hooks/               # Custom React hooks
├── services/            # API clients, business logic
├── utils/               # Pure utility functions
├── types/               # TypeScript type definitions
├── constants/           # Application constants
├── config/              # Configuration files
└── tests/               # Test files (mirror src structure)
```

### Documentation Standards

**README.md Structure**:
```markdown
# Project Name

Brief description

## Installation
## Usage
## API Reference
## Contributing
## License
```

**CHANGELOG.md** (Keep a Changelog format):
```markdown
# Changelog

## [Unreleased]
### Added
### Changed
### Fixed

## [1.0.0] - 2024-01-01
### Added
- Initial release
```

---

## OpenCode Integration

### When to Use This Skill

**Auto-load when detecting**:
- Code style inconsistencies ("format", "style", "inconsistent")
- Missing documentation ("no docs", "undocumented API")
- Magic numbers/strings ("magic value", "hardcoded")
- Naming issues ("confusing name", "inconsistent naming")

**Manual invocation**:
```
@use coding-standards
User: "Review code style consistency"
```

### Workflow Integration

**1. Initial setup**:
```bash
# Install tools
npm install --save-dev eslint prettier husky lint-staged

# Initialize configs
npx eslint --init
echo "{}" > .prettierrc

# Set up pre-commit hooks
npx husky install
```

**2. Apply standards**:
```bash
# Format entire codebase
npm run format

# Fix linting issues
npm run lint:fix

# Check for violations
npm run lint
```

**3. Enforce in CI**:
```yaml
# .github/workflows/ci.yml
- name: Check code style
  run: npm run lint
  
- name: Check formatting
  run: npx prettier --check .
```

### Skills Combination

**Works well with**:
- `backend-patterns` - Async naming, error class names
- `frontend-patterns` - Component naming, prop naming
- `test-driven-development` - Test file naming
- `api-design` - API endpoint naming

**Example workflow**:
```
1. @use coding-standards → Establish conventions
2. @use frontend-patterns → Apply React-specific standards
3. @use test-driven-development → Add tests following naming conventions
4. @use verification-before-completion → Verify consistency
```

---

## Verification Checklist

Before marking coding standards complete:

- [ ] Naming conventions documented and consistent
- [ ] No magic numbers or strings (all extracted to constants)
- [ ] Complex logic has explanatory comments (WHY, not WHAT)
- [ ] Auto-formatter configured (Prettier)
- [ ] Public APIs have JSDoc documentation
- [ ] ESLint configured with appropriate rules
- [ ] Pre-commit hooks prevent bad commits
- [ ] CI checks enforce standards
- [ ] .editorconfig present for editor consistency
- [ ] CONTRIBUTING.md documents standards

**Code quality metrics**:
- Zero ESLint errors
- Zero Prettier formatting issues
- 100% JSDoc coverage for public APIs
- Consistent naming across codebase
- No magic numbers in production code

---

**This skill enforces maintainable coding practices with zero tolerance for inconsistency, undocumented APIs, and magic values.**
