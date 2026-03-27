---
name: component-design
description: React component design patterns including composition, prop patterns, children patterns, render props, and compound components.
origin: ECC-derived (extracted from frontend-patterns)
adapted_for: OpenCode
---

# Component Design Patterns

## OpenCode Integration

**When to Use**:
- Designing reusable React components
- Creating component libraries
- Implementing complex UI patterns
- Refactoring large components

**Load this skill when**:
- User mentions "component design", "reusable components", "composition"
- Creating design systems
- Building component libraries

**Usage Pattern**:
```typescript
@use component-design
User: "Design a reusable modal component"
```

**Combines well with**:
- `react-hooks` - Hook patterns
- `frontend-patterns` - Overall React architecture

---

## Overview

Component design patterns for maintainable, reusable React components.

## Composition Patterns

### Children Prop Pattern

```typescript
// Container component accepts any children
function Card({ children }: { children: React.ReactNode }) {
  return (
    <div className="card">
      {children}
    </div>
  )
}

// Usage
<Card>
  <h2>Title</h2>
  <p>Content</p>
</Card>
```

### Compound Components

```typescript
// Parent provides context
const TabsContext = createContext<{
  activeTab: string
  setActiveTab: (tab: string) => void
} | null>(null)

function Tabs({ children }: { children: React.ReactNode }) {
  const [activeTab, setActiveTab] = useState('tab1')
  
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  )
}

Tabs.TabList = function TabList({ children }: { children: React.ReactNode }) {
  return <div className="tab-list">{children}</div>
}

Tabs.Tab = function Tab({ id, children }: { id: string; children: React.ReactNode }) {
  const context = useContext(TabsContext)
  const isActive = context?.activeTab === id
  
  return (
    <button
      className={isActive ? 'tab active' : 'tab'}
      onClick={() => context?.setActiveTab(id)}
    >
      {children}
    </button>
  )
}

Tabs.TabPanel = function TabPanel({ id, children }: { id: string; children: React.ReactNode }) {
  const context = useContext(TabsContext)
  if (context?.activeTab !== id) return null
  
  return <div className="tab-panel">{children}</div>
}

// Usage
<Tabs>
  <Tabs.TabList>
    <Tabs.Tab id="tab1">Tab 1</Tabs.Tab>
    <Tabs.Tab id="tab2">Tab 2</Tabs.Tab>
  </Tabs.TabList>
  
  <Tabs.TabPanel id="tab1">Content 1</Tabs.TabPanel>
  <Tabs.TabPanel id="tab2">Content 2</Tabs.TabPanel>
</Tabs>
```

## Prop Patterns

### Discriminated Unions (Type-safe variants)

```typescript
type ButtonProps =
  | { variant: 'primary'; onClick: () => void }
  | { variant: 'link'; href: string }
  | { variant: 'icon'; icon: string; onClick: () => void }

function Button(props: ButtonProps) {
  if (props.variant === 'link') {
    return <a href={props.href} className="button button-link" />
  }
  
  if (props.variant === 'icon') {
    return (
      <button onClick={props.onClick} className="button button-icon">
        <Icon name={props.icon} />
      </button>
    )
  }
  
  return (
    <button onClick={props.onClick} className="button button-primary">
      {props.children}
    </button>
  )
}
```

### Render Props Pattern

```typescript
interface MouseTrackerProps {
  render: (position: { x: number; y: number }) => React.ReactNode
}

function MouseTracker({ render }: MouseTrackerProps) {
  const [position, setPosition] = useState({ x: 0, y: 0 })
  
  useEffect(() => {
    function handleMove(e: MouseEvent) {
      setPosition({ x: e.clientX, y: e.clientY })
    }
    
    window.addEventListener('mousemove', handleMove)
    return () => window.removeEventListener('mousemove', handleMove)
  }, [])
  
  return <>{render(position)}</>
}

// Usage
<MouseTracker
  render={({ x, y }) => (
    <div>Mouse at ({x}, {y})</div>
  )}
/>
```

## Best Practices

- **Single Responsibility**: Each component does one thing well
- **Composition over Inheritance**: Build complex UIs from simple components
- **Props Interface First**: Design props interface before implementation
- **TypeScript**: Use discriminated unions for variant props
- **Compound Components**: For complex components with multiple parts
- **Controlled vs Uncontrolled**: Be explicit about state ownership

## Resources

- [React Patterns](https://reactpatterns.com/)
- [Compound Components](https://kentcdodds.com/blog/compound-components-with-react-hooks)
- [Advanced React Patterns](https://frontendmastery.com/posts/advanced-react-component-patterns/)
