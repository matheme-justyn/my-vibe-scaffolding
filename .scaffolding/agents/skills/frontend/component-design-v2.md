---
name: component-design
version: 2.0.0
description: React component design with Iron Laws enforcement - composition patterns, prop patterns, children patterns, render props, compound components, and single responsibility principles.
origin: ECC-derived (frontend expertise)
adapted_for: OpenCode
transformation: Superpowers Iron Laws integration
---

# Component Design Patterns v2.0

## Iron Laws (Superpowers Style)

### 1. NO GOD COMPONENTS (MAX 300 LINES, SINGLE RESPONSIBILITY)

**❌ BAD**:
```tsx
// 800-line component doing everything
function UserDashboard() {
  // Authentication logic
  const [user, setUser] = useState(null);
  useEffect(() => { /* auth check */ }, []);
  
  // Data fetching
  const [orders, setOrders] = useState([]);
  const [products, setProducts] = useState([]);
  useEffect(() => { /* fetch orders */ }, []);
  useEffect(() => { /* fetch products */ }, []);
  
  // Form handling
  const [formData, setFormData] = useState({});
  const handleSubmit = () => { /* validation, API call */ };
  
  // UI state
  const [activeTab, setActiveTab] = useState('orders');
  const [modalOpen, setModalOpen] = useState(false);
  
  // Business logic
  const calculateTotal = () => { /* complex calculation */ };
  const applyDiscount = () => { /* discount logic */ };
  
  return (
    <div>
      {/* 500 lines of JSX */}
      <Header user={user} />
      <Sidebar />
      <TabPanel>
        <OrdersList orders={orders} />
        <ProductsList products={products} />
      </TabPanel>
      <Modal isOpen={modalOpen}>
        <Form onSubmit={handleSubmit} />
      </Modal>
    </div>
  );
}
```

**✅ GOOD**:
```tsx
// Split into focused components (each < 150 lines)

// Container: Orchestration only
function UserDashboardContainer() {
  const { user } = useAuth(); // Custom hook
  const { orders } = useOrders(user?.id); // Custom hook
  const { products } = useProducts(); // Custom hook
  
  return (
    <DashboardLayout user={user}>
      <OrdersTab orders={orders} />
      <ProductsTab products={products} />
    </DashboardLayout>
  );
}

// Custom hooks: Data fetching
function useOrders(userId: number) {
  const [orders, setOrders] = useState([]);
  useEffect(() => {
    if (!userId) return;
    fetchOrders(userId).then(setOrders);
  }, [userId]);
  return { orders };
}

// Presentational: UI only
function OrdersTab({ orders }: { orders: Order[] }) {
  const [activeOrder, setActiveOrder] = useState<Order | null>(null);
  
  return (
    <>
      <OrdersList 
        orders={orders} 
        onSelectOrder={setActiveOrder} 
      />
      {activeOrder && (
        <OrderDetailsModal 
          order={activeOrder}
          onClose={() => setActiveOrder(null)}
        />
      )}
    </>
  );
}

// Dumb component: Pure display
function OrdersList({ orders, onSelectOrder }: OrdersListProps) {
  return (
    <ul>
      {orders.map(order => (
        <OrderItem 
          key={order.id} 
          order={order} 
          onClick={() => onSelectOrder(order)}
        />
      ))}
    </ul>
  );
}
```

**Violation Handling**: Split any component > 300 lines into smaller components, extract logic to custom hooks

**No Excuses**:
- ❌ "It's all related functionality"
- ❌ "Splitting makes it harder to follow"
- ❌ "I'll refactor later"

**Enforcement**: ESLint rule `max-lines` (300), code review, component size metrics

---

### 2. NO PROP DRILLING BEYOND 2 LEVELS

