---
name: react-hooks
description: React Hooks patterns including useState, useEffect, useMemo, useCallback, custom hooks, and performance optimization techniques.
origin: ECC-derived (extracted from frontend-patterns)
adapted_for: OpenCode
---

# React Hooks Patterns

## OpenCode Integration

**When to Use**:
- Building functional React components
- Managing component state and effects
- Optimizing re-renders
- Creating custom hooks
- Refactoring class components to hooks

**Load this skill when**:
- User mentions "hooks", "useState", "useEffect", "React"
- Creating stateful components
- Performance optimization needed

**Usage Pattern**:
```typescript
// Automatically loaded when AGENTS.md detects React hooks keywords
// Or manually load:
@use react-hooks
User: "Implement a data fetching hook with caching"
```

**Combines well with**:
- `frontend-patterns` - Overall React architecture
- `state-management` - Global state patterns

---

## Overview

React Hooks patterns for modern functional components.

## Core Hooks

### useState - Component State

```typescript
// ❌ BAD: Direct state mutation
const [user, setUser] = useState({ name: '', email: '' })
user.name = 'John'  // Doesn't trigger re-render

// ✅ GOOD: Immutable updates
setUser({ ...user, name: 'John' })

// ✅ GOOD: Functional updates (when depending on previous state)
const [count, setCount] = useState(0)
setCount(prev => prev + 1)  // Safer than setCount(count + 1)

// ✅ GOOD: Lazy initialization (expensive computation)
const [data, setData] = useState(() => {
  return expensiveComputation()  // Only runs on mount
})
```

### useEffect - Side Effects

```typescript
// ❌ BAD: Missing dependencies
useEffect(() => {
  fetchUser(userId)  // userId not in deps array
}, [])

// ✅ GOOD: Complete dependencies
useEffect(() => {
  fetchUser(userId)
}, [userId])

// ✅ GOOD: Cleanup function
useEffect(() => {
  const subscription = subscribeToData()
  
  return () => {
    subscription.unsubscribe()  // Cleanup on unmount
  }
}, [])

// ✅ GOOD: Conditional effects
useEffect(() => {
  if (!userId) return  // Guard clause
  
  fetchUser(userId)
}, [userId])

// ✅ GOOD: Async effects
useEffect(() => {
  let cancelled = false
  
  async function loadData() {
    const data = await fetchData()
    if (!cancelled) {
      setData(data)
    }
  }
  
  loadData()
  
  return () => {
    cancelled = true  // Prevent state updates if unmounted
  }
}, [])
```

### useMemo - Memoized Values

```typescript
// ❌ BAD: Memoizing cheap computations (overhead > benefit)
const doubled = useMemo(() => value * 2, [value])

// ✅ GOOD: Memoizing expensive computations
const expensiveResult = useMemo(() => {
  return heavyComputation(data)
}, [data])

// ✅ GOOD: Memoizing object/array identity
const config = useMemo(() => ({
  userId,
  theme,
  locale
}), [userId, theme, locale])

// ✅ GOOD: Filtering/sorting large lists
const filteredItems = useMemo(() => {
  return items
    .filter(item => item.status === 'active')
    .sort((a, b) => b.priority - a.priority)
}, [items])
```

### useCallback - Memoized Functions

```typescript
// ❌ BAD: Unnecessary useCallback (no benefit)
const handleClick = useCallback(() => {
  console.log('clicked')
}, [])

// ✅ GOOD: Preventing child re-renders
const MemoizedChild = React.memo(Child)

function Parent() {
  const [count, setCount] = useState(0)
  
  // Without useCallback, creates new function on every render
  const handleChildClick = useCallback(() => {
    setCount(c => c + 1)
  }, [])  // MemoizedChild won't re-render unnecessarily
  
  return <MemoizedChild onClick={handleChildClick} />
}

// ✅ GOOD: Stable function reference for dependencies
function useDebounce(value, delay) {
  const [debouncedValue, setDebouncedValue] = useState(value)
  
  const updateValue = useCallback(() => {
    setDebouncedValue(value)
  }, [value])
  
  useEffect(() => {
    const timeout = setTimeout(updateValue, delay)
    return () => clearTimeout(timeout)
  }, [updateValue, delay])
  
  return debouncedValue
}
```

### useRef - Mutable References

