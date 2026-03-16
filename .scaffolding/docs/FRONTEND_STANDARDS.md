# Frontend Standards (前端開發標準)

**Version**: 2.2.0  
**Module**: FRONTEND_STANDARDS  
**Loading**: Conditional (`project.type = "frontend"` or `"fullstack"`)  
**Purpose**: React/Next.js/Vue development standards for modern frontend applications.

---

## Overview

This guide defines **frontend development standards** for React, Next.js, Vue, and modern JavaScript/TypeScript applications. It covers component architecture, state management, performance optimization, and best practices.

**Scope**:
- ✅ Component design patterns (composition, hooks, props)
- ✅ State management (local, global, server)
- ✅ Performance optimization (code splitting, lazy loading)
- ✅ Build configuration (Webpack, Vite, bundling)
- ❌ UI/UX design principles (see UI_UX_GUIDELINES)
- ❌ Accessibility (see ACCESSIBILITY_STANDARDS)

**Loading Trigger**: `project.type = "frontend"` OR `project.type = "fullstack"`

---

## Component Architecture

### 1. Component Structure

**Rule**: Components should be small, focused, and reusable.

✅ **DO**:
```tsx
// Good: Single responsibility, clear props
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

export function Button({ label, onClick, variant = 'primary', disabled = false }: ButtonProps) {
  return (
    <button
      className={`btn btn-${variant}`}
      onClick={onClick}
      disabled={disabled}
    >
      {label}
    </button>
  );
}
```

❌ **DON'T**:
```tsx
// Bad: Multiple responsibilities, unclear props
export function Button(props: any) {
  // Handles button, loading, tooltip, analytics all in one
  return <button {...props}>{props.children}</button>;
}
```

**Why**: Single-responsibility components are easier to test, maintain, and reuse.

### 2. File Organization

**Recommended Structure**:
```
src/
├── components/
│   ├── ui/              # Reusable UI components
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.test.tsx
│   │   │   ├── Button.stories.tsx
│   │   │   └── index.ts
│   │   └── Input/
│   ├── features/        # Feature-specific components
│   │   ├── UserProfile/
│   │   └── ProductList/
│   └── layouts/         # Layout components
│       ├── AppLayout.tsx
│       └── DashboardLayout.tsx
├── hooks/               # Custom React hooks
│   ├── useAuth.ts
│   └── useApi.ts
├── lib/                 # Utilities, helpers
│   ├── api.ts
│   └── utils.ts
├── pages/               # Route pages (Next.js) or views
└── styles/              # Global styles, themes
```

### 3. Component Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| **Presentational** | PascalCase | `<UserCard />`, `<ProductGrid />` |
| **Container** | PascalCase + Container | `<UserProfileContainer />` |
| **HOC** | `with` prefix | `withAuth()`, `withLoading()` |
| **Hooks** | `use` prefix | `useAuth()`, `useLocalStorage()` |
| **Context** | PascalCase + Context | `AuthContext`, `ThemeContext` |

---

## React Hooks Patterns

### 1. Custom Hooks for Logic Reuse

✅ **DO**:
```tsx
// Good: Extract reusable logic into custom hooks
function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged((user) => {
      setUser(user);
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  return { user, loading, isAuthenticated: !!user };
}

// Usage
function ProfilePage() {
  const { user, loading, isAuthenticated } = useAuth();
  
  if (loading) return <Spinner />;
  if (!isAuthenticated) return <Redirect to="/login" />;
  
  return <Profile user={user} />;
}
```

### 2. Effect Dependencies

✅ **DO**:
```tsx
// Good: Explicit dependencies
useEffect(() => {
  fetchData(userId);
}, [userId]);

// Good: No dependencies for mount-only effects
useEffect(() => {
  const cleanup = setupWebSocket();
  return cleanup;
}, []);
```

❌ **DON'T**:
```tsx
// Bad: Missing dependencies (eslint-plugin-react-hooks will warn)
useEffect(() => {
  fetchData(userId);
}, []); // Missing userId dependency

// Bad: Function in dependency array (creates new reference every render)
useEffect(() => {
  handleResize();
}, [handleResize]); // Should use useCallback
```

### 3. useCallback and useMemo

**Rule**: Use `useCallback` for functions passed to children, `useMemo` for expensive computations.

✅ **DO**:
```tsx
function ParentComponent() {
  const [count, setCount] = useState(0);
  
  // useCallback: Memoize callback to prevent child re-renders
  const handleClick = useCallback(() => {
    setCount(c => c + 1);
  }, []);
  
  // useMemo: Memoize expensive computation
  const expensiveValue = useMemo(() => {
    return computeExpensiveValue(count);
  }, [count]);
  
  return <ChildComponent onClick={handleClick} value={expensiveValue} />;
}
```