**❌ BAD**:
```tsx
// Prop drilling through 5 levels
function App() {
  const [user, setUser] = useState(null);
  return <Dashboard user={user} setUser={setUser} />;
}

function Dashboard({ user, setUser }) {
  return <Sidebar user={user} setUser={setUser} />;
}

function Sidebar({ user, setUser }) {
  return <Navigation user={user} setUser={setUser} />;
}

function Navigation({ user, setUser }) {
  return <UserMenu user={user} setUser={setUser} />;
}

function UserMenu({ user, setUser }) {
  // Finally used here, 5 levels deep
  return (
    <button onClick={() => setUser(null)}>
      {user.name} (Logout)
    </button>
  );
}
```

**✅ GOOD**:
```tsx
// Option 1: Context API (for global state)
const UserContext = createContext<UserContextType>(null);

function App() {
  const [user, setUser] = useState(null);
  return (
    <UserContext.Provider value={{ user, setUser }}>
      <Dashboard />
    </UserContext.Provider>
  );
}

function Dashboard() {
  // No props needed
  return <Sidebar />;
}

function UserMenu() {
  // Access directly from context
  const { user, setUser } = useContext(UserContext);
  return (
    <button onClick={() => setUser(null)}>
      {user.name} (Logout)
    </button>
  );
}

// Option 2: Component composition (for layout)
function App() {
  const [user, setUser] = useState(null);
  return (
    <Dashboard>
      <Sidebar>
        <UserMenu user={user} setUser={setUser} />
      </Sidebar>
    </Dashboard>
  );
}

function Dashboard({ children }: { children: ReactNode }) {
  return <div className="dashboard">{children}</div>;
}

function Sidebar({ children }: { children: ReactNode }) {
  return <aside className="sidebar">{children}</aside>;
}

// Option 3: State management library
import { useUserStore } from './store';

function UserMenu() {
  const { user, logout } = useUserStore();
  return (
    <button onClick={logout}>
      {user.name} (Logout)
    </button>
  );
}
```

**Violation Handling**: Use Context API, composition, or state management (Redux, Zustand) for deeply nested state

**No Excuses**:
- ❌ "Context is overkill for this"
- ❌ "It's only a few props"
- ❌ "Global state is harder to test"

**Enforcement**: ESLint plugin `react/jsx-props-no-drilling`, code review, prop count metrics

---

### 3. NO MULTIPLE RESPONSIBILITIES (ONE PURPOSE PER COMPONENT)

**❌ BAD**:
```tsx
// Component doing data fetching + display + business logic
function ProductCard({ productId }: { productId: number }) {
  // Data fetching
  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    fetch(`/api/products/${productId}`)
      .then(res => res.json())
      .then(data => {
        setProduct(data);
        setLoading(false);
      });
  }, [productId]);
  
  // Business logic
  const discountedPrice = product 
    ? product.price * (1 - product.discount / 100)
    : 0;
  
  const isInStock = product && product.stock > 0;
  const canPurchase = isInStock && product.published;
  
  // Cart management
  const [cart, setCart] = useState([]);
  const addToCart = () => {
    setCart([...cart, product]);
    saveCartToLocalStorage(cart);
  };
  
  if (loading) return <Spinner />;
  if (!product) return <Error />;
  
  return (
    <div>
      <img src={product.image} />
      <h3>{product.name}</h3>
      <p>${discountedPrice.toFixed(2)}</p>
      {canPurchase && (
        <button onClick={addToCart}>Add to Cart</button>
      )}
    </div>
  );
}
```

