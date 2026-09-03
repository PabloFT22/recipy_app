# Skill: UI Audit — Automated Review

You are performing an automated UI/UX audit on Recipy app views. Systematically review each file against these criteria and report findings.

---

## Audit Process

### Step 1: Collect Context
For every view file being audited:
1. Read the ERB template
2. Read the associated CSS classes in `application.css`
3. Read any associated Stimulus controllers
4. Check the controller action for instance variables

### Step 2: Run Checks

#### A. Design Token Compliance
- [ ] Scan for hardcoded color values (hex, rgb, hsl) — should use `var(--color-*)`
- [ ] Scan for hardcoded spacing values — should use `var(--space-*)`
- [ ] Scan for hardcoded border-radius — should use `var(--radius-*)`
- [ ] Scan for hardcoded shadows — should use `var(--shadow-*)`

#### B. Accessibility (WCAG 2.1 AA)
- [ ] All images have `alt` attributes
- [ ] Form inputs have associated `<label>` elements
- [ ] Buttons have accessible names (text content or `aria-label`)
- [ ] Color contrast meets 4.5:1 for normal text, 3:1 for large text
- [ ] Focus indicators are visible on interactive elements
- [ ] Links are distinguishable from surrounding text
- [ ] ARIA roles and attributes are correctly used
- [ ] Heading hierarchy is logical (no skipped levels)

#### C. Responsive Design
- [ ] Layout doesn't overflow on 320px width
- [ ] Touch targets are at least 44x44px
- [ ] Text is readable without horizontal scrolling
- [ ] Images are responsive (max-width: 100%)
- [ ] Grids collapse to single column on mobile

#### D. State Coverage
- [ ] Empty state designed for lists/collections
- [ ] Loading indicators for async operations
- [ ] Error state for form submissions
- [ ] Success/confirmation feedback
- [ ] Disabled state for unavailable actions

#### E. UX Patterns
- [ ] Destructive actions require confirmation
- [ ] Primary action is visually prominent
- [ ] Navigation has clear current-page indicator
- [ ] Back/cancel links available on forms
- [ ] Breadcrumbs for nested resources

#### F. Performance
- [ ] No unnecessary DOM nesting
- [ ] Images use appropriate sizes/formats
- [ ] CSS animations use `transform`/`opacity` (GPU-accelerated)
- [ ] Turbo Frames scope refreshes to minimal DOM

### Step 3: Report Format

```markdown
## UI Audit Report: [view_name]

### 🟢 Passing
- List of checks that pass

### 🟡 Warnings
- Minor issues that should be addressed

### 🔴 Failures
- Critical issues that must be fixed

### 💡 Recommendations
- Suggested improvements beyond compliance
```

---

## Quick Audit Commands

To trigger specific audits:
- **"Audit all views"** — Run full audit on every file in `app/views/`
- **"Audit [view_name]"** — Run full audit on a specific view
- **"Accessibility audit"** — Run only accessibility checks
- **"Token compliance audit"** — Run only design token checks
- **"Responsive audit"** — Run only responsive design checks
