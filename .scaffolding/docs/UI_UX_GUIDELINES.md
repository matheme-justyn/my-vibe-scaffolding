# UI/UX Guidelines (介面設計指南)

**Version**: 2.2.0  
**Module**: UI_UX_GUIDELINES  
**Loading**: Conditional (`project.type = "frontend"` or `"fullstack"`)  
**Purpose**: Design systems, visual hierarchy, and user experience best practices.

---

## Overview

This guide defines **UI/UX design principles** for creating intuitive, accessible, and visually consistent interfaces. It covers design systems, component patterns, spacing, typography, and interaction design.

**Scope**:
- ✅ Design systems and component libraries
- ✅ Visual hierarchy and layout
- ✅ Typography and color systems
- ✅ Interaction patterns and micro-interactions
- ❌ Technical implementation (see FRONTEND_STANDARDS)
- ❌ Accessibility specifics (see ACCESSIBILITY_STANDARDS)

**Loading Trigger**: `project.type = "frontend"` OR `project.type = "fullstack"`

---

## Design Systems

### 1. What is a Design System?

A design system is a **complete set of standards, components, and tools** for designing and building consistent products.

**Components**:
- **Design tokens**: Colors, spacing, typography scales
- **Component library**: Buttons, inputs, cards, modals
- **Patterns**: Navigation, forms, data display
- **Guidelines**: Usage rules, do's and don'ts
- **Documentation**: Storybook, style guides

### 2. Design Tokens

**Rule**: Define all design decisions as reusable tokens.

✅ **DO**:
```css
/* tokens.css */
:root {
  /* Colors */
  --color-primary: #3B82F6;
  --color-primary-hover: #2563EB;
  --color-danger: #EF4444;
  --color-success: #10B981;
  
  /* Spacing scale (4px base) */
  --space-1: 0.25rem;  /* 4px */
  --space-2: 0.5rem;   /* 8px */
  --space-3: 0.75rem;  /* 12px */
  --space-4: 1rem;     /* 16px */
  --space-6: 1.5rem;   /* 24px */
  --space-8: 2rem;     /* 32px */
  
  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'Fira Code', monospace;
  --text-xs: 0.75rem;  /* 12px */
  --text-sm: 0.875rem; /* 14px */
  --text-base: 1rem;   /* 16px */
  --text-lg: 1.125rem; /* 18px */
  --text-xl: 1.25rem;  /* 20px */
  
  /* Border radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  
  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
}

/* Usage */
.button {
  background: var(--color-primary);
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-md);
  font-size: var(--text-base);
}
```

❌ **DON'T**:
```css
/* Bad: Hard-coded values scattered everywhere */
.button {
  background: #3B82F6;
  padding: 8px 16px;
  border-radius: 6px;
}

.card {
  background: #3B82F6; /* Same color but inconsistent if changed */
  padding: 10px 20px;  /* Different spacing scale */
}
```

### 3. Color Systems

**8+1 Rule**: Primary + 8 shades

```
Primary Color: #3B82F6 (blue-500)

Shades:
├── 50:  #EFF6FF  (lightest)
├── 100: #DBEAFE
├── 200: #BFDBFE
├── 300: #93C5FD
├── 400: #60A5FA
├── 500: #3B82F6  ← Base color
├── 600: #2563EB
├── 700: #1D4ED8
├── 800: #1E40AF
└── 900: #1E3A8A  (darkest)
```

**Semantic Colors**:
```css
:root {
  --color-success: #10B981;  /* Green */
  --color-warning: #F59E0B;  /* Orange */
  --color-danger: #EF4444;   /* Red */
  --color-info: #3B82F6;     /* Blue */
  
  /* Text colors */
  --text-primary: #111827;    /* Almost black */
  --text-secondary: #6B7280;  /* Gray */
  --text-disabled: #9CA3AF;   /* Light gray */
  
  /* Background colors */
  --bg-primary: #FFFFFF;
  --bg-secondary: #F9FAFB;
  --bg-tertiary: #F3F4F6;
}
```

---

## Layout Principles

### 1. Visual Hierarchy

**Rule**: Guide user attention through size, color, and spacing.

**Hierarchy Levels**:
1. **Primary**: Main heading, CTA buttons (largest, boldest)
2. **Secondary**: Subheadings, important info (medium weight)
3. **Tertiary**: Body text, labels (regular weight)
4. **Quaternary**: Captions, metadata (smallest, muted)

✅ **Good Hierarchy**:
```html
<article>
  <h1 class="text-4xl font-bold text-primary">    <!-- Level 1: Largest -->
    How to Build Design Systems
  </h1>
  <p class="text-lg text-secondary mt-2">         <!-- Level 2: Medium -->
    A comprehensive guide for designers and developers
  </p>
  <div class="text-sm text-disabled mt-1">        <!-- Level 4: Smallest -->
    Published on March 16, 2026 · 5 min read
  </div>
  <p class="text-base text-primary mt-6">         <!-- Level 3: Body -->
    Design systems help teams build consistent...
  </p>
</article>
```

