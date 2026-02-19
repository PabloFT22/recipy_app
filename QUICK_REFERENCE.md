# Quick Reference Guide - Recipy App

## 🚀 Common Commands

### Development Server
```bash
rails server                    # Start server on port 3000
rails server -p 4000           # Start on different port
rails server -e production     # Run in production mode
```

### Database
```bash
rails db:create                # Create databases
rails db:migrate               # Run pending migrations
rails db:rollback              # Rollback last migration
rails db:reset                 # Drop, create, and migrate
rails db:seed                  # Load seed data
```

### Console
```bash
rails console                  # Open Rails console
rails console --sandbox        # Console without saving changes
rails dbconsole               # Open database console
```

### Testing
```bash
bundle exec rspec              # Run all tests
bundle exec rspec spec/models  # Run model tests
rspec spec/models/recipe_spec.rb:10  # Run specific test
```

### Routes
```bash
rails routes                   # Show all routes
rails routes -g recipe         # Filter routes containing "recipe"
```

---

## 💻 Console Operations

### Create User
```ruby
user = User.create!(
  email: 'test@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)
```

### Create Recipe with Ingredients
```ruby
recipe = user.recipes.create!(
  title: 'Pasta Carbonara',
  description: 'Classic Italian pasta dish',
  servings: 4,
  prep_time: 10,
  cook_time: 20,
  instructions: 'Boil pasta. Cook bacon. Mix eggs and cheese...',
  difficulty: 'medium'
)

# Parse ingredients
text = <<~INGREDIENTS
  1 pound pasta
  6 strips bacon, diced
  3 eggs
  1 cup parmesan cheese, grated
  Salt and pepper to taste
INGREDIENTS

parser = RecipeParserService.new(text)
parsed = parser.parse

parsed.each do |ing_data|
  finder = IngredientFinderService.new(ing_data[:ingredient_name])
  ingredient = finder.find_or_create
  
  recipe.recipe_ingredients.create!(
    ingredient: ingredient,
    quantity: ing_data[:quantity],
    unit: ing_data[:unit],
    notes: ing_data[:notes]
  )
end
```

### Create Meal Plan
```ruby
meal_plan = user.meal_plans.create!(
  name: 'Week of Feb 18',
  start_date: Date.current.beginning_of_week,
  end_date: Date.current.end_of_week
)

# Add recipes to meal plan
meal_plan.meal_plan_recipes.create!(
  recipe: recipe,
  scheduled_for: Date.current,
  meal_type: 'dinner',
  servings: 4
)
```

### Generate Grocery List
```ruby
grocery_list = meal_plan.generate_grocery_list(name: "Weekly Shopping")
grocery_list.items_by_category
```

### Query Examples
```ruby
# Find recipes by difficulty
Recipe.by_difficulty('easy')

# Search recipes
Recipe.search('pasta')

# Recent recipes
Recipe.recent.limit(10)

# Public recipes
Recipe.public_recipes

# Recipes with specific ingredient
Recipe.joins(:ingredients).where(ingredients: { normalized_name: 'tomato' })

# Active grocery lists
user.grocery_lists.active

# Current meal plans
user.meal_plans.active
```

---

## 🔧 Service Object Examples

### Parse Ingredients
```ruby
parser = RecipeParserService.new(<<~TEXT)
  2 cups flour
  1/2 cup sugar
  1 1/2 teaspoons vanilla extract
  3 eggs, beaten
  Salt to taste
TEXT

result = parser.parse
# => [
#   { ingredient_name: "flour", quantity: 2.0, unit: "cups", notes: nil },
#   { ingredient_name: "sugar", quantity: 0.5, unit: "cups", notes: nil },
#   { ingredient_name: "vanilla extract", quantity: 1.5, unit: "teaspoons", notes: nil },
#   { ingredient_name: "eggs", quantity: 3.0, unit: nil, notes: "beaten" },
#   { ingredient_name: "salt", quantity: nil, unit: "to_taste", notes: nil }
# ]
```

### Scrape Recipe
```ruby
scraper = RecipeScraperService.new('https://www.allrecipes.com/recipe/example/')
recipe_data = scraper.scrape

if recipe_data
  recipe = Recipe.create!(
    title: recipe_data[:title],
    description: recipe_data[:description],
    prep_time: recipe_data[:prep_time],
    cook_time: recipe_data[:cook_time],
    servings: recipe_data[:servings],
    instructions: recipe_data[:instructions],
    source_url: url
  )
  
  # Parse and add ingredients
  if recipe_data[:ingredients].present?
    parser = RecipeParserService.new(recipe_data[:ingredients].join("\n"))
    parsed = parser.parse
    
    parsed.each do |ing|
      finder = IngredientFinderService.new(ing[:ingredient_name])
      ingredient = finder.find_or_create
      recipe.recipe_ingredients.create!(
        ingredient: ingredient,
        quantity: ing[:quantity],
        unit: ing[:unit],
        notes: ing[:notes]
      )
    end
  end
end
```

