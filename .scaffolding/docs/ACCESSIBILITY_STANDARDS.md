# Accessibility Standards (無障礙標準)

**Version**: 2.2.0  
**Module**: ACCESSIBILITY_STANDARDS  
**Loading**: Conditional (`project.quality` contains `"accessibility"`)  
**Purpose**: WCAG 2.1 compliance, screen reader support, keyboard navigation.

---

## Overview

This guide ensures web applications are **accessible to all users**, including those with disabilities. It covers WCAG 2.1 Level AA compliance, semantic HTML, ARIA, keyboard navigation, and assistive technology support.

**Scope**:
- ✅ WCAG 2.1 Level AA compliance
- ✅ Semantic HTML and ARIA
- ✅ Keyboard navigation
- ✅ Screen reader support
- ✅ Color contrast and visual design

**Loading Trigger**: `project.quality` contains `"accessibility"`

---

## WCAG 2.1 Principles (POUR)

### 1. Perceivable
Information must be presentable to users in ways they can perceive.

**Requirements**:
- ✅ Text alternatives for non-text content
- ✅ Captions for audio/video
- ✅ Adaptable content structure
- ✅ Sufficient color contrast (4.5:1 minimum)

### 2. Operable
UI components must be operable by all users.

**Requirements**:
- ✅ Keyboard accessible (no mouse required)
- ✅ Sufficient time to read/interact
- ✅ No content causing seizures (no flashing > 3 times/second)
- ✅ Clear navigation mechanisms

### 3. Understandable
Information and UI must be understandable.

**Requirements**:
- ✅ Readable text (clear language)
- ✅ Predictable behavior
- ✅ Input assistance (error prevention/correction)

### 4. Robust
Content must work with assistive technologies.

**Requirements**:
- ✅ Valid HTML
- ✅ Proper ARIA usage
- ✅ Compatible with screen readers

---

## Semantic HTML

### 1. Use Semantic Elements

✅ **DO**:
```html
<!-- Good: Semantic HTML -->
<nav>
  <ul>
    <li><a href="/home">Home</a></li>
    <li><a href="/about">About</a></li>
  </ul>
</nav>

<main>
  <article>
    <h1>Article Title</h1>
    <p>Content...</p>
  </article>
  <aside>
    <h2>Related Links</h2>
  </aside>
</main>

<footer>
  <p>&copy; 2026 Company Name</p>
</footer>
```

❌ **DON'T**:
```html
<!-- Bad: Generic divs -->
<div class="nav">
  <div class="nav-item">Home</div>
  <div class="nav-item">About</div>
</div>

<div class="content">
  <div class="title">Article Title</div>
  <div class="text">Content...</div>
</div>
```

**Why**: Semantic HTML provides meaning to assistive technologies.

### 2. Heading Hierarchy

✅ **DO**:
```html
<h1>Page Title</h1>
  <h2>Section 1</h2>
    <h3>Subsection 1.1</h3>
    <h3>Subsection 1.2</h3>
  <h2>Section 2</h2>
    <h3>Subsection 2.1</h3>
```

❌ **DON'T**:
```html
<h1>Page Title</h1>
<h3>Section 1</h3>  <!-- Skipped h2 -->
<h2>Section 2</h2>  <!-- Out of order -->
```

**Rule**: Never skip heading levels. Use `<h1>` once per page.

---

## ARIA (Accessible Rich Internet Applications)

### 1. ARIA Roles

**Common Roles**:
```html
<!-- Landmark roles -->
<div role="banner">Header</div>
<div role="navigation">Nav</div>
<div role="main">Main content</div>
<div role="complementary">Sidebar</div>
<div role="contentinfo">Footer</div>

<!-- Widget roles -->
<div role="button" tabindex="0">Custom Button</div>
<div role="alert">Error message</div>
<div role="dialog" aria-modal="true">Modal</div>
```

**Rule**: Use semantic HTML first, ARIA only when necessary.

### 2. ARIA States and Properties

**aria-label**: Provides accessible name
```html
<button aria-label="Close dialog">
  <svg>...</svg>  <!-- Icon only, no text -->
</button>
```

**aria-labelledby**: References another element
```html
<section aria-labelledby="section-title">
  <h2 id="section-title">Settings</h2>
  ...
</section>
```

