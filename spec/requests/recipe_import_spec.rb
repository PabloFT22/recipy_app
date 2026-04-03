require 'rails_helper'

RSpec.describe "Recipe Import", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /recipes/import" do
    it "returns http success" do
      get import_recipes_path
      expect(response).to have_http_status(:success)
    end

    it "renders the import form" do
      get import_recipes_path
      expect(response.body).to include("Import Recipe from URL")
      expect(response.body).to include("Recipe URL")
    end
  end

  describe "POST /recipes/import_from_url" do
    let(:recipe_data) do
      {
        title: "Chocolate Chip Cookies",
        description: "Classic homemade cookies",
        prep_time: 15,
        cook_time: 12,
        servings: 24,
        instructions: "Mix dry ingredients.\n\nAdd wet ingredients.\n\nBake at 350°F.",
        ingredients: ["2 cups all-purpose flour", "1 cup sugar", "1/2 cup butter"],
        image_url: nil
      }
    end

    context "with a valid URL that returns recipe data" do
      before do
        scraper = instance_double(RecipeScraperService, scrape: recipe_data, errors: [])
        allow(RecipeScraperService).to receive(:new).and_return(scraper)
      end

      it "creates a new recipe for the current user" do
        expect {
          post import_from_url_recipes_path, params: { url: "https://example.com/recipe" }
        }.to change(Recipe, :count).by(1)

        recipe = Recipe.last
        expect(recipe.user).to eq(user)
        expect(recipe.title).to eq("Chocolate Chip Cookies")
        expect(recipe.source_url).to eq("https://example.com/recipe")
        expect(recipe.prep_time).to eq(15)
        expect(recipe.cook_time).to eq(12)
        expect(recipe.servings).to eq(24)
      end

      it "redirects to the new recipe with a success notice" do
        post import_from_url_recipes_path, params: { url: "https://example.com/recipe" }
        expect(response).to redirect_to(recipe_path(Recipe.last))
        follow_redirect!
        expect(response.body).to include("Recipe imported successfully!")
      end

      it "stores the source_url on the recipe" do
        post import_from_url_recipes_path, params: { url: "https://example.com/recipe" }
        expect(Recipe.last.source_url).to eq("https://example.com/recipe")
      end

      it "creates recipe ingredients" do
        parser = instance_double(RecipeParserService)
        allow(RecipeParserService).to receive(:new).and_return(parser)
        allow(parser).to receive(:parse).and_return([
          { ingredient_name: "all-purpose flour", quantity: 2.0, unit: "cups", notes: nil },
          { ingredient_name: "sugar", quantity: 1.0, unit: "cups", notes: nil }
        ])

        expect {
          post import_from_url_recipes_path, params: { url: "https://example.com/recipe" }
        }.to change(RecipeIngredient, :count).by(2)
      end
    end

    context "with a blank URL" do
      it "redirects back to import with an error" do
        post import_from_url_recipes_path, params: { url: "" }
        expect(response).to redirect_to(import_recipes_path)
        follow_redirect!
        expect(response.body).to include("Please enter a URL")
      end
    end

    context "with an invalid URL format" do
      it "redirects back to import with an error" do
        post import_from_url_recipes_path, params: { url: "not-a-url" }
        expect(response).to redirect_to(import_recipes_path)
        follow_redirect!
        expect(response.body).to include("Please enter a valid URL")
      end
    end

    context "when the URL has already been imported by the user" do
      before do
        create(:recipe, user: user, source_url: "https://example.com/recipe", title: "Existing Recipe")
      end

      it "redirects to the existing recipe" do
        post import_from_url_recipes_path, params: { url: "https://example.com/recipe" }
        expect(response).to redirect_to(recipe_path(Recipe.last))
        follow_redirect!
        expect(response.body).to include("You already imported this recipe")
      end
    end

    context "when scraping fails" do
      before do
        scraper = instance_double(RecipeScraperService, scrape: nil, errors: ["Network error: connection refused"])
        allow(RecipeScraperService).to receive(:new).and_return(scraper)
      end

      it "redirects back to import with scraper errors" do
        post import_from_url_recipes_path, params: { url: "https://example.com/bad-page" }
        expect(response).to redirect_to(import_recipes_path)
        follow_redirect!
        expect(response.body).to include("Could not import recipe")
      end
    end

    context "when the page has no recipe data (blank title)" do
      before do
        scraper = instance_double(RecipeScraperService, scrape: { title: nil }, errors: [])
        allow(RecipeScraperService).to receive(:new).and_return(scraper)
      end

      it "redirects back to import with a helpful error" do
        post import_from_url_recipes_path, params: { url: "https://example.com/not-a-recipe" }
        expect(response).to redirect_to(import_recipes_path)
        follow_redirect!
        expect(response.body).to include("Could not find recipe data")
      end
    end
  end

  describe "authentication" do
    it "requires login for import page" do
      sign_out user
      get import_recipes_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "requires login for import_from_url" do
      sign_out user
      post import_from_url_recipes_path, params: { url: "https://example.com/recipe" }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