**✅ GOOD**:
```tsx
// Split responsibilities: Data → Logic → Display → Interaction

// 1. Data fetching (custom hook)
function useProduct(productId: number) {
  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  
  useEffect(() => {
    setLoading(true);
    fetchProduct(productId)
      .then(setProduct)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [productId]);
  
  return { product, loading, error };
}

// 2. Business logic (custom hook)
function useProductPricing(product: Product) {
  const discountedPrice = useMemo(
    () => product.price * (1 - product.discount / 100),
    [product.price, product.discount]
  );
  
  const isInStock = product.stock > 0;
  const canPurchase = isInStock && product.published;
  
  return { discountedPrice, isInStock, canPurchase };
}

// 3. Cart management (separate hook or store)
function useCart() {
  const [cart, setCart] = useLocalStorage('cart', []);
  
  const addToCart = useCallback((product: Product) => {
    setCart([...cart, product]);
  }, [cart, setCart]);
  
  return { cart, addToCart };
}

// 4. Presentational component (display only)
function ProductCard({ productId }: { productId: number }) {
  const { product, loading, error } = useProduct(productId);
  const { addToCart } = useCart();
  
  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!product) return null;
  
  return <ProductCardView product={product} onAddToCart={addToCart} />;
}

// 5. Pure display component
function ProductCardView({ 
  product, 
  onAddToCart 
}: ProductCardViewProps) {
  const { discountedPrice, canPurchase } = useProductPricing(product);
  
  return (
    <article className="product-card">
      <ProductImage src={product.image} alt={product.name} />
      <ProductInfo name={product.name} price={discountedPrice} />
      {canPurchase && (
        <AddToCartButton onClick={() => onAddToCart(product)} />
      )}
    </article>
  );
}
```

**Violation Handling**: Extract data fetching to hooks, business logic to services/hooks, split UI into presentational components

**No Excuses**:
- ❌ "It's all part of the same feature"
- ❌ "Splitting makes the code harder to follow"
- ❌ "Premature abstraction"

**Enforcement**: Single Responsibility Principle, code review, component complexity metrics

---

### 4. NO MISSING PROPTYPES/TYPES (ALL PROPS MUST BE TYPED)

**❌ BAD**:
```tsx
// No types (JavaScript or any)
function UserProfile({ user, onEdit, onDelete }) {
  // What shape is 'user'? What are the callback signatures?
  return (
    <div>
      <h2>{user.name}</h2>
      <button onClick={onEdit}>Edit</button>
      <button onClick={() => onDelete(user.id)}>Delete</button>
    </div>
  );
}

// Partial types (missing optional props)
interface UserProfileProps {
  user: User;
  onEdit: () => void;
  // Missing: onDelete, className, isLoading?
}

// Using 'any'
function DataTable({ data }: { data: any[] }) {
  // No type safety on data structure
  return data.map(item => <div>{item.name}</div>);
}
```

**✅ GOOD**:
```tsx
// Complete TypeScript interface
interface UserProfileProps {
  user: User;
  onEdit: (user: User) => void;
  onDelete: (userId: number) => Promise<void>;
  className?: string; // Optional props marked explicitly
  isLoading?: boolean;
}

function UserProfile({
  user,
  onEdit,
  onDelete,
  className,
  isLoading = false // Default value
}: UserProfileProps) {
  return (
    <div className={className}>
      {isLoading ? (
        <Spinner />
      ) : (
        <>
          <h2>{user.name}</h2>
          <button onClick={() => onEdit(user)}>Edit</button>
          <button onClick={() => onDelete(user.id)}>Delete</button>
        </>
      )}
    </div>
  );
}

// Generic types for reusable components
interface DataTableProps<T> {
  data: T[];
  columns: ColumnDef<T>[];
  onRowClick?: (row: T) => void;
  keyExtractor: (row: T) => string | number;
}

function DataTable<T>({ 
  data, 
  columns, 
  onRowClick,
  keyExtractor 
}: DataTableProps<T>) {
  return (
    <table>
      <tbody>
        {data.map(row => (
          <tr 
            key={keyExtractor(row)} 
            onClick={() => onRowClick?.(row)}
          >
            {columns.map(col => (
              <td key={col.key}>{col.render(row)}</td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}

// PropTypes for JavaScript projects
import PropTypes from 'prop-types';

UserProfile.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
  }).isRequired,
  onEdit: PropTypes.func.isRequired,
  onDelete: PropTypes.func.isRequired,
  className: PropTypes.string,
  isLoading: PropTypes.bool,
};

UserProfile.defaultProps = {
  className: '',
  isLoading: false,
};
```