**aria-describedby**: Provides additional description
```html
<input
  id="email"
  aria-describedby="email-help"
/>
<p id="email-help">We'll never share your email.</p>
```

**aria-expanded**: Indicates expandable content
```html
<button
  aria-expanded="false"
  aria-controls="dropdown-menu"
>
  Options
</button>
<div id="dropdown-menu" hidden>...</div>
```

**aria-live**: Announces dynamic content
```html
<!-- Polite: Wait for user to pause -->
<div aria-live="polite">
  5 new messages
</div>

<!-- Assertive: Interrupt immediately -->
<div aria-live="assertive" role="alert">
  Error: Connection lost
</div>
```

### 3. ARIA Best Practices

✅ **DO**:
- Use semantic HTML first, ARIA second
- Test with actual screen readers
- Keep ARIA updated (e.g., `aria-expanded` when toggling)

❌ **DON'T**:
- Use ARIA when semantic HTML exists
- Add `role="button"` to `<button>` (redundant)
- Forget to manage focus in custom widgets

---

## Keyboard Navigation

### 1. Focus Management

**Rule**: All interactive elements must be keyboard accessible.

✅ **DO**:
```html
<!-- Native elements are focusable by default -->
<button>Click me</button>
<a href="/page">Link</a>
<input type="text" />

<!-- Custom interactive elements need tabindex -->
<div
  role="button"
  tabindex="0"
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') handleClick();
  }}
>
  Custom Button
</div>
```

**tabindex Values**:
- `0`: Natural tab order (recommended)
- `-1`: Focusable via JS, not in tab order
- `1+`: Explicit order (avoid, creates confusion)

### 2. Focus Indicators

✅ **DO**:
```css
/* Custom focus indicator (more visible than browser default) */
*:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* Don't remove focus outline */
button:focus {
  outline: 2px solid blue;
}
```

❌ **DON'T**:
```css
/* NEVER do this */
*:focus {
  outline: none;  /* Removes focus indicator */
}
```

### 3. Keyboard Shortcuts

**Common Patterns**:
- `Tab`: Move forward
- `Shift+Tab`: Move backward
- `Enter/Space`: Activate button/link
- `Escape`: Close modal/dropdown
- `Arrow keys`: Navigate lists/menus

**Example: Dropdown Menu**:
```tsx
function Dropdown() {
  const [open, setOpen] = useState(false);
  const itemRefs = useRef<HTMLElement[]>([]);
  
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') {
      setOpen(false);
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      // Focus next item
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      // Focus previous item
    }
  };
  
  return (
    <div onKeyDown={handleKeyDown}>
      <button
        aria-expanded={open}
        aria-controls="menu"
        onClick={() => setOpen(!open)}
      >
        Options
      </button>
      {open && (
        <ul id="menu" role="menu">
          <li role="menuitem" tabIndex={0}>Item 1</li>
          <li role="menuitem" tabIndex={0}>Item 2</li>
        </ul>
      )}
    </div>
  );
}
```

---

## Color Contrast

### 1. Contrast Ratios (WCAG 2.1 Level AA)

**Requirements**:
- **Normal text** (< 18px): 4.5:1 minimum
- **Large text** (≥ 18px or 14px bold): 3:1 minimum
- **UI components**: 3:1 minimum

✅ **Good Contrast**:
```css
/* Black text on white: 21:1 ratio (excellent) */
.text {
  color: #000000;
  background: #FFFFFF;
}

/* Dark gray on white: 7:1 ratio (good) */
.text-muted {
  color: #4A4A4A;
  background: #FFFFFF;
}
```

❌ **Poor Contrast**:
```css
/* Light gray on white: 1.5:1 ratio (fails) */
.text-bad {
  color: #CCCCCC;
  background: #FFFFFF;
}
```

**Tools**:
- WebAIM Contrast Checker
- Chrome DevTools Accessibility Panel
- Figma Contrast Plugin

### 2. Don't Rely on Color Alone

✅ **DO**:
```html
<!-- Good: Icon + color + text -->
<div class="alert alert-error">
  <svg aria-hidden="true">❌</svg>
  <strong>Error:</strong> Invalid email address
</div>
```

❌ **DON'T**:
```html
<!-- Bad: Color only -->
<div style="color: red;">Invalid email</div>
```

---

## Forms Accessibility

### 1. Label Association