### 2. Spacing System

**8px Grid System** (Recommended):

```
4px   = 0.25rem = var(--space-1)
8px   = 0.5rem  = var(--space-2)  ← Base unit
12px  = 0.75rem = var(--space-3)
16px  = 1rem    = var(--space-4)
24px  = 1.5rem  = var(--space-6)
32px  = 2rem    = var(--space-8)
48px  = 3rem    = var(--space-12)
64px  = 4rem    = var(--space-16)
```

**Spacing Rules**:
- **Intra-component spacing**: 4-8px (tight)
- **Inter-component spacing**: 16-24px (comfortable)
- **Section spacing**: 48-64px (generous)

✅ **DO**:
```html
<!-- Good: Consistent spacing scale -->
<div class="space-y-8">               <!-- 32px between sections -->
  <section class="space-y-4">         <!-- 16px between elements -->
    <h2>Section Title</h2>
    <p>Content here...</p>
    <button class="px-4 py-2">        <!-- 16px horizontal, 8px vertical -->
      Action
    </button>
  </section>
</div>
```

### 3. Grid Layouts

**12-Column Grid** (Standard):

```css
.container {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: var(--space-6);
  max-width: 1280px;
  margin: 0 auto;
}

/* Responsive spans */
.col-full  { grid-column: span 12; }  /* Full width */
.col-half  { grid-column: span 6; }   /* Half width */
.col-third { grid-column: span 4; }   /* Third width */
.col-quarter { grid-column: span 3; } /* Quarter width */
```

**Responsive Breakpoints**:
```css
/* Mobile-first approach */
:root {
  --breakpoint-sm: 640px;   /* Small tablets */
  --breakpoint-md: 768px;   /* Tablets */
  --breakpoint-lg: 1024px;  /* Laptops */
  --breakpoint-xl: 1280px;  /* Desktops */
}

/* Usage */
.card {
  grid-column: span 12;  /* Full width on mobile */
}

@media (min-width: 768px) {
  .card {
    grid-column: span 6;  /* Half width on tablets */
  }
}

@media (min-width: 1024px) {
  .card {
    grid-column: span 4;  /* Third width on desktops */
  }
}
```

---

## Typography

### 1. Font Scale

**Rule**: Use modular scale (1.25 ratio recommended)

```css
:root {
  /* Modular scale (Major Third: 1.25) */
  --text-xs: 0.64rem;   /* 10.24px */
  --text-sm: 0.8rem;    /* 12.8px */
  --text-base: 1rem;    /* 16px - Base size */
  --text-lg: 1.25rem;   /* 20px */
  --text-xl: 1.563rem;  /* 25px */
  --text-2xl: 1.953rem; /* 31.25px */
  --text-3xl: 2.441rem; /* 39px */
  --text-4xl: 3.052rem; /* 48.8px */
}
```

### 2. Line Height

**Rule**: Larger text = tighter line-height, smaller text = looser

```css
:root {
  --leading-none: 1;
  --leading-tight: 1.25;
  --leading-snug: 1.375;
  --leading-normal: 1.5;
  --leading-relaxed: 1.625;
  --leading-loose: 2;
}

/* Usage */
h1 { line-height: var(--leading-tight); }    /* 1.25 for headings */
p  { line-height: var(--leading-relaxed); }  /* 1.625 for body text */
```

### 3. Font Weights

```css
:root {
  --font-thin: 100;
  --font-light: 300;
  --font-normal: 400;
  --font-medium: 500;
  --font-semibold: 600;
  --font-bold: 700;
  --font-extrabold: 800;
}

/* Usage guidelines */
h1, h2 { font-weight: var(--font-bold); }      /* 700 */
h3, h4 { font-weight: var(--font-semibold); }  /* 600 */
body   { font-weight: var(--font-normal); }    /* 400 */
```

### 4. Text Hierarchy Example

```html
<article class="space-y-6">
  <h1 class="text-4xl font-bold leading-tight text-primary">
    Main Headline
  </h1>
  <h2 class="text-2xl font-semibold leading-snug text-primary">
    Section Heading
  </h2>
  <p class="text-base font-normal leading-relaxed text-secondary">
    Body paragraph with comfortable reading line-height...
  </p>
  <small class="text-sm text-disabled">
    Metadata or caption
  </small>
</article>
```

---

## Component Patterns

### 1. Buttons

**Variants**:
```css
/* Primary: Main actions */
.btn-primary {
  background: var(--color-primary);
  color: white;
  border: none;
}

/* Secondary: Less important actions */
.btn-secondary {
  background: transparent;
  color: var(--color-primary);
  border: 1px solid var(--color-primary);
}

/* Danger: Destructive actions */
.btn-danger {
  background: var(--color-danger);
  color: white;
}

/* Ghost: Subtle actions */
.btn-ghost {
  background: transparent;
  color: var(--text-primary);
  border: none;
}
```

