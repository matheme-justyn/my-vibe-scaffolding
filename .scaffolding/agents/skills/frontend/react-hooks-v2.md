---
name: react-hooks
version: 2.0.0
description: React Hooks patterns with Iron Laws enforcement - useState, useEffect, useMemo, useCallback, custom hooks, and performance optimization.
origin: ECC-derived (extracted from frontend-patterns)
adapted_for: OpenCode
transformation: Superpowers Iron Laws integration
---

# React Hooks Patterns v2.0

## Iron Laws (Superpowers Style)

### 1. NO MISSING USEEFFECT DEPENDENCIES

**❌ BAD**:
```typescript
// Missing userId in dependency array
useEffect(() => {
  fetchUser(userId)
}, [])

// Missing all external dependencies
const config = { theme, locale }
useEffect(() => {
  updateConfig(config)
}, [])
```

**✅ GOOD**:
```typescript
// Complete dependency array
useEffect(() => {
  fetchUser(userId)
}, [userId])

// All dependencies included
useEffect(() => {
  updateConfig({ theme, locale })
}, [theme, locale])
```

**Violation Handling**: Add ALL referenced external values to dependency array

**No Excuses**:
- ❌ "I want it to run only once"
- ❌ "The linter is wrong"
- ❌ "Too many re-renders"

**Enforcement**: ESLint rule `react-hooks/exhaustive-deps` (NEVER disable), React Hooks linter

---

### 2. NO USEEFFECT WITHOUT CLEANUP

**❌ BAD**:
```typescript
// Event listener without cleanup
useEffect(() => {
  window.addEventListener('scroll', handleScroll)
}, [])

// Subscription without cleanup
useEffect(() => {
  const sub = subscribeToData()
}, [])

// Timer without cleanup
useEffect(() => {
  setInterval(() => setCount(c => c + 1), 1000)
}, [])
```

**✅ GOOD**:
```typescript
// Event listener WITH cleanup
useEffect(() => {
  window.addEventListener('scroll', handleScroll)
  return () => window.removeEventListener('scroll', handleScroll)
}, [])

// Subscription WITH cleanup
useEffect(() => {
  const sub = subscribeToData()
  return () => sub.unsubscribe()
}, [])

// Timer WITH cleanup
useEffect(() => {
  const interval = setInterval(() => setCount(c => c + 1), 1000)
  return () => clearInterval(interval)
}, [])
```

**Violation Handling**: Add cleanup function that reverses the side effect

**No Excuses**:
- ❌ "Component never unmounts"
- ❌ "Cleanup isn't necessary"
- ❌ "I'll add it later"

**Enforcement**: Code review, memory leak detection tools, React DevTools Profiler

---

### 3. NO DIRECT STATE MUTATIONS IN USESTATE

**❌ BAD**:
```typescript
// Direct mutation (doesn't trigger re-render)
const [user, setUser] = useState({ name: '', email: '' })
user.name = 'John'

// Array push (mutation)
const [items, setItems] = useState([])
items.push(newItem)
setItems(items)

// Nested object mutation
const [form, setForm] = useState({ profile: { name: '' } })
form.profile.name = 'John'
```

**✅ GOOD**:
```typescript
// Immutable update
const [user, setUser] = useState({ name: '', email: '' })
setUser({ ...user, name: 'John' })

// Array concat/spread
const [items, setItems] = useState([])
setItems([...items, newItem])

// Nested immutable update (or use Immer)
const [form, setForm] = useState({ profile: { name: '' } })
setForm({
  ...form,
  profile: {
    ...form.profile,
    name: 'John'
  }
})
```

**Violation Handling**: Replace mutations with immutable updates, use spread operator or Immer

**No Excuses**:
- ❌ "Mutation is faster"
- ❌ "It's just one property"
- ❌ "I'll spread it afterward"

**Enforcement**: ESLint rule `no-param-reassign`, TypeScript readonly types, Immer library

---

### 4. NO USEMEMO/USECALLBACK FOR CHEAP OPERATIONS

**❌ BAD**:
```typescript
// Memoizing trivial computation (overhead > benefit)
const doubled = useMemo(() => value * 2, [value])
const sum = useMemo(() => a + b, [a, b])

// useCallback without memoized child
const handleClick = useCallback(() => {
  console.log('clicked')
}, [])

return <div onClick={handleClick}>Not Memoized</div>
```

**✅ GOOD**:
```typescript
// Memoizing expensive computation
const expensiveResult = useMemo(() => {
  return heavyComputation(data)  // Complex algorithm
}, [data])

// useCallback WITH React.memo child
const MemoizedChild = React.memo(Child)

const handleClick = useCallback(() => {
  doSomething()
}, [])

return <MemoizedChild onClick={handleClick} />
```

**Violation Handling**: Remove useMemo/useCallback for trivial operations, only use for expensive computations or preventing child re-renders

**No Excuses**:
- ❌ "Memoization is always good"
- ❌ "It doesn't hurt to memo everything"
- ❌ "Premature optimization is fine"

