require 'rails_helper'

# Renders every user-facing page end to end. The views share a lot of helpers
# and partials, so this catches template breakage that per-feature specs miss.
RSpec.describe "Page rendering", type: :request do
  let(:user) { create(:user) }

  let!(:recipe) do
    create(:recipe, user: user, title: "Smoke Test Stew", difficulty: "easy",
                    prep_time: 15, servings: 4)
  end
  let!(:meal_plan) { create(:meal_plan, user: user, name: "Smoke Week") }
  let!(:grocery_list) { create(:grocery_list, user: user, name: "Smoke Shop") }
  let!(:collection) { create(:recipe_collection, user: user, name: "Smoke Collection") }

  context "when signed out" do
    it "renders the landing page" do
      get root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Everything you cook")
    end

    it "renders the public recipe index" do
      get recipes_path
      expect(response).to have_http_status(:success)
    end

    it "renders the Devise sign-in and sign-up pages" do
      get new_user_session_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("auth-card")

      get new_user_registration_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("auth-card")
    end
  end

  context "when signed in" do
    before { sign_in user }

    {
      "dashboard"          => :root_path,
      "recipes index"      => :recipes_path,
      "new recipe"         => :new_recipe_path,
      "recipe import"      => :import_recipes_path,
      "meal plans index"   => :meal_plans_path,
      "new meal plan"      => :new_meal_plan_path,
      "grocery lists"      => :grocery_lists_path,
      "new grocery list"   => :new_grocery_list_path,
      "collections index"  => :recipe_collections_path,
      "new collection"     => :new_recipe_collection_path,
      "pantry"             => :pantry_path
    }.each do |label, helper|
      it "renders the #{label}" do
        get send(helper)
        expect(response).to have_http_status(:success)
      end
    end

    it "renders the recipe show and edit pages" do
      get recipe_path(recipe)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Smoke Test Stew")

      get edit_recipe_path(recipe)
      expect(response).to have_http_status(:success)
    end

    it "renders the meal plan show and edit pages" do
      get meal_plan_path(meal_plan)
      expect(response).to have_http_status(:success)

      get edit_meal_plan_path(meal_plan)
      expect(response).to have_http_status(:success)
    end

    it "renders the grocery list show and edit pages" do
      get grocery_list_path(grocery_list)
      expect(response).to have_http_status(:success)

      get edit_grocery_list_path(grocery_list)
      expect(response).to have_http_status(:success)
    end

    it "renders the collection show and edit pages" do
      get recipe_collection_path(collection)
      expect(response).to have_http_status(:success)

      get edit_recipe_collection_path(collection)
      expect(response).to have_http_status(:success)
    end

    it "marks the current section in the navigation" do
      get recipes_path
      expect(response.body).to include('aria-current="page"')
      expect(response.body).to include("nav-link--current")
    end

    it "renders the Phase 2 pages" do
      get cook_recipe_path(recipe)
      expect(response).to have_http_status(:success)

      get user_path(user)
      expect(response).to have_http_status(:success)

      get pantry_items_path
      expect(response).to have_http_status(:success)

      get suggest_pantry_items_path
      expect(response).to have_http_status(:success)

      get export_ical_meal_plan_path(meal_plan)
      expect(response).to have_http_status(:success)
    end

    it "renders a recipe that has a review, a like and nutrition" do
      create(:review, user: user, recipe: recipe, rating: 4, body: "Solid midweek dinner")
      Like.create!(user: user, recipe: recipe)
      NutritionInfo.create!(recipe: recipe, calories: 520, protein_g: 30, carbs_g: 44,
                            fat_g: 22, fiber_g: 6, sodium_mg: 800, per_servings: 4)

      get recipe_path(recipe.reload)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Solid midweek dinner")
      expect(response.body).to include("Nutrition")
    end

    it "renders icons as inline SVG rather than emoji" do
      get root_path
      expect(response.body).to include('class="icon icon-')
    end
  end
end