**Sizes**:
```css
.btn-sm { padding: var(--space-1) var(--space-3); font-size: var(--text-sm); }
.btn-md { padding: var(--space-2) var(--space-4); font-size: var(--text-base); }
.btn-lg { padding: var(--space-3) var(--space-6); font-size: var(--text-lg); }
```

**States**:
- **Hover**: Darken by 10%
- **Active**: Darken by 15%
- **Disabled**: 50% opacity, no pointer events
- **Loading**: Show spinner, disable interaction

### 2. Cards

**Anatomy**:
```html
<div class="card">
  <img class="card-image" src="..." alt="..." />
  <div class="card-header">
    <h3 class="card-title">Title</h3>
    <p class="card-subtitle">Subtitle</p>
  </div>
  <div class="card-body">
    <p>Content goes here...</p>
  </div>
  <div class="card-footer">
    <button class="btn-primary">Action</button>
  </div>
</div>
```

**Styling**:
```css
.card {
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
}

.card-header {
  padding: var(--space-4);
  border-bottom: 1px solid var(--border-color);
}

.card-body {
  padding: var(--space-4);
}

.card-footer {
  padding: var(--space-4);
  background: var(--bg-secondary);
  border-top: 1px solid var(--border-color);
}
```

### 3. Forms

**Input Sizing**:
```css
.input {
  padding: var(--space-2) var(--space-3);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  font-size: var(--text-base);
}

.input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.input:invalid {
  border-color: var(--color-danger);
}
```

**Labels and Helpers**:
```html
<div class="form-field">
  <label class="form-label" for="email">Email</label>
  <input
    id="email"
    type="email"
    class="form-input"
    placeholder="you@example.com"
  />
  <p class="form-helper">We'll never share your email.</p>
</div>
```

---

## Interaction Design

### 1. Hover Effects

**Subtle Feedback**:
```css
.card {
  transition: box-shadow 0.2s ease, transform 0.2s ease;
}

.card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}
```

**Button Hovers**:
```css
.btn {
  transition: background-color 0.15s ease;
}

.btn:hover {
  background-color: var(--color-primary-hover);
}

.btn:active {
  transform: scale(0.98);
}
```

### 2. Loading States

**Skeleton Screens**:
```html
<div class="skeleton">
  <div class="skeleton-line" style="width: 80%"></div>
  <div class="skeleton-line" style="width: 60%"></div>
  <div class="skeleton-line" style="width: 90%"></div>
</div>
```

```css
.skeleton-line {
  height: 1rem;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: loading 1.5s ease-in-out infinite;
  border-radius: var(--radius-sm);
  margin-bottom: var(--space-2);
}

@keyframes loading {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

### 3. Micro-interactions

**Toast Notifications**:
```css
.toast {
  position: fixed;
  bottom: var(--space-4);
  right: var(--space-4);
  padding: var(--space-3) var(--space-4);
  background: var(--color-success);
  color: white;
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-lg);
  animation: slideIn 0.3s ease;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}
```

---

## Responsive Design

### 1. Mobile-First Approach

✅ **DO**:
```css
/* Base styles: Mobile (default) */
.card {
  width: 100%;
  padding: var(--space-4);
}

/* Tablet and up */
@media (min-width: 768px) {
  .card {
    width: 50%;
    padding: var(--space-6);
  }
}

/* Desktop and up */
@media (min-width: 1024px) {
  .card {
    width: 33.333%;
    padding: var(--space-8);
  }
}
```

### 2. Touch Targets

**Rule**: Minimum 44x44px for touch targets (iOS/Android standard)

```css
.touch-target {
  min-width: 44px;
  min-height: 44px;
  padding: var(--space-2);
}
```

---

## Dark Mode

```css
:root {
  --bg-primary: #FFFFFF;
  --text-primary: #111827;
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: #1F2937;
    --text-primary: #F9FAFB;
  }
}

/* Manual toggle */
[data-theme="dark"] {
  --bg-primary: #1F2937;
  --text-primary: #F9FAFB;
}
```

---

## Tools & Resources

**Design Tools**:
- **Figma**: UI design and prototyping
- **Storybook**: Component documentation
- **Chromatic**: Visual regression testing

**Color Tools**:
- **Coolors.co**: Color palette generator
- **Contrast Checker**: WCAG contrast validation

**Inspiration**:
- **Dribbble**: UI design inspiration
- **Behance**: Design portfolios
- **Mobbin**: Mobile app patterns

---

## Module Dependencies

**Required Modules**:
- STYLE_GUIDE - Code conventions
- FRONTEND_STANDARDS - Technical implementation

**Related Modules**:
- ACCESSIBILITY_STANDARDS - WCAG compliance
- I18N_GUIDE - Multi-language support

**Terminology**:
- See `.scaffolding/docs/terminology/software/frontend.md`