**Violation Handling**: Add TypeScript interfaces or PropTypes to ALL components, no `any` types allowed

**No Excuses**:
- ❌ "It's obvious from the code"
- ❌ "TypeScript is too verbose"
- ❌ "I'll add types later"

**Enforcement**: TypeScript strict mode, ESLint rule `react/prop-types`, CI type checking

---

### 5. NO UNCONTROLLED INPUTS (CONTROLLED INPUTS ONLY)

**❌ BAD**:
```tsx
// Uncontrolled input (DOM manages state)
function LoginForm() {
  const emailRef = useRef<HTMLInputElement>(null);
  const passwordRef = useRef<HTMLInputElement>(null);
  
  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    // Reading from DOM
    const email = emailRef.current?.value;
    const password = passwordRef.current?.value;
    login(email, password);
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input ref={emailRef} type="email" />
      <input ref={passwordRef} type="password" />
      <button>Login</button>
    </form>
  );
}

// Mixed controlled/uncontrolled (dangerous)
function SearchBar() {
  const [query, setQuery] = useState('');
  
  return (
    <input 
      defaultValue={query} // Uncontrolled
      onChange={e => setQuery(e.target.value)} // Trying to control
    />
  );
}
```

**✅ GOOD**:
```tsx
// Controlled inputs (React manages state)
function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  
  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    login(email, password);
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input 
        type="email" 
        value={email} 
        onChange={e => setEmail(e.target.value)}
      />
      <input 
        type="password" 
        value={password} 
        onChange={e => setPassword(e.target.value)}
      />
      <button>Login</button>
    </form>
  );
}

// Form library (React Hook Form) for complex forms
import { useForm } from 'react-hook-form';

function RegistrationForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>();
  
  const onSubmit = (data: FormData) => {
    register(data);
  };
  
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input 
        {...register('email', { 
          required: 'Email is required',
          pattern: /\S+@\S+\.\S+/
        })} 
      />
      {errors.email && <span>{errors.email.message}</span>}
      
      <input 
        type="password"
        {...register('password', { 
          required: 'Password is required',
          minLength: 8
        })} 
      />
      {errors.password && <span>{errors.password.message}</span>}
      
      <button>Register</button>
    </form>
  );
}

// Controlled select
function CountrySelector() {
  const [country, setCountry] = useState('US');
  
  return (
    <select value={country} onChange={e => setCountry(e.target.value)}>
      <option value="US">United States</option>
      <option value="CA">Canada</option>
      <option value="UK">United Kingdom</option>
    </select>
  );
}

// Controlled checkbox
function NewsletterSubscribe() {
  const [subscribed, setSubscribed] = useState(false);
  
  return (
    <label>
      <input 
        type="checkbox" 
        checked={subscribed} 
        onChange={e => setSubscribed(e.target.checked)}
      />
      Subscribe to newsletter
    </label>
  );
}
```

**Violation Handling**: Convert ALL uncontrolled inputs to controlled, use `value`/`checked` + `onChange`

**No Excuses**:
- ❌ "Uncontrolled inputs are simpler"
- ❌ "I don't need validation"
- ❌ "Performance is better with refs"

**Enforcement**: ESLint plugin `react/no-uncontrolled-component`, code review, form validation tests

---

## Implementation Details (Original ECC Domain Knowledge)

### Component Composition Patterns

#### 1. Children Pattern

**Basic children prop**:
```tsx
function Card({ children }: { children: ReactNode }) {
  return (
    <div className="card">
      <div className="card-content">
        {children}
      </div>
    </div>
  );
}

// Usage
<Card>
  <h2>Title</h2>
  <p>Content goes here</p>
</Card>
```

