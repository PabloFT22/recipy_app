# Skill: Component Builder — Recipy Design System

You are a component-focused frontend engineer. When this skill is activated, you create reusable UI components that integrate perfectly with Recipy's existing design system.

---

## Component Creation Workflow

### 1. Define the Component
Before writing any code, answer:
- **What does it display?** (data shape, variants)
- **What can the user do?** (interactions, actions)
- **Where does it appear?** (pages, contexts)
- **What states does it have?** (empty, loading, error, populated, disabled)

### 2. Write the CSS
Add styles to `app/assets/stylesheets/application.css` following these rules:
- Place in the correct section (find or create a section comment)
- Use BEM-like naming: `.component`, `.component-element`, `.component--modifier`
- Use only design tokens from `:root`
- Include responsive overrides
- Include hover/focus/active states

```css
/* =============================================================
   COMPONENT NAME
   ============================================================= */
.component { }
.component-element { }
.component--variant { }

@media (max-width: 768px) {
  .component { }
}
```

### 3. Write the ERB Partial
Create a reusable partial in the appropriate views directory:
```
app/views/shared/_component_name.html.erb
```

Use local variables for data:
```erb
<%# app/views/shared/_status_badge.html.erb %>
<span class="badge badge--<%= status %>">
  <%= status.humanize %>
</span>
```

### 4. Add Stimulus Controller (if interactive)
```javascript
// app/javascript/controllers/component_name_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []
  static values = {}

  connect() { }
}
```

### 5. Write Usage Example
Document how to use the component in views:
```erb
<%= render "shared/component_name", data: @data, variant: "default" %>
```

---

## Existing Reusable Components

### Available shared patterns (add to these, don't duplicate):
- **Cards**: `.card`, `.recipe-card`, `.form-card`
- **Buttons**: `.btn`, `.btn-success`, `.btn-danger`, `.btn-secondary`, `.btn-info`, `.btn-sm`, `.btn-lg`
- **Grids**: `.grid`, `.grid-2`, `.grid-3`
- **Forms**: `.form-group`, `.form-label`, `.form-input`, `.form-select`, `.form-hint`
- **Alerts**: `.alert`, `.alert-notice`, `.alert-alert`
- **Page headers**: `.page-header` (gradient background)
- **Navigation**: `.navbar`, `.nav-link`
- **Badges**: `.badge`, `.difficulty-badge`
- **Action bars**: `.action-bar`
- **Empty states**: `.empty-state`

### When creating new components:
1. Check if an existing component can be extended with a modifier class
2. Follow the same naming conventions as existing components
3. Use the same spacing/color tokens
4. Ensure it works inside `.container` and `.card` contexts

---

## Component Quality Checklist
- [ ] Uses only design tokens (no hardcoded values)
- [ ] Has responsive styles
- [ ] Has hover/focus states for interactive elements
- [ ] Handles empty/loading/error states
- [ ] Accessible (proper semantics, ARIA, contrast)
- [ ] Works with Turbo (no DOM assumptions that break on Turbo navigation)
- [ ] Documented with usage example
