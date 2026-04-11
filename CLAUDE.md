# Recipy App — Claude Code Instructions

## Project Overview
Recipy is a recipe management Rails application. Users can save, organize, and plan meals from their recipe collection. The app supports importing recipes from URLs, organizing them into collections, creating meal plans, and generating grocery lists.

## Tech Stack
- **Framework**: Ruby on Rails 7.1 (Ruby 2.7.4)
- **Database**: MySQL (mysql2 gem)
- **Frontend**: Hotwire (Turbo + Stimulus), Importmap, Sprockets
- **Styling**: Vanilla CSS with CSS custom properties (design tokens) — NO Tailwind, NO Sass
- **Authentication**: Devise
- **Background Jobs**: Sidekiq
- **Key Gems**: friendly_id (slugs), kaminari (pagination), httparty + nokogiri (scraping), image_processing (photos), ruby-measurement (ingredient parsing)

## Key Commands
- **Start server**: `bin/rails server`
- **Run all tests**: `bundle exec rspec`
- **Run specific test**: `bundle exec rspec spec/path/to/file_spec.rb`
- **Run migrations**: `bin/rails db:migrate`
- **Rails console**: `bin/rails console`
- **Routes**: `bin/rails routes`

## Architecture Rules
- All models inherit from `ApplicationRecord`
- Use Devise for auth — never roll custom authentication
- Ingredients are normalized (downcased, stripped) to prevent duplicates
- Recipes use friendly_id for slugs
- Use Turbo Frames and Turbo Streams for dynamic UI updates
- Use Stimulus controllers for client-side behavior
- Follow Rails conventions: fat models, skinny controllers
- Use service objects for complex business logic (`app/services/`)
- Tests go in `spec/` (RSpec) with factories in `spec/factories/`

## Frontend / UI Rules
- All styles live in `app/assets/stylesheets/application.css` — single file, design-token-driven
- Use CSS custom properties defined in `:root` (see Design System skill for full reference)
- Mobile-first responsive design with `@media (max-width: 768px)` breakpoints
- Use Stimulus controllers in `app/javascript/controllers/` for interactivity
- Views use ERB templates with Turbo Frames for partial page updates
- Touch targets must be at least `var(--touch-min)` (44px)
- Prefer CSS Grid (`.grid`, `.grid-2`, `.grid-3`) and Flexbox for layouts

## File Organization
```
app/
  controllers/    — Request handling
  models/         — Business logic and validations
  services/       — Complex operations (scraping, parsing, etc.)
  views/          — ERB templates with Turbo Frames
  javascript/
    controllers/  — Stimulus controllers
  assets/
    stylesheets/  — CSS (single application.css with design tokens)
spec/
  factories/      — FactoryBot factories
  requests/       — Request specs
  services/       — Service specs
```

## Skills
Claude Code skills are defined in `.claude/skills/`. Load the relevant skill when working on UI/UX, design, or frontend tasks.