### Find or Create Ingredient
```ruby
finder = IngredientFinderService.new('Fresh Tomatoes')
ingredient = finder.find_or_create
# => #<Ingredient id: 1, name: "Fresh Tomatoes", normalized_name: "tomato", category: "produce">
```

---

## 🎨 View Helpers

### Recipe Display
```erb
<%= link_to recipe.title, recipe_path(recipe) %>
<%= image_tag recipe.image if recipe.image.attached? %>
<%= recipe.total_time %> minutes
```

### Form Helpers
```erb
<%= form_with model: @recipe do |f| %>
  <%= f.text_field :title, class: 'form-control' %>
  <%= f.text_area :description, class: 'form-control' %>
  <%= f.number_field :servings, class: 'form-control' %>
  <%= f.select :difficulty, ['easy', 'medium', 'hard'], {}, class: 'form-control' %>
  <%= f.file_field :image, class: 'form-control' %>
  <%= f.submit 'Save Recipe', class: 'btn' %>
<% end %>
```

---

## 📊 Common Queries

### Recipe Stats
```ruby
user.recipes.count
user.recipes.group(:difficulty).count
user.recipes.where('created_at > ?', 1.week.ago).count
```

### Ingredient Usage
```ruby
Ingredient.joins(:recipe_ingredients)
  .group(:name)
  .order('COUNT(recipe_ingredients.id) DESC')
  .limit(10)
  .count
```

### Grocery List Stats
```ruby
list = GroceryList.find(1)
list.total_items
list.checked_items
list.progress_percentage
```

---

## 🐛 Debugging

### Enable SQL Logging
```ruby
ActiveRecord::Base.logger = Logger.new(STDOUT)
```

### Check Associations
```ruby
recipe.ingredients.to_sql
recipe.recipe_ingredients.explain
```

### Benchmark Queries
```ruby
require 'benchmark'

time = Benchmark.measure do
  Recipe.includes(:ingredients).limit(100).each do |recipe|
    recipe.ingredients.count
  end
end

puts time
```

---

## 🔒 Security

### Strong Parameters Example
```ruby
def recipe_params
  params.require(:recipe).permit(
    :title, :description, :servings, :prep_time,
    :cook_time, :instructions, :difficulty,
    :is_public, :image
  )
end
```

### Scoped Queries
```ruby
# Always scope to current_user
@recipes = current_user.recipes
@grocery_lists = current_user.grocery_lists
```

---

## 📦 Deployment Commands

### Heroku
```bash
# Login
heroku login

# Create app
heroku create app-name

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Set config
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)

# Deploy
git push heroku main

# Migrate
heroku run rails db:migrate

# Open console
heroku run rails console

# View logs
heroku logs --tail
```

### Docker
```bash
# Build
docker build -t recipy-app .

# Run
docker run -p 3000:3000 recipy-app

# Compose
docker-compose up
```

---

## 🎯 Pro Tips

### Seed Data
Create `db/seeds.rb`:
```ruby
# Create demo user
user = User.create!(
  email: 'demo@recipyapp.com',
  password: 'password123'
)

# Create sample recipes
5.times do |i|
  recipe = user.recipes.create!(
    title: "Recipe #{i+1}",
    description: "A delicious recipe",
    servings: rand(2..8),
    prep_time: rand(10..30),
    cook_time: rand(20..60),
    difficulty: ['easy', 'medium', 'hard'].sample,
    instructions: "Step 1: ...\nStep 2: ...\nStep 3: ..."
  )
  
  # Add random ingredients
  3.times do
    ingredient = Ingredient.create!(
      name: Faker::Food.ingredient,
      normalized_name: Faker::Food.ingredient.downcase,
      category: Ingredient::CATEGORIES.sample
    )
    
    recipe.recipe_ingredients.create!(
      ingredient: ingredient,
      quantity: rand(1..5),
      unit: RecipeIngredient::UNITS.sample
    )
  end
end

puts "Created #{Recipe.count} recipes with #{Ingredient.count} ingredients"
```

Run with: `rails db:seed`

---

## 🚨 Troubleshooting

### PostgreSQL not starting
```bash
brew services restart postgresql@14
```

### Migration errors
```bash
rails db:rollback
# Fix migration
rails db:migrate
```

### Asset issues
```bash
rails assets:clobber
rails assets:precompile
```

### Clear cache
```bash
rails dev:cache  # Toggle caching
rails tmp:clear  # Clear tmp files
```

---

**Happy Cooking! 👨‍🍳**