❌ **DON'T**:
```tsx
// Bad: Premature optimization (no child to optimize)
const handleClick = useCallback(() => setCount(c => c + 1), []); // Unnecessary

// Bad: Memoizing cheap operations
const doubled = useMemo(() => count * 2, [count]); // Too simple, not worth it
```

---

## State Management

### 1. State Placement Decision Tree

```
Is state needed by multiple routes?
├── YES → Global state (Context/Redux/Zustand)
└── NO → Is state needed by multiple components in same route?
    ├── YES → Lift to common parent
    └── NO → Keep in component (useState)
```

### 2. Local State (useState)

**Use for**: UI state, form inputs, toggles

✅ **DO**:
```tsx
function SearchBar() {
  const [query, setQuery] = useState('');
  const [showResults, setShowResults] = useState(false);
  
  return (
    <div>
      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        onFocus={() => setShowResults(true)}
      />
      {showResults && <SearchResults query={query} />}
    </div>
  );
}
```

### 3. Context API (useContext)

**Use for**: Theme, auth, i18n (infrequently changing data)

✅ **DO**:
```tsx
// Good: Split contexts by concern
const AuthContext = createContext<AuthState>(null);
const ThemeContext = createContext<ThemeState>(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  
  return (
    <AuthContext.Provider value={{ user, setUser }}>
      {children}
    </AuthContext.Provider>
  );
}

// Custom hook for easy access
export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
}
```

❌ **DON'T**:
```tsx
// Bad: Single massive context causes unnecessary re-renders
const AppContext = createContext({ user, theme, settings, cart, notifications });
```

### 4. Global State Libraries

**Zustand** (Recommended for most projects):
```tsx
// Good: Simple, minimal boilerplate
import create from 'zustand';

const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
}));

function Counter() {
  const { count, increment } = useStore();
  return <button onClick={increment}>{count}</button>;
}
```

**Redux Toolkit** (For complex state with time-travel debugging):
```tsx
import { createSlice, configureStore } from '@reduxjs/toolkit';

const counterSlice = createSlice({
  name: 'counter',
  initialState: { value: 0 },
  reducers: {
    increment: (state) => { state.value += 1; },
    decrement: (state) => { state.value -= 1; },
  },
});

export const store = configureStore({
  reducer: { counter: counterSlice.reducer },
});
```

---

## Performance Optimization

### 1. Code Splitting

✅ **DO**:
```tsx
// Good: Lazy load routes
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

### 2. Image Optimization

✅ **DO** (Next.js):
```tsx
import Image from 'next/image';

// Good: Use Next.js Image component
<Image
  src="/hero.jpg"
  alt="Hero image"
  width={800}
  height={600}
  priority // For above-the-fold images
  placeholder="blur"
  blurDataURL="data:image/..." // Low-quality placeholder
/>
```

### 3. List Virtualization

**Use for**: Long lists (100+ items)

```tsx
import { FixedSizeList } from 'react-window';

function VirtualList({ items }) {
  const Row = ({ index, style }) => (
    <div style={style}>{items[index].name}</div>
  );
  
  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {Row}
    </FixedSizeList>
  );
}
```

### 4. Memo and React.memo

✅ **DO**:
```tsx
// Good: Memoize expensive components
const ExpensiveComponent = React.memo(({ data }) => {
  // Complex rendering logic
  return <div>{processData(data)}</div>;
});

// With custom comparison
const UserCard = React.memo(
  ({ user }) => <div>{user.name}</div>,
  (prevProps, nextProps) => prevProps.user.id === nextProps.user.id
);
```

---

## TypeScript Best Practices

### 1. Component Props Types

✅ **DO**:
```tsx
// Good: Explicit prop types
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  loading?: boolean;
}

export function Button({ 
  label, 
  onClick, 
  variant = 'primary',
  size = 'md',
  disabled = false,
  loading = false 
}: ButtonProps) {
  // Implementation
}
```

### 2. Generic Components

```tsx
// Good: Reusable generic components
interface SelectProps<T> {
  options: T[];
  value: T;
  onChange: (value: T) => void;
  getLabel: (option: T) => string;
  getValue: (option: T) => string;
}

