# 🎨 Recipy App — Full UI/UX Overhaul Prompt

> **Use this prompt with Claude Code (or any AI coding agent). Make sure you're on the `5-ui-ux` branch.**
> **Work through it section by section — don't try to do everything in one shot.**

---

## The Brief

I'm overhauling the entire visual design of **Recipy**, a Rails 7.1 recipe management app. The current design is functional but generic — it looks like every other Bootstrap-era CRUD app with flat colored buttons, plain white cards, and no visual personality.

I want a design that feels **refined, cohesive, and distinctive** — like it was designed by someone who cares about craft. Think of how Apple uses translucency and consistent materials, or how Linear uses subtle depth and restraint. I don't want to copy anyone — I want Recipy to have its **own visual identity** rooted in the feeling of cooking: warm, inviting, tactile, and a little bit premium.

---

## Design Philosophy & Principles

### The Feeling
Recipy should feel like opening a beautiful cookbook in a warm kitchen — not like using an enterprise dashboard. Every surface should feel intentional, not default.

### Core Principles
1. **Material Consistency** — Every surface type (cards, buttons, inputs, nav) should feel like it's made of the same "material." If cards have a subtle frosted-glass quality, buttons should echo that. No mixing flat buttons with glossy cards.
2. **Restrained Color** — Use color sparingly and meaningfully. The current gradient is everywhere and loses impact. Let the UI breathe with neutral tones, and use the accent color only for actions and highlights.
3. **Depth with Purpose** — Shadows, layering, and subtle transparency should communicate hierarchy, not just decoration. Primary content sits on top. Background recedes.
4. **Typography as Structure** — Let font weight, size, and spacing do the heavy lifting instead of borders and boxes. Reduce visual clutter.
5. **Micro-interactions** — Subtle transitions on hover, focus, and state changes. Nothing flashy — just enough to make the interface feel alive and responsive.
6. **Whitespace is a Feature** — Give content room to breathe. The current design crams too many elements together.

---

## Design Direction (The "Recipy Material")

### Color Palette — Rethink the Tokens
The current palette is too many saturated colors competing for attention. Redesign the `:root` tokens:

- **Background**: Warm off-white/cream (not cold `#f5f5f5`). Think `#faf9f7` or similar. Cooking is warm.
- **Cards/Surfaces**: White with very subtle warmth, or light frosted surfaces with `backdrop-filter: blur()` where appropriate.
- **Primary Accent**: Keep a single strong accent (the purple-blue gradient is fine, but use it ONLY for primary CTAs and key highlights — not headers, not every button).
- **Text**: Rich dark brown/charcoal instead of generic `#333`. Something like `#2d2a26`.
- **Muted text**: Warm gray, not blue-gray.
- **Borders**: Almost invisible. Use shadow and spacing to separate, not lines.
- **Status colors**: Desaturate slightly — the current `#2ecc71` and `#e74c3c` are very loud. Soften them.

### Surface Treatment
- Cards should feel like they're floating slightly — not just "white box with border-radius"
- Consider a very subtle noise/grain texture on the background (CSS only, no images)
- Buttons should have a slight translucency or glass quality — not solid flat rectangles
- Active/selected states should feel like pressing into a surface, not just changing color

### Typography Upgrade
- Current system font stack is fine, but tighten up the hierarchy:
  - Page titles: Large, bold, generous letter-spacing
  - Section headers: Medium weight, not shouty
  - Body: Comfortable reading size, generous line-height
  - Meta/captions: Small, warm gray, slightly tracked
- Consider adding a single accent font (via Google Fonts / importmap) for the brand name "Recipy" and page titles — something with personality but still clean (e.g., a nice serif or rounded sans)

### Iconography
- Replace emoji icons (📅 🛒 🍽️ ⏱️) with a consistent icon set or a minimal SVG approach
- If keeping emoji, at least make it consistent — currently mixing emoji with text labels randomly

---

## Page-by-Page Overhaul Instructions

### 1. Layout Shell (`application.html.erb`)
- **Navbar**: The dark block navbar feels heavy and dated. Make it lighter — perhaps a frosted/translucent bar that sits over the content with `backdrop-filter`, or a clean white bar with subtle bottom shadow. The brand "Recipy" should have personality (accent font, color, or a small logo mark).
- **Footer**: Lighten it. Doesn't need to be a heavy dark block. Simple, minimal, warm.
- **Flash messages**: Make them feel like gentle toasts — perhaps floating, pill-shaped, with an icon. Not the full-width colored bars.
- **Page transitions**: Add subtle fade-in for main content on Turbo navigations.

### 2. Home / Dashboard (`home/index.html.erb`)
- **Signed-in view**: The "Quick Actions" card with 3 stacked buttons is boring. Redesign as a grid of action tiles/icons — each one a distinct, tappable surface with an icon and label. Think of iOS widget-style blocks.
- **Active Meal Plan & Grocery Lists**: These are important — give them visual priority. Maybe a prominent "This Week" section with a timeline or mini-calendar feel.
- **Recent Recipes**: The recipe cards are the star — make them magazine-quality. Larger images, overlay text on the image with a gradient scrim, subtle parallax on hover.
- **Signed-out landing**: Make this feel like a product landing page — hero section with imagery, value props with icons, and a strong CTA. Not 3 plain cards with emoji.