✅ **DO**:
```html
<!-- Explicit association -->
<label for="email">Email:</label>
<input id="email" type="email" required />

<!-- Implicit association -->
<label>
  Email:
  <input type="email" required />
</label>
```

❌ **DON'T**:
```html
<!-- No association -->
<div>Email:</div>
<input type="email" />
```

### 2. Error Messages

✅ **DO**:
```html
<label for="email">Email:</label>
<input
  id="email"
  type="email"
  aria-invalid="true"
  aria-describedby="email-error"
/>
<p id="email-error" role="alert">
  Please enter a valid email address
</p>
```

### 3. Required Fields

```html
<label for="name">
  Name
  <span aria-label="required">*</span>
</label>
<input id="name" required aria-required="true" />
```

---

## Images and Media

### 1. Alt Text

✅ **DO**:
```html
<!-- Informative image -->
<img src="chart.png" alt="Bar chart showing sales growth from 2020-2025" />

<!-- Decorative image -->
<img src="decoration.png" alt="" role="presentation" />

<!-- Functional image (button) -->
<button>
  <img src="print.svg" alt="Print document" />
</button>
```

❌ **DON'T**:
```html
<!-- Missing alt -->
<img src="important.png" />

<!-- Redundant alt -->
<img src="photo.jpg" alt="Photo of photo" />

<!-- Alt on decorative image -->
<img src="border.png" alt="Border image" />  <!-- Should be alt="" -->
```

### 2. Video/Audio

```html
<video controls>
  <source src="video.mp4" type="video/mp4" />
  <track kind="captions" src="captions.vtt" srclang="en" label="English" />
  <track kind="subtitles" src="subtitles.vtt" srclang="zh" label="中文" />
</video>
```

---

## Modal Dialogs

### 1. Focus Trap

```tsx
function Modal({ open, onClose, children }) {
  const modalRef = useRef<HTMLDivElement>(null);
  
  useEffect(() => {
    if (open) {
      // Store previously focused element
      const previousFocus = document.activeElement as HTMLElement;
      
      // Focus first focusable element in modal
      const focusable = modalRef.current?.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );
      (focusable?.[0] as HTMLElement)?.focus();
      
      // Return focus on close
      return () => previousFocus?.focus();
    }
  }, [open]);
  
  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <h2 id="modal-title">Modal Title</h2>
      {children}
      <button onClick={onClose}>Close</button>
    </div>
  );
}
```

---

## Screen Reader Testing

### 1. Tools

- **macOS**: VoiceOver (Cmd+F5)
- **Windows**: NVDA (free), JAWS
- **Chrome**: ChromeVox extension
- **Mobile**: TalkBack (Android), VoiceOver (iOS)

### 2. Test Checklist

- [ ] Can navigate entire page with keyboard only
- [ ] Focus indicator visible on all interactive elements
- [ ] Screen reader announces all content correctly
- [ ] Form errors announced in real-time
- [ ] Modals trap focus and return focus on close
- [ ] Images have appropriate alt text
- [ ] Contrast ratios meet WCAG AA standards

---

## Common Patterns

### 1. Skip Links

```html
<!-- First element in <body> -->
<a href="#main-content" class="skip-link">
  Skip to main content
</a>

<nav>...</nav>

<main id="main-content" tabindex="-1">
  ...
</main>
```

```css
.skip-link {
  position: absolute;
  left: -9999px;
}

.skip-link:focus {
  left: 0;
  top: 0;
  z-index: 9999;
  padding: 1rem;
  background: #000;
  color: #fff;
}
```

### 2. Loading States

```html
<button disabled aria-busy="true">
  <span aria-live="polite">Loading...</span>
  <span class="sr-only">Please wait</span>
</button>
```

---

## Resources

**Guidelines**:
- [WCAG 2.1](https://www.w3.org/WAI/WCAG21/quickref/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)

**Tools**:
- **axe DevTools**: Browser extension for testing
- **Lighthouse**: Built into Chrome DevTools
- **WAVE**: Web accessibility evaluation tool

**Testing**:
- **Pa11y**: Automated testing
- **jest-axe**: Unit test accessibility

---

## Module Dependencies

**Required Modules**:
- STYLE_GUIDE
- FRONTEND_STANDARDS

**Related Modules**:
- UI_UX_GUIDELINES
- I18N_GUIDE
