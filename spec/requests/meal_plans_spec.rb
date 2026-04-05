require 'rails_helper'

RSpec.describe "Meal Plans", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET /meal_plans" do
    it "returns http success" do
      get meal_plans_path
      expect(response).to have_http_status(:success)
    end

    it "renders meal plan cards when plans exist" do
      create(:meal_plan, user: user, name: "Week 1")
      get meal_plans_path
      expect(response.body).to include("Week 1")
    end

    it "shows empty state when no plans exist" do
      get meal_plans_path
      expect(response.body).to include("No meal plans yet")
    end
  end

  describe "GET /meal_plans/new" do
    it "returns http success" do
      get new_meal_plan_path
      expect(response).to have_http_status(:success)
    end

    it "renders the form" do
      get new_meal_plan_path
      expect(response.body).to include("Create New Meal Plan")
    end
  end

  describe "POST /meal_plans" do
    it "creates a meal plan and redirects" do
      expect {
        post meal_plans_path, params: {
          meal_plan: { name: "Test Plan", start_date: Date.current, end_date: Date.current + 7.days }
        }
      }.to change(MealPlan, :count).by(1)
      expect(response).to redirect_to(MealPlan.last)
    end

    it "re-renders new on validation error" do
      post meal_plans_path, params: {
        meal_plan: { name: "", start_date: Date.current, end_date: Date.current + 7.days }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /meal_plans/:id" do
    let(:meal_plan) { create(:meal_plan, user: user) }

    it "returns http success" do
      get meal_plan_path(meal_plan)
      expect(response).to have_http_status(:success)
    end

    it "renders the calendar grid" do
      get meal_plan_path(meal_plan)
      expect(response.body).to include("mp-calendar")
      expect(response.body).to include("Breakfast")
      expect(response.body).to include("Lunch")
      expect(response.body).to include("Dinner")
      expect(response.body).to include("Snack")
    end

    it "shows the recipe picker modal" do
      get meal_plan_path(meal_plan)
      expect(response.body).to include("mp-picker-overlay")
    end

    it "shows recipes assigned to the plan" do
      recipe = create(:recipe, user: user, title: "Test Pasta")
      create(:meal_plan_recipe, meal_plan: meal_plan, recipe: recipe,
             scheduled_for: meal_plan.start_date, meal_type: "dinner")
      get meal_plan_path(meal_plan)
      expect(response.body).to include("Test Pasta")
    end
  end

  describe "GET /meal_plans/:id/edit" do
    let(:meal_plan) { create(:meal_plan, user: user) }

    it "returns http success" do
      get edit_meal_plan_path(meal_plan)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /meal_plans/:id" do
    let(:meal_plan) { create(:meal_plan, user: user) }

    it "updates and redirects" do
      patch meal_plan_path(meal_plan), params: { meal_plan: { name: "Updated" } }
      expect(response).to redirect_to(meal_plan)
      expect(meal_plan.reload.name).to eq("Updated")
    end
  end

  describe "DELETE /meal_plans/:id" do
    let!(:meal_plan) { create(:meal_plan, user: user) }

    it "deletes and redirects" do
      expect { delete meal_plan_path(meal_plan) }.to change(MealPlan, :count).by(-1)
      expect(response).to redirect_to(meal_plans_url)
    end
  end

  describe "POST /meal_plans/:id/generate_grocery_list" do
    let(:meal_plan) { create(:meal_plan, user: user) }

    it "redirects with alert when no recipes" do
      post generate_grocery_list_meal_plan_path(meal_plan)
      expect(response).to redirect_to(meal_plan)
      expect(flash[:alert]).to include("no recipes")
    end

    it "generates a grocery list when recipes exist" do
      recipe = create(:recipe, user: user, servings: 4)
      ingredient = create(:ingredient)
      create(:recipe_ingredient, recipe: recipe, ingredient: ingredient, quantity: 2, unit: "cup")
      create(:meal_plan_recipe, meal_plan: meal_plan, recipe: recipe,
             scheduled_for: meal_plan.start_date, meal_type: "dinner", servings: 4)

      expect {
        post generate_grocery_list_meal_plan_path(meal_plan)
      }.to change(GroceryList, :count).by(1)
      expect(response).to redirect_to(GroceryList.last)
    end
  end
end

RSpec.describe "Meal Plan Recipes", type: :request do
  let(:user) { create(:user) }
  let(:meal_plan) { create(:meal_plan, user: user) }
  let(:recipe) { create(:recipe, user: user) }
  before { sign_in user }

  describe "POST /meal_plans/:meal_plan_id/meal_plan_recipes" do
    it "adds a recipe to the meal plan" do
      expect {
        post meal_plan_meal_plan_recipes_path(meal_plan), params: {
          meal_plan_recipe: {
            recipe_id: recipe.id,
            scheduled_for: meal_plan.start_date,
            meal_type: "dinner",
            servings: 4
          }
        }
      }.to change(MealPlanRecipe, :count).by(1)
      expect(response).to redirect_to(meal_plan)
    end
  end

  describe "DELETE /meal_plans/:meal_plan_id/meal_plan_recipes/:id" do
    let!(:mpr) { create(:meal_plan_recipe, meal_plan: meal_plan, recipe: recipe) }

    it "removes the recipe from the plan" do
      expect {
        delete meal_plan_meal_plan_recipe_path(meal_plan, mpr)
      }.to change(MealPlanRecipe, :count).by(-1)
      expect(response).to redirect_to(meal_plan)
    end
  end
end