**Named slots pattern**:
```tsx
interface ModalProps {
  header: ReactNode;
  body: ReactNode;
  footer: ReactNode;
}

function Modal({ header, body, footer }: ModalProps) {
  return (
    <div className="modal">
      <div className="modal-header">{header}</div>
      <div className="modal-body">{body}</div>
      <div className="modal-footer">{footer}</div>
    </div>
  );
}

// Usage
<Modal
  header={<h2>Confirm Action</h2>}
  body={<p>Are you sure?</p>}
  footer={
    <>
      <button>Cancel</button>
      <button>Confirm</button>
    </>
  }
/>
```

#### 2. Render Props Pattern

```tsx
interface DataFetcherProps<T> {
  url: string;
  render: (data: T, loading: boolean, error: Error | null) => ReactNode;
}

function DataFetcher<T>({ url, render }: DataFetcherProps<T>) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  
  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(setData)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [url]);
  
  return <>{render(data, loading, error)}</>;
}

// Usage
<DataFetcher<User>
  url="/api/user/1"
  render={(user, loading, error) => {
    if (loading) return <Spinner />;
    if (error) return <Error message={error.message} />;
    return <UserProfile user={user} />;
  }}
/>
```

#### 3. Compound Components Pattern

```tsx
// Parent component provides context
const TabsContext = createContext<TabsContextType>(null);

function Tabs({ children, defaultActiveId }: TabsProps) {
  const [activeId, setActiveId] = useState(defaultActiveId);
  
  return (
    <TabsContext.Provider value={{ activeId, setActiveId }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

// Child components consume context
function TabList({ children }: { children: ReactNode }) {
  return <div className="tab-list">{children}</div>;
}

function Tab({ id, children }: TabProps) {
  const { activeId, setActiveId } = useContext(TabsContext);
  const isActive = activeId === id;
  
  return (
    <button 
      className={isActive ? 'tab-active' : 'tab'}
      onClick={() => setActiveId(id)}
    >
      {children}
    </button>
  );
}

function TabPanels({ children }: { children: ReactNode }) {
  return <div className="tab-panels">{children}</div>;
}

function TabPanel({ id, children }: TabPanelProps) {
  const { activeId } = useContext(TabsContext);
  if (activeId !== id) return null;
  
  return <div className="tab-panel">{children}</div>;
}

// Export as compound component
Tabs.List = TabList;
Tabs.Tab = Tab;
Tabs.Panels = TabPanels;
Tabs.Panel = TabPanel;

// Usage
<Tabs defaultActiveId="orders">
  <Tabs.List>
    <Tabs.Tab id="orders">Orders</Tabs.Tab>
    <Tabs.Tab id="products">Products</Tabs.Tab>
  </Tabs.List>
  
  <Tabs.Panels>
    <Tabs.Panel id="orders">
      <OrdersList />
    </Tabs.Panel>
    <Tabs.Panel id="products">
      <ProductsList />
    </Tabs.Panel>
  </Tabs.Panels>
</Tabs>
```

#### 4. Higher-Order Components (HOC)

```tsx
// withAuth HOC
function withAuth<P extends object>(
  Component: ComponentType<P>
): ComponentType<P> {
  return function AuthenticatedComponent(props: P) {
    const { user, loading } = useAuth();
    
    if (loading) return <Spinner />;
    if (!user) return <Redirect to="/login" />;
    
    return <Component {...props} />;
  };
}

// Usage
const ProtectedDashboard = withAuth(Dashboard);

// withErrorBoundary HOC
function withErrorBoundary<P extends object>(
  Component: ComponentType<P>,
  fallback: ReactNode
): ComponentType<P> {
  return function ErrorBoundaryComponent(props: P) {
    return (
      <ErrorBoundary fallback={fallback}>
        <Component {...props} />
      </ErrorBoundary>
    );
  };
}
```

