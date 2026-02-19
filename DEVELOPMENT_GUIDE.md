# Recipy App - Complete Setup & Development Guide

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Setup Instructions](#setup-instructions)
3. [Development Workflow](#development-workflow)
4. [API & Services](#api--services)
5. [Deployment Guide](#deployment-guide)
6. [Testing Strategy](#testing-strategy)

---

## 🏗 Architecture Overview

### Models & Relationships

```
User
├── has_many :recipes
├── has_many :grocery_lists
├── has_many :recipe_collections
└── has_many :meal_plans

Recipe
├── belongs_to :user
├── has_many :recipe_ingredients
├── has_many :ingredients (through: recipe_ingredients)
├── has_many :recipe_collection_memberships
├── has_many :meal_plan_recipes
└── has_one_attached :image

Ingredient
├── has_many :recipe_ingredients
├── has_many :recipes (through: recipe_ingredients)
└── has_many :grocery_list_items

GroceryList
├── belongs_to :user
├── has_many :grocery_list_items
└── has_many :ingredients (through: grocery_list_items)

MealPlan
├── belongs_to :user
├── has_many :meal_plan_recipes
└── has_many :recipes (through: meal_plan_recipes)
```

### Service Objects

**RecipeParserService** - Parses ingredient text
- Input: Raw text with ingredients
- Output: Structured array with quantities, units, names, notes
- Handles fractions (1/2, 1 1/2)
- Normalizes units (tbsp → tablespoons)

**RecipeScraperService** - Imports recipes from URLs
- Supports JSON-LD structured data
- Fallback to meta tags and selectors
- Extracts: title, description, ingredients, instructions, images

**IngredientFinderService** - Normalizes & finds ingredients
- Removes descriptors (fresh, chopped, etc.)
- Singularizes names
- Auto-categorizes (produce, dairy, meat, etc.)
- Prevents duplicate ingredients

---

## 🚀 Setup Instructions

### 1. Prerequisites

Install the required software:

```bash
# Install Ruby 2.7.4 (using RVM)
rvm install 2.7.4
rvm use 2.7.4

# Install PostgreSQL
brew install postgresql@14
brew services start postgresql@14

# Install ImageMagick (for image processing)
brew install imagemagick
```

### 2. Clone & Install

```bash
# Clone repository
git clone https://github.com/PabloFT22/recipy_app.git
cd recipy_app

# Install gems
bundle install

# Setup database
rails db:create
rails db:migrate

# (Optional) Seed sample data
rails db:seed
```

### 3. Environment Configuration

Create `.env` file:

```env
DATABASE_URL=postgresql://localhost/recipy_app_development
SECRET_KEY_BASE=your_secret_key_here
```

### 4. Start Development Server

```bash
rails server
```

Visit: http://localhost:3000

---

## 💻 Development Workflow

### Creating Features

1. **Generate migration**
   ```bash
   rails generate migration AddFieldToModel field:type
   ```

2. **Generate model**
   ```bash
   rails generate model ModelName field:type
   ```

3. **Generate controller**
   ```bash
   rails generate controller ControllerName action1 action2
   ```

4. **Run migrations**
   ```bash
   rails db:migrate
   ```

### Common Tasks

**Reset database**
```bash
rails db:drop db:create db:migrate
```

**Access Rails console**
```bash
rails console
```

**Check routes**
```bash
rails routes
```

**Run specific migration**
```bash
rails db:migrate:up VERSION=20260218195947
```

### Database Operations

**Create sample data in console**
```ruby
# Create user
user = User.create!(email: 'test@example.com', password: 'password123')

# Create ingredient
tomato = Ingredient.create!(name: 'Tomatoes', normalized_name: 'tomato', category: 'produce')

# Create recipe
recipe = user.recipes.create!(
  title: 'Tomato Soup',
  description: 'Delicious homemade soup',
  servings: 4,
  prep_time: 10,
  cook_time: 30,
  instructions: 'Cook tomatoes...',
  difficulty: 'easy'
)

# Add ingredient to recipe
recipe.recipe_ingredients.create!(
  ingredient: tomato,
  quantity: 4,
  unit: 'cups',
  notes: 'diced'
)
```

---

## 🔧 API & Services

### RecipeParserService Usage

```ruby
text = <<~INGREDIENTS
  2 cups flour
  1 tablespoon olive oil
  3 tomatoes, diced
  Salt to taste
INGREDIENTS

parser = RecipeParserService.new(text)
ingredients = parser.parse

# Returns:
# [
#   { ingredient_name: 'flour', quantity: 2.0, unit: 'cups', notes: nil },
#   { ingredient_name: 'olive oil', quantity: 1.0, unit: 'tablespoons', notes: nil },
#   { ingredient_name: 'tomatoes', quantity: 3.0, unit: nil, notes: 'diced' },
#   { ingredient_name: 'salt', quantity: nil, unit: 'to_taste', notes: nil }
# ]
```

### RecipeScraperService Usage

```ruby
scraper = RecipeScraperService.new('https://example.com/recipe')
recipe_data = scraper.scrape

if recipe_data
  recipe = Recipe.create!(
    title: recipe_data[:title],
    description: recipe_data[:description],
    prep_time: recipe_data[:prep_time],
    cook_time: recipe_data[:cook_time],
    servings: recipe_data[:servings],
    instructions: recipe_data[:instructions]
  )
end
```

### Grocery List Generation

```ruby
# From meal plan
meal_plan = MealPlan.find(1)
grocery_list = meal_plan.generate_grocery_list

# Manual creation
list = GroceryList.create!(user: user, name: "Weekly Shopping")
list.add_recipes([recipe1, recipe2], servings_multiplier: 1.5)

# Get items by category
list.items_by_category
# => { 'produce' => [...], 'dairy' => [...], ... }
```

---

## 🚢 Deployment Guide

### Heroku Deployment

1. **Install Heroku CLI**
   ```bash
   brew tap heroku/brew && brew install heroku
   ```

2. **Create Heroku app**
   ```bash
   heroku create recipy-app-prod
   ```

3. **Add PostgreSQL addon**
   ```bash
   heroku addons:create heroku-postgresql:mini
   ```

4. **Set environment variables**
   ```bash
   heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
   heroku config:set RAILS_ENV=production
   ```

5. **Deploy**
   ```bash
   git push heroku main
   ```

6. **Run migrations**
   ```bash
   heroku run rails db:migrate
   ```

7. **Open app**
   ```bash
   heroku open
   ```

### Production Configuration

Update `config/environments/production.rb`:

```ruby
# Use AWS S3 for Active Storage
config.active_storage.service = :amazon

# Configure action mailer
config.action_mailer.default_url_options = { host: 'your-domain.com' }
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp.sendgrid.net',
  port: 587,
  user_name: ENV['SENDGRID_USERNAME'],
  password: ENV['SENDGRID_PASSWORD'],
  authentication: :plain,
  enable_starttls_auto: true
}
```

Update `config/storage.yml`:

```yaml
amazon:
  service: S3
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
  region: us-east-1
  bucket: your-bucket-name
```

### Docker Deployment

```bash
# Build image
docker build -t recipy-app .

# Run container
docker run -d \
  -p 3000:3000 \
  -e DATABASE_URL=postgresql://user:pass@host/db \
  -e RAILS_MASTER_KEY=your_key \
  --name recipy \
  recipy-app
```

---

## 🧪 Testing Strategy

### RSpec Setup

```bash
# Run all tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/models/recipe_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Example Tests

**Model Test** (`spec/models/recipe_spec.rb`):
```ruby
require 'rails_helper'

RSpec.describe Recipe, type: :model do
  it 'calculates total time' do
    recipe = build(:recipe, prep_time: 15, cook_time: 30)
    expect(recipe.total_time).to eq(45)
  end
  
  it 'scales servings correctly' do
    recipe = create(:recipe, servings: 4)
    ingredient = create(:ingredient)
    recipe.recipe_ingredients.create!(
      ingredient: ingredient,
      quantity: 2,
      unit: 'cups'
    )
    
    scaled = recipe.scale_servings(8)
    expect(scaled.first[:quantity]).to eq(4.0)
  end
end
```

**Service Test** (`spec/services/recipe_parser_service_spec.rb`):
```ruby
require 'rails_helper'

RSpec.describe RecipeParserService do
  it 'parses ingredient with quantity and unit' do
    service = RecipeParserService.new("2 cups flour")
    result = service.parse.first
    
    expect(result[:ingredient_name]).to eq('flour')
    expect(result[:quantity]).to eq(2.0)
    expect(result[:unit]).to eq('cups')
  end
end
```

---

## 📚 Additional Resources

### Useful Commands

```bash
# Check gem versions
bundle list

# Update gems
bundle update

# Check for security vulnerabilities
bundle audit

# Precompile assets
rails assets:precompile

# Open console in production
heroku run rails console

# View logs
heroku logs --tail

# Scale dynos
heroku ps:scale web=2
```

### Debugging

```ruby
# In controller/model
byebug  # or binding.pry

# Check SQL queries
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Benchmark code
Benchmark.measure { expensive_operation }
```

### Performance Optimization

```ruby
# Eager loading to prevent N+1 queries
@recipes = Recipe.includes(:ingredients, :user).all

# Counter cache
add_column :users, :recipes_count, :integer, default: 0
belongs_to :user, counter_cache: true

# Database indexes
add_index :recipes, :user_id
add_index :recipe_ingredients, [:recipe_id, :ingredient_id]
```

---

## 🎯 Next Steps

1. ✅ **Core functionality is complete**
2. 🚀 **Deploy to production**
3. 📱 **Add PWA support for mobile**
4. 🔍 **Implement full-text search (Elasticsearch)**
5. 🤖 **Add AI recipe suggestions**
6. 📊 **Analytics dashboard**
7. 🔔 **Email notifications**
8. 👥 **Social features (sharing, following)**

---

## 📞 Support

- GitHub Issues: https://github.com/PabloFT22/recipy_app/issues
- Documentation: https://github.com/PabloFT22/recipy_app/wiki
- Email: support@recipyapp.com

---

**Built with ❤️ using Ruby on Rails**