export function Select<T>({ options, value, onChange, getLabel, getValue }: SelectProps<T>) {
  return (
    <select onChange={(e) => {
      const selected = options.find(o => getValue(o) === e.target.value);
      if (selected) onChange(selected);
    }}>
      {options.map(option => (
        <option key={getValue(option)} value={getValue(option)}>
          {getLabel(option)}
        </option>
      ))}
    </select>
  );
}
```

---

## Form Handling

### 1. Controlled Components (Recommended)

✅ **DO**:
```tsx
function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validation
    const newErrors: Record<string, string> = {};
    if (!email) newErrors.email = 'Email is required';
    if (!password) newErrors.password = 'Password is required';
    
    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }
    
    // Submit
    login({ email, password });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      {errors.email && <span className="error">{errors.email}</span>}
      
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      {errors.password && <span className="error">{errors.password}</span>}
      
      <button type="submit">Login</button>
    </form>
  );
}
```

### 2. Form Libraries (For Complex Forms)

**React Hook Form** (Recommended):
```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

function LoginForm() {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(schema),
  });

  const onSubmit = (data) => login(data);

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      {errors.email && <span>{errors.email.message}</span>}
      
      <input type="password" {...register('password')} />
      {errors.password && <span>{errors.password.message}</span>}
      
      <button type="submit">Login</button>
    </form>
  );
}
```

---

## API Integration

### 1. Data Fetching Patterns

**TanStack Query (React Query)** (Recommended):
```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

function UserProfile({ userId }) {
  // Automatic caching, refetching, loading/error states
  const { data: user, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  });

  const queryClient = useQueryClient();
  
  const updateMutation = useMutation({
    mutationFn: updateUser,
    onSuccess: () => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: ['user', userId] });
    },
  });

  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <div>
      <h1>{user.name}</h1>
      <button onClick={() => updateMutation.mutate({ ...user, name: 'New Name' })}>
        Update
      </button>
    </div>
  );
}
```

### 2. Server State vs Client State

| Type | Examples | Tool |
|------|----------|------|
| **Server State** | User data, products, posts | React Query, SWR |
| **Client State** | UI toggles, form inputs, theme | useState, Context |

**Rule**: Don't store server data in useState/Context — use React Query/SWR.

---

## Testing

### 1. Component Testing (React Testing Library)

✅ **DO**:
```tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('renders with label', () => {
    render(<Button label="Click me" onClick={() => {}} />);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn();
    render(<Button label="Click" onClick={handleClick} />);
    
    fireEvent.click(screen.getByText('Click'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button label="Click" onClick={() => {}} disabled />);
    expect(screen.getByText('Click')).toBeDisabled();
  });
});
```

### 2. Hook Testing

```tsx
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('increments counter', () => {
    const { result } = renderHook(() => useCounter());
    
    expect(result.current.count).toBe(0);
    
    act(() => {
      result.current.increment();
    });
    
    expect(result.current.count).toBe(1);
  });
});
```

---

## Build Configuration

### 1. Vite Configuration (Recommended for New Projects)

```ts
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
    },
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom'],
        },
      },
    },
  },
});
```

### 2. Next.js Configuration

```js
// next.config.js
module.exports = {
  reactStrictMode: true,
  swcMinify: true,
  images: {
    domains: ['cdn.example.com'],
  },
  i18n: {
    locales: ['en', 'zh-TW', 'ja'],
    defaultLocale: 'en',
  },
};
```

---

## Anti-Patterns to Avoid

| ❌ Anti-Pattern | ✅ Better Approach |
|----------------|-------------------|
| Prop drilling (passing props 5+ levels) | Use Context or state management |
| Massive components (500+ lines) | Split into smaller components |
| useState for server data | Use React Query/SWR |
| useEffect for derived state | Use useMemo or plain variables |
| Premature optimization | Profile first, optimize bottlenecks |
| Inline arrow functions in JSX | Extract to useCallback if causing re-renders |
| Any type in TypeScript | Explicit types |

---

## Tools & Resources

**Essential Tools**:
- **React Developer Tools**: Browser extension for debugging
- **TanStack Query Devtools**: Inspect query cache
- **Why Did You Render**: Find unnecessary re-renders
- **Lighthouse**: Performance auditing

**Recommended Libraries**:
- **State**: Zustand, Redux Toolkit
- **Forms**: React Hook Form
- **Data Fetching**: TanStack Query
- **Styling**: Tailwind CSS, Styled Components
- **Testing**: React Testing Library, Vitest
- **Build**: Vite, Next.js

**References**:
- [React Docs (beta)](https://react.dev/)
- [Next.js Documentation](https://nextjs.org/docs)
- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)

---

## Module Dependencies

**Required Modules**:
- STYLE_GUIDE - Universal code conventions
- GIT_WORKFLOW - Version control practices

**Related Modules**:
- UI_UX_GUIDELINES - Design principles
- ACCESSIBILITY_STANDARDS - WCAG compliance
- PERFORMANCE_OPTIMIZATION - Advanced optimization
- I18N_GUIDE - Internationalization

**Terminology**:
- See `.scaffolding/docs/terminology/software/frontend.md`