```typescript
// ✅ Accessing DOM elements
function Input() {
  const inputRef = useRef<HTMLInputElement>(null)
  
  useEffect(() => {
    inputRef.current?.focus()
  }, [])
  
  return <input ref={inputRef} />
}

// ✅ Storing mutable values (doesn't trigger re-render)
function Counter() {
  const countRef = useRef(0)
  const [, forceUpdate] = useState({})
  
  function increment() {
    countRef.current++  // Doesn't trigger re-render
    forceUpdate({})  // Manually trigger re-render
  }
  
  return <button onClick={increment}>{countRef.current}</button>
}

// ✅ Storing previous values
function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>()
  
  useEffect(() => {
    ref.current = value
  }, [value])
  
  return ref.current
}
```

## Custom Hooks Patterns

### Data Fetching Hook

```typescript
interface UseDataOptions<T> {
  initialData?: T
  onSuccess?: (data: T) => void
  onError?: (error: Error) => void
}

function useData<T>(
  fetcher: () => Promise<T>,
  deps: any[],
  options: UseDataOptions<T> = {}
) {
  const [data, setData] = useState<T | undefined>(options.initialData)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<Error | null>(null)
  
  useEffect(() => {
    let cancelled = false
    
    async function loadData() {
      setLoading(true)
      setError(null)
      
      try {
        const result = await fetcher()
        
        if (!cancelled) {
          setData(result)
          options.onSuccess?.(result)
        }
      } catch (err) {
        if (!cancelled) {
          const error = err as Error
          setError(error)
          options.onError?.(error)
        }
      } finally {
        if (!cancelled) {
          setLoading(false)
        }
      }
    }
    
    loadData()
    
    return () => {
      cancelled = true
    }
  }, deps)
  
  return { data, loading, error }
}

// Usage
function UserProfile({ userId }: { userId: string }) {
  const { data: user, loading, error } = useData(
    () => fetchUser(userId),
    [userId],
    {
      onSuccess: (user) => console.log('Loaded:', user.name),
      onError: (error) => console.error('Failed:', error)
    }
  )
  
  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>
  if (!user) return null
  
  return <div>{user.name}</div>
}
```

### Form Hook

```typescript
function useForm<T extends Record<string, any>>(initialValues: T) {
  const [values, setValues] = useState(initialValues)
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({})
  const [touched, setTouched] = useState<Partial<Record<keyof T, boolean>>>({})
  
  const handleChange = useCallback((name: keyof T, value: any) => {
    setValues(prev => ({ ...prev, [name]: value }))
  }, [])
  
  const handleBlur = useCallback((name: keyof T) => {
    setTouched(prev => ({ ...prev, [name]: true }))
  }, [])
  
  const setFieldError = useCallback((name: keyof T, error: string) => {
    setErrors(prev => ({ ...prev, [name]: error }))
  }, [])
  
  const reset = useCallback(() => {
    setValues(initialValues)
    setErrors({})
    setTouched({})
  }, [initialValues])
  
  return {
    values,
    errors,
    touched,
    handleChange,
    handleBlur,
    setFieldError,
    reset
  }
}

// Usage
function LoginForm() {
  const form = useForm({ email: '', password: '' })
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!form.values.email) {
      form.setFieldError('email', 'Email required')
      return
    }
    
    await login(form.values)
    form.reset()
  }
  
  return (
    <form onSubmit={handleSubmit}>
      <input
        value={form.values.email}
        onChange={(e) => form.handleChange('email', e.target.value)}
        onBlur={() => form.handleBlur('email')}
      />
      {form.touched.email && form.errors.email && (
        <span>{form.errors.email}</span>
      )}
      
      <button type="submit">Login</button>
    </form>
  )
}
```

### Local Storage Hook

```typescript
function useLocalStorage<T>(key: string, initialValue: T) {
  // State to store our value
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch (error) {
      console.error('Error reading from localStorage:', error)
      return initialValue
    }
  })
  
  // Return a wrapped version of useState's setter that persists to localStorage
  const setValue = useCallback((value: T | ((val: T) => T)) => {
    try {
      // Allow value to be a function for same API as useState
      const valueToStore = value instanceof Function ? value(storedValue) : value
      setStoredValue(valueToStore)
      window.localStorage.setItem(key, JSON.stringify(valueToStore))
    } catch (error) {
      console.error('Error writing to localStorage:', error)
    }
  }, [key, storedValue])
  
  return [storedValue, setValue] as const
}

// Usage
function ThemeToggle() {
  const [theme, setTheme] = useLocalStorage('theme', 'light')
  
  return (
    <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
      Current theme: {theme}
    </button>
  )
}
```