---

### Component Optimization

#### 1. Memoization

```tsx
// React.memo for expensive renders
const ExpensiveComponent = React.memo(function ExpensiveComponent({ 
  data 
}: { data: Data[] }) {
  // Complex rendering logic
  return <ComplexVisualization data={data} />;
}, (prevProps, nextProps) => {
  // Custom comparison
  return prevProps.data.length === nextProps.data.length;
});

// useMemo for expensive calculations
function ProductList({ products }: { products: Product[] }) {
  const sortedProducts = useMemo(() => {
    return products
      .sort((a, b) => b.rating - a.rating)
      .slice(0, 10);
  }, [products]);
  
  return <>{sortedProducts.map(p => <ProductCard key={p.id} product={p} />)}</>;
}

// useCallback for stable function references
function ParentComponent() {
  const [count, setCount] = useState(0);
  
  const handleClick = useCallback(() => {
    setCount(c => c + 1);
  }, []); // Stable reference
  
  return <ChildComponent onClick={handleClick} />;
}
```

#### 2. Code Splitting

```tsx
// Lazy loading for route-based splitting
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<PageLoader />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}

// Component-level lazy loading
const HeavyChart = lazy(() => import('./components/HeavyChart'));

function Analytics() {
  const [showChart, setShowChart] = useState(false);
  
  return (
    <div>
      <button onClick={() => setShowChart(true)}>Show Chart</button>
      {showChart && (
        <Suspense fallback={<Spinner />}>
          <HeavyChart data={data} />
        </Suspense>
      )}
    </div>
  );
}
```

---

## OpenCode Integration

### When to Use This Skill

**Auto-load when detecting**:
- Large components ("this component is too big")
- Prop drilling ("passing props through many levels")
- Mixed concerns ("component doing too much")
- Missing types ("TypeScript error", "PropTypes missing")
- Form handling ("uncontrolled input", "form validation")

**Manual invocation**:
```
@use component-design
User: "Refactor this component"
```

### Workflow Integration

**1. Component audit**:
```bash
# Find large components
find src -name "*.tsx" -exec wc -l {} + | sort -rn | head -10

# Check prop drilling depth
# (manual code review)
```

**2. Refactoring steps**:
- Extract custom hooks (data fetching, business logic)
- Split into smaller components (< 300 lines each)
- Use Context API for global state
- Add TypeScript types to all props
- Convert uncontrolled inputs to controlled

**3. Verification**:
```bash
# Type check
npm run type-check

# Test component in isolation
npm test -- UserProfile.test.tsx
```

### Skills Combination

**Works well with**:
- `frontend-patterns` - State management, performance
- `react-hooks` - Custom hooks, useEffect patterns
- `test-driven-development` - Component testing
- `accessibility` - ARIA, keyboard navigation

**Example workflow**:
```
1. @use systematic-debugging → Identify component issues
2. @use component-design → Refactor component structure
3. @use react-hooks → Extract custom hooks
4. @use test-driven-development → Add component tests
5. @use verification-before-completion → Verify improvements
```

---

## Verification Checklist

Before marking component design complete:

- [ ] No components > 300 lines
- [ ] No prop drilling beyond 2 levels (use Context/composition)
- [ ] Each component has single responsibility
- [ ] All props have TypeScript types or PropTypes
- [ ] All inputs are controlled (value + onChange)
- [ ] Complex logic extracted to custom hooks
- [ ] Pure presentational components separated from containers
- [ ] Proper component composition patterns used
- [ ] Code splitting applied to heavy components
- [ ] Memoization added where needed (React.memo, useMemo)

**Component health metrics**:
- Average component size < 150 lines
- Max component size < 300 lines
- Prop count per component < 10
- Component nesting depth < 5
- Test coverage > 80%

---

**This skill enforces maintainable component architecture with zero tolerance for monolithic components, prop drilling, and missing type safety.**