### 3. Recipes Index (`recipes/index.html.erb`)
- **Search/filter bar**: Make it feel integrated, not like a separate card. A floating search bar with filter chips/pills below it.
- **Tag filters**: Style as horizontal scrollable pills with subtle active states, not badge-like rectangles.
- **Recipe grid**: Larger cards, image-dominant. On hover: slight scale, shadow lift, maybe reveal a quick-action overlay (view/edit). The current text-heavy cards bury the visual appeal.
- **Empty state**: Make it delightful — illustration, warm copy, prominent CTA.

### 4. Recipe Show (`recipes/show.html.erb`)
- This is the most important page. It should feel like reading a beautiful recipe page from a food magazine.
- **Header**: Full-bleed hero image (if available) with title overlay, not a purple gradient box.
- **Meta info**: Clean horizontal layout with subtle dividers, not scattered badges.
- **Ingredients**: Styled as a clean checklist with generous spacing. The checkbox interaction should feel satisfying.
- **Instructions**: Numbered steps with clear visual separation. Step numbers should be prominent but not distracting.
- **Actions**: Float a subtle action bar or use a sticky bottom bar on mobile — not scattered buttons.

### 5. Recipe Form (`recipes/_form.html.erb`)
- The accordion card approach is good — refine it:
  - Headers don't need to be full gradient. Use a subtle left-border accent or icon color instead.
  - Focus states on inputs should feel warm and inviting.
  - The ingredient parsing section is clever — make it feel more interactive.
- Overall: Forms should feel calm and guiding, not overwhelming.

### 6. Meal Plans (`meal_plans/index.html.erb`)
- Cards should show a visual timeline or weekly grid preview, not just text.
- Active plan should be visually distinct — perhaps a glowing border or elevated position.
- Consider a calendar/timeline view option alongside the card grid.

### 7. Grocery Lists (`grocery_lists/index.html.erb`)
- Progress bars should feel more tactile — rounded, with a slight gradient or animation.
- Cards could show a preview of top items.
- The filter tabs should feel like a proper segmented control, not text links.

### 8. Collections (`recipe_collections/index.html.erb`)
- Make the thumbnail strip more prominent — it's the visual hook.
- Cards could have a "stack of cards" effect to suggest a collection.
- Consider masonry layout for visual variety.

---

## Technical Constraints

- **CSS only** — all styles in `app/assets/stylesheets/application.css`
- **No CSS frameworks** — no Tailwind, Bootstrap, etc. Pure vanilla CSS with custom properties
- **No Sass/SCSS** — Sprockets with plain CSS
- **Animations via CSS** — use `transform`, `opacity`, `filter` for GPU acceleration
- **Stimulus controllers** for any interactive behavior (JS in `app/javascript/controllers/`)
- **Turbo-compatible** — all changes must work with Turbo Drive and Turbo Frames
- **Mobile-first** — design for 320px up, enhance for tablet and desktop
- **Accessibility** — WCAG 2.1 AA: contrast ratios, focus indicators, semantic HTML
- **Performance** — no external image assets for decoration. Use CSS gradients, shadows, and `backdrop-filter` only
- **Design tokens** — all values must be defined as CSS custom properties in `:root`

---

## How to Execute

### Phase 1: Foundation (Do this first)
1. Redesign the `:root` design tokens (colors, spacing, shadows, typography)
2. Update the base reset and body styles
3. Redesign the navbar and footer
4. Update button styles (all variants)
5. Update card base styles
6. Update form base styles
7. Update alert/flash styles

### Phase 2: Components
8. Redesign recipe cards (index card style)
9. Redesign recipe show page
10. Redesign the recipe form cards/accordion
11. Redesign meal plan cards
12. Redesign grocery list cards and progress bars
13. Redesign collection cards
14. Redesign empty states

### Phase 3: Pages
15. Overhaul the home page (both signed-in and signed-out)
16. Overhaul the recipes index (search, filters, grid)
17. Polish meal plans index and show
18. Polish grocery lists index and show
19. Polish collections index and show

### Phase 4: Polish
20. Add micro-interactions (hover, focus, transitions)
21. Add page transition animations (Turbo)
22. Responsive audit — test every page at 320px, 768px, 1024px, 1440px
23. Accessibility audit — contrast, focus, screen reader testing
24. Performance check — no layout shifts, smooth animations

---

## Reference: Current File Map

| File | What it is |
|------|-----------|
| `app/assets/stylesheets/application.css` | ALL styles (3600+ lines, single file) |
| `app/views/layouts/application.html.erb` | Main layout shell |
| `app/views/home/index.html.erb` | Dashboard / landing page |
| `app/views/recipes/index.html.erb` | Recipe listing |
| `app/views/recipes/show.html.erb` | Recipe detail page |
| `app/views/recipes/_form.html.erb` | Recipe create/edit form |
| `app/views/recipes/import.html.erb` | Recipe import page |
| `app/views/meal_plans/index.html.erb` | Meal plans listing |
| `app/views/grocery_lists/index.html.erb` | Grocery lists listing |
| `app/views/recipe_collections/index.html.erb` | Collections listing |
| `app/javascript/controllers/` | Stimulus controllers |

---

## What Success Looks Like

When this overhaul is done, someone should be able to open Recipy and immediately feel:
- "This looks **designed**, not just coded"
- "This feels **warm and inviting**, like a kitchen — not cold like a dashboard"
- "Everything feels **consistent** — like it's all part of the same family"
- "The interface is **calm and clear** — I know exactly where to look and what to do"
- "The little details are **delightful** — hover effects, transitions, spacing"

It should NOT feel like: a template, a Bootstrap app, a todo-list tutorial, or an admin panel.
