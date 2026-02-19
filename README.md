# Recipy - Recipe Management & Meal Planning App

A comprehensive Ruby on Rails application for managing recipes, planning meals, and generating smart grocery lists.

## Features

### 🍳 Recipe Management
- Create, edit, and organize recipes
- Upload recipe images
- Parse ingredients from text (paste ingredients and auto-extract quantities/units)
- Import recipes from URLs (web scraping)
- Duplicate recipes
- Public/private recipe sharing
- Difficulty levels and categorization
- Search and filter recipes

### 📅 Meal Planning
- Create weekly/custom meal plans
- Schedule recipes for specific days
- Breakfast, lunch, dinner, and snack planning
- Adjust servings per meal
- View active, upcoming, and past meal plans

### 🛒 Smart Grocery Lists
- Generate grocery lists from meal plans
- Automatically combine ingredient quantities
- Organize items by store category (produce, dairy, meat, etc.)
- Check off items while shopping
- Mark items as "on hand" to hide from shopping list
- Track shopping progress
- Multiple list statuses (active, completed, archived)

### 📚 Collections
- Organize recipes into collections/folders
- Create themed collections (favorites, holiday recipes, etc.)
- Add/remove recipes from collections

## Tech Stack

- **Framework**: Ruby on Rails 7.1.5
- **Ruby Version**: 2.7.4
- **Database**: PostgreSQL
- **Authentication**: Devise
- **Image Processing**: Active Storage + ImageMagick/libvips
- **Background Jobs**: Sidekiq (for future async tasks)
- **Frontend**: Hotwire (Turbo + Stimulus)
- **HTTP Client**: HTTParty (for recipe scraping)
- **Pagination**: Kaminari
- **URL Slugs**: FriendlyId

## Database Schema

### Core Models
- **User** - Authentication and user management
- **Recipe** - Recipe details, instructions, metadata
- **Ingredient** - Normalized ingredient database
- **RecipeIngredient** - Join table with quantities and units
- **GroceryList** - Shopping lists
- **GroceryListItem** - Individual items with quantities
- **MealPlan** - Meal planning periods
- **MealPlanRecipe** - Recipes scheduled in meal plans
- **RecipeCollection** - Recipe organization
- **RecipeCollectionMembership** - Join table for collections

## Installation

### Prerequisites
- Ruby 2.7.4
- PostgreSQL
- ImageMagick or libvips (for image processing)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/PabloFT22/recipy_app.git
   cd recipy_app
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up database**
   ```bash
   # Start PostgreSQL
   brew services start postgresql@14
   
   # Create and migrate database
   rails db:create
   rails db:migrate
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Visit the app**
   Open [http://localhost:3000](http://localhost:3000)

## Usage Guide

### Creating a Recipe

1. Click "Add New Recipe"
2. Fill in title, description, servings, times
3. For ingredients, you can:
   - Paste a list like:
     ```
     2 cups flour
     1 tablespoon olive oil
     3 tomatoes, diced
     Salt to taste
     ```
   - The parser will automatically extract quantities and units
4. Add instructions
5. Upload an image (optional)

### Importing a Recipe from URL

1. Go to Recipes → Import
2. Paste a recipe URL (works with most major recipe sites)
3. The scraper extracts title, ingredients, instructions, and images
4. Review and edit as needed

### Creating a Meal Plan

1. Click "Create Meal Plan"
2. Set start and end dates
3. Add recipes for each day
4. Specify meal type (breakfast/lunch/dinner/snack)
5. Adjust servings if needed

### Generating a Grocery List

1. From a meal plan, click "Generate Grocery List"
2. The system automatically:
   - Combines duplicate ingredients
   - Sums quantities
   - Groups by store category
3. Check off items as you shop

## Service Objects

### RecipeParserService
Parses ingredient text and extracts:
- Quantities (handles fractions like 1/2, 1 1/2)
- Units (normalized: tbsp → tablespoons)
- Ingredient names
- Notes (e.g., "diced", "to taste")

### RecipeScraperService
Web scraping for recipe import:
- Supports JSON-LD structured data
- Fallback to meta tags and common selectors
- Extracts title, description, ingredients, instructions, images
- Handles duration parsing (ISO 8601)

### IngredientFinderService
Ingredient normalization:
- Finds or creates ingredients
- Normalizes names (removes descriptors, singularizes)
- Auto-categorizes ingredients (produce, dairy, meat, etc.)

## Configuration

### Environment Variables

Create a `.env` file for sensitive data:

```env
DATABASE_URL=postgresql://localhost/recipy_app_development
SECRET_KEY_BASE=your_secret_key
```

### Image Storage

Active Storage is configured for local storage in development. For production:

1. Configure cloud storage (S3, Google Cloud Storage, Azure)
2. Update `config/storage.yml`
3. Set `config.active_storage.service = :amazon` in production.rb

## Deployment

### Heroku Deployment

1. **Create Heroku app**
   ```bash
   heroku create recipy-app
   ```

2. **Add PostgreSQL**
   ```bash
   heroku addons:create heroku-postgresql:mini
   ```

3. **Set environment variables**
   ```bash
   heroku config:set RAILS_MASTER_KEY=<your-master-key>
   ```

4. **Deploy**
   ```bash
   git push heroku main
   heroku run rails db:migrate
   ```

5. **Open app**
   ```bash
   heroku open
   ```

### Docker Deployment

A Dockerfile is included for containerized deployment:

```bash
docker build -t recipy-app .
docker run -p 3000:3000 -e DATABASE_URL=<postgres-url> recipy-app
```

### Environment-Specific Configuration

**Production checklist:**
- Set `SECRET_KEY_BASE`
- Configure production database
- Set up cloud storage for Active Storage
- Configure action mailer (SendGrid, Mailgun, etc.)
- Enable HTTPS
- Set up background job processing (Sidekiq with Redis)

## Testing

Run tests with RSpec:

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/recipe_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

## Future Enhancements

Planned features:
- [ ] Recipe ratings and reviews
- [ ] Cooking mode (step-by-step with voice)
- [ ] Nutritional information calculation
- [ ] Ingredient substitutions
- [ ] Cost tracking
- [ ] Collaboration (share lists with household)
- [ ] Mobile app (React Native or Flutter)
- [ ] AI-powered recipe suggestions
- [ ] Voice input for hands-free cooking

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues or questions:
- Create an issue on GitHub
- Email: support@recipyapp.com

## Acknowledgments

Built with:
- Ruby on Rails
- PostgreSQL
- Devise
- Hotwire
- HTTParty & Nokogiri
