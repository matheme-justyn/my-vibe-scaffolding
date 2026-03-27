---
name: unit-testing
description: Unit testing patterns with Jest/Vitest including test structure, mocking, assertions, and test organization for frontend and backend code.
origin: ECC-derived (extracted from tdd-workflow and backend-patterns)
adapted_for: OpenCode
---

# Unit Testing Patterns

## OpenCode Integration

**When to Use**:
- Testing individual functions and utilities
- Testing component logic
- Testing pure functions
- Implementing TDD workflow

**Load this skill when**:
- User mentions "unit test", "Jest", "Vitest", "testing"
- Writing tests for functions/components
- Implementing test coverage

**Usage Pattern**:
```typescript
@use unit-testing
User: "Write unit tests for utility functions"
```

**Combines well with**:
- `tdd-workflow` - Test-driven development workflow
- `react-hooks` - Testing hooks

---

## Overview

Unit testing patterns for comprehensive test coverage.

## Test Structure

### AAA Pattern (Arrange-Act-Assert)

```typescript
describe('calculateTotal', () => {
  it('calculates total with tax', () => {
    // Arrange
    const items = [
      { price: 10, quantity: 2 },
      { price: 5, quantity: 1 }
    ]
    const taxRate = 0.1
    
    // Act
    const result = calculateTotal(items, taxRate)
    
    // Assert
    expect(result).toBe(27.5)  // (20 + 5) * 1.1
  })
})
```

### Testing Edge Cases

```typescript
describe('divide', () => {
  it('divides positive numbers', () => {
    expect(divide(10, 2)).toBe(5)
  })
  
  it('divides negative numbers', () => {
    expect(divide(-10, 2)).toBe(-5)
  })
  
  it('returns Infinity for division by zero', () => {
    expect(divide(10, 0)).toBe(Infinity)
  })
  
  it('handles decimal results', () => {
    expect(divide(5, 2)).toBe(2.5)
  })
})
```

## Mocking

### Jest Mocks

```typescript
// Mock function
const mockCallback = jest.fn()
mockCallback('test')
expect(mockCallback).toHaveBeenCalledWith('test')

// Mock module
jest.mock('./api', () => ({
  fetchUser: jest.fn().mockResolvedValue({ id: 1, name: 'Test' })
}))

// Mock implementation
const mockFetch = jest.fn()
mockFetch.mockImplementation(() => Promise.resolve({ data: 'test' }))
```

### Testing Async Code

```typescript
describe('fetchUser', () => {
  it('fetches user successfully', async () => {
    const user = await fetchUser('123')
    expect(user).toEqual({ id: '123', name: 'John' })
  })
  
  it('handles errors', async () => {
    await expect(fetchUser('invalid')).rejects.toThrow('User not found')
  })
})
```

## Component Testing

```typescript
import { render, screen, fireEvent } from '@testing-library/react'

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })
  
  it('calls onClick when clicked', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click</Button>)
    
    fireEvent.click(screen.getByRole('button'))
    
    expect(handleClick).toHaveBeenCalledTimes(1)
  })
  
  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })
})
```

## Best Practices

- **Test behavior, not implementation**: Test what the code does, not how
- **One assertion per test**: Focus on single behavior
- **Descriptive test names**: "it('returns error when email is invalid')"
- **Mock external dependencies**: Database, API calls, file system
- **Test edge cases**: Null, undefined, empty arrays, boundary values
- **Fast tests**: Unit tests should run in milliseconds
- **Deterministic**: Same input → same output, every time

## Quick Checklist

- [ ] Tests follow AAA pattern
- [ ] Edge cases covered
- [ ] Async code tested properly
- [ ] Mocks used for external dependencies
- [ ] Test names descriptive
- [ ] One assertion per test
- [ ] Tests run fast (< 1s for entire suite)
- [ ] Coverage > 80%

## Resources

- [Jest Documentation](https://jestjs.io/)
- [Testing Library](https://testing-library.com/)
- [Vitest Guide](https://vitest.dev/guide/)