**Enforcement**: Performance profiling (React DevTools Profiler), code review

---

### 5. NO ASYNC USEEFFECT WITHOUT CANCELLATION

**❌ BAD**:
```typescript
// Race condition - state update after unmount
useEffect(() => {
  async function loadData() {
    const data = await fetchData()
    setData(data)  // Might run after unmount
  }
  loadData()
}, [])

// Multiple async calls without cancellation
useEffect(() => {
  fetchUser(userId).then(setUser)
  fetchPosts(userId).then(setPosts)
}, [userId])
```

**✅ GOOD**:
```typescript
// Cancellation flag
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
    cancelled = true
  }
}, [])

// AbortController for fetch
useEffect(() => {
  const controller = new AbortController()
  
  async function loadData() {
    try {
      const data = await fetch('/api/data', {
        signal: controller.signal
      })
      setData(data)
    } catch (err) {
      if (err.name !== 'AbortError') throw err
    }
  }
  
  loadData()
  
  return () => controller.abort()
}, [])
```

**Violation Handling**: Add cancellation flag or AbortController to ALL async effects

**No Excuses**:
- ❌ "Effect rarely completes after unmount"
- ❌ "Race condition is unlikely"
- ❌ "Console warning is fine"

**Enforcement**: React strict mode, console warning detection, E2E tests

---

## Implementation Details (Original ECC)

### Core Hooks

#### useState - Component State

```typescript
// ✅ Immutable updates
setUser({ ...user, name: 'John' })

// ✅ Functional updates (when depending on previous state)
const [count, setCount] = useState(0)
setCount(prev => prev + 1)  // Safer than setCount(count + 1)

// ✅ Lazy initialization (expensive computation)
const [data, setData] = useState(() => {
  return expensiveComputation()  // Only runs on mount
})
```

#### useEffect - Side Effects

```typescript
// ✅ Complete dependencies
useEffect(() => {
  fetchUser(userId)
}, [userId])

// ✅ Cleanup function
useEffect(() => {
  const subscription = subscribeToData()
  
  return () => {
    subscription.unsubscribe()
  }
}, [])

// ✅ Conditional effects
useEffect(() => {
  if (!userId) return
  
  fetchUser(userId)
}, [userId])

// ✅ Async effects with cancellation
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
    cancelled = true
  }
}, [])
```

#### useMemo - Memoized Values

```typescript
// ✅ Memoizing expensive computations
const expensiveResult = useMemo(() => {
  return heavyComputation(data)
}, [data])

// ✅ Memoizing object/array identity
const config = useMemo(() => ({
  userId,
  theme,
  locale
}), [userId, theme, locale])

// ✅ Filtering/sorting large lists
const filteredItems = useMemo(() => {
  return items
    .filter(item => item.status === 'active')
    .sort((a, b) => b.priority - a.priority)
}, [items])
```

#### useCallback - Memoized Functions

```typescript
// ✅ Preventing child re-renders
const MemoizedChild = React.memo(Child)

function Parent() {
  const [count, setCount] = useState(0)
  
  const handleChildClick = useCallback(() => {
    setCount(c => c + 1)
  }, [])
  
  return <MemoizedChild onClick={handleChildClick} />
}

// ✅ Stable function reference for dependencies
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

#### useRef - Mutable References

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
    countRef.current++
    forceUpdate({})
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

### Custom Hooks Patterns

#### Data Fetching Hook

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

#### Form Hook

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

#### Local Storage Hook

```typescript
function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch (error) {
      console.error('Error reading from localStorage:', error)
      return initialValue
    }
  })
  
  const setValue = useCallback((value: T | ((val: T) => T)) => {
    try {
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

#### Debounce Hook

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

### Performance Optimization

#### Avoiding Unnecessary Re-renders

```typescript
// ✅ Memoized object
function GoodComponent({ userId }: Props) {
  const config = useMemo(() => ({
    userId,
    theme: 'dark'
  }), [userId])
  
  return <ExpensiveChild config={config} />
}

// ✅ React.memo + stable props
const MemoizedChild = React.memo(ExpensiveChild)

function BetterComponent({ userId }: Props) {
  const config = useMemo(() => ({
    userId,
    theme: 'dark'
  }), [userId])
  
  return <MemoizedChild config={config} />
}
```

#### Lazy Loading

```typescript
import { lazy, Suspense } from 'react'

const HeavyComponent = lazy(() => import('./HeavyComponent'))

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HeavyComponent />
    </Suspense>
  )
}
```

### Common Pitfalls

#### ❌ Infinite Loops

```typescript
// GOOD: Memoized dependency
const config = useMemo(() => ({ userId }), [userId])
useEffect(() => {
  fetchData(config)
}, [config])
```

#### ❌ Stale Closures

```typescript
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

### Testing Hooks

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

### Quick Checklist

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
- [ ] All Iron Laws violations resolved

---

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
- `component-design` - Component composition

---

**Remember**: These Iron Laws prevent the most common React Hooks issues - missing dependencies, memory leaks, stale closures, and performance problems. No exceptions.