### Debounce Hook

```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)
  
  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)
    
    return () => {
      clearTimeout(handler)
    }
  }, [value, delay])
  
  return debouncedValue
}

// Usage
function SearchInput() {
  const [search, setSearch] = useState('')
  const debouncedSearch = useDebounce(search, 500)
  
  useEffect(() => {
    if (debouncedSearch) {
      performSearch(debouncedSearch)
    }
  }, [debouncedSearch])
  
  return (
    <input
      value={search}
      onChange={(e) => setSearch(e.target.value)}
      placeholder="Search..."
    />
  )
}
```

## Performance Optimization

### Avoiding Unnecessary Re-renders

```typescript
// ❌ BAD: Creating new objects/arrays in render
function BadComponent({ userId }: Props) {
  // New object on every render → child re-renders
  const config = { userId, theme: 'dark' }
  
  return <ExpensiveChild config={config} />
}

// ✅ GOOD: Memoized object
function GoodComponent({ userId }: Props) {
  const config = useMemo(() => ({
    userId,
    theme: 'dark'
  }), [userId])
  
  return <ExpensiveChild config={config} />
}

// ✅ BETTER: React.memo + stable props
const MemoizedChild = React.memo(ExpensiveChild)

function BetterComponent({ userId }: Props) {
  const config = useMemo(() => ({
    userId,
    theme: 'dark'
  }), [userId])
  
  return <MemoizedChild config={config} />
}
```

### Lazy Loading

```typescript
import { lazy, Suspense } from 'react'

// Lazy load heavy components
const HeavyComponent = lazy(() => import('./HeavyComponent'))

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HeavyComponent />
    </Suspense>
  )
}
```

## Common Pitfalls

### ❌ Infinite Loops

```typescript
// BAD: Missing dependency array
useEffect(() => {
  setCount(count + 1)  // Runs on every render → infinite loop
})

// BAD: Object/array in dependency
useEffect(() => {
  fetchData(config)
}, [config])  // config is new object every render → infinite loop

// GOOD: Memoized dependency
const config = useMemo(() => ({ userId }), [userId])
useEffect(() => {
  fetchData(config)
}, [config])
```

### ❌ Stale Closures

```typescript
// BAD: Stale closure
function Counter() {
  const [count, setCount] = useState(0)
  
  useEffect(() => {
    setInterval(() => {
      setCount(count + 1)  // Always uses count = 0
    }, 1000)
  }, [])
  
  return <div>{count}</div>
}

// GOOD: Functional update
function Counter() {
  const [count, setCount] = useState(0)
  
  useEffect(() => {
    const interval = setInterval(() => {
      setCount(c => c + 1)  // Uses latest count
    }, 1000)
    
    return () => clearInterval(interval)
  }, [])
  
  return <div>{count}</div>
}
```

## Testing Hooks

```typescript
import { renderHook, act } from '@testing-library/react'

describe('useCounter', () => {
  it('increments counter', () => {
    const { result } = renderHook(() => useCounter())
    
    act(() => {
      result.current.increment()
    })
    
    expect(result.current.count).toBe(1)
  })
})

describe('useData', () => {
  it('fetches data successfully', async () => {
    const fetcher = jest.fn().mockResolvedValue({ id: 1, name: 'Test' })
    const { result, waitForNextUpdate } = renderHook(() =>
      useData(fetcher, [])
    )
    
    expect(result.current.loading).toBe(true)
    
    await waitForNextUpdate()
    
    expect(result.current.loading).toBe(false)
    expect(result.current.data).toEqual({ id: 1, name: 'Test' })
    expect(result.current.error).toBeNull()
  })
})
```

## Quick Checklist

- [ ] useEffect has complete dependency array
- [ ] Cleanup functions in useEffect
- [ ] useMemo for expensive computations only
- [ ] useCallback for functions passed to memoized children
- [ ] Functional updates when depending on previous state
- [ ] Async effects handle cancellation
- [ ] Custom hooks follow naming convention (use*)
- [ ] No infinite loops in effects
- [ ] No stale closures
- [ ] Hooks tested with @testing-library/react

## Resources

- [React Hooks Documentation](https://react.dev/reference/react)
- [usehooks.com](https://usehooks.com/) - Hook recipes
- [React Hooks FAQ](https://react.dev/learn/hooks-faq)
- [Testing Library Hooks](https://react-hooks-testing-library.com/)
