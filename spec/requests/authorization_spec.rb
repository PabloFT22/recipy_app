require 'rails_helper'

# Cross-user access checks. Every one of these is an IDOR probe: the attacker is
# a legitimate signed-in user guessing another user's record id.
RSpec.describe "Authorization", type: :request do
  let(:victim)   { create(:user) }
  let(:attacker) { create(:user) }

  before { sign_in attacker }

  describe "private recipes" do
    let!(:secret) { create(:recipe, user: victim, title: "Victim Secret", is_public: false) }

    it "cannot be viewed directly" do
      get recipe_path(secret)
      expect(response).to redirect_to(recipes_path)
      expect(response.body).not_to include("Victim Secret")
    end

    it "cannot be scheduled into my meal plan" do
      plan = create(:meal_plan, user: attacker)

      post meal_plan_meal_plan_recipes_path(plan), params: {
        meal_plan_recipe: {
          recipe_id: secret.id,
          scheduled_for: plan.start_date,
          meal_type: "dinner",
          servings: 2
        }
      }

      expect(plan.meal_plan_recipes.count).to eq(0)
      follow_redirect!
      expect(response.body).not_to include("Victim Secret")
    end

    it "cannot be swapped in via a meal plan recipe update" do
      plan = create(:meal_plan, user: attacker)
      mine = create(:recipe, user: attacker, title: "My Own Recipe")
      mpr  = create(:meal_plan_recipe, meal_plan: plan, recipe: mine,
                                       scheduled_for: plan.start_date, meal_type: "lunch")

      patch meal_plan_meal_plan_recipe_path(plan, mpr), params: {
        meal_plan_recipe: { recipe_id: secret.id }
      }

      expect(mpr.reload.recipe_id).to eq(mine.id)
    end

    it "cannot be added to my collection" do
      collection = create(:recipe_collection, user: attacker)

      post add_recipe_recipe_collection_path(collection), params: { recipe_id: secret.slug }

      expect(collection.recipes.count).to eq(0)
    end

    it "cannot be duplicated into my account" do
      expect {
        post duplicate_recipe_path(secret)
      }.not_to change(attacker.recipes, :count)
    end
  end

  describe "public recipes" do
    let!(:shared) { create(:recipe, user: victim, title: "Shared Dish", is_public: true) }

    it "can be scheduled into my meal plan" do
      plan = create(:meal_plan, user: attacker)

      post meal_plan_meal_plan_recipes_path(plan), params: {
        meal_plan_recipe: {
          recipe_id: shared.id,
          scheduled_for: plan.start_date,
          meal_type: "dinner",
          servings: 2
        }
      }

      expect(plan.meal_plan_recipes.count).to eq(1)
    end
  end

  # A miss on a `current_user.x.find` raises RecordNotFound, which production
  # renders as the static 404 page. Only the status is asserted here: the test
  # environment's debug error page echoes request/exception detail that the
  # public 404 never shows.
  describe "other users' records" do
    it "does not expose another user's meal plan" do
      plan = create(:meal_plan, user: victim, name: "Victim Week")
      get meal_plan_path(plan)
      expect(response).to have_http_status(:not_found)
    end

    it "does not expose another user's grocery list" do
      list = create(:grocery_list, user: victim, name: "Victim Shop")
      get grocery_list_path(list)
      expect(response).to have_http_status(:not_found)
    end

    it "does not expose another user's collection" do
      collection = create(:recipe_collection, user: victim, name: "Victim Collection")
      get recipe_collection_path(collection)
      expect(response).to have_http_status(:not_found)
    end

    it "does not let me edit another user's recipe" do
      recipe = create(:recipe, user: victim, title: "Victim Editable", is_public: true)
      patch recipe_path(recipe), params: { recipe: { title: "Hijacked" } }
      expect(recipe.reload.title).to eq("Victim Editable")
    end

    it "does not let me delete another user's recipe" do
      recipe = create(:recipe, user: victim, is_public: true)
      expect { delete recipe_path(recipe) }.not_to change(Recipe, :count)
    end
  end

  describe "tag search" do
    it "only returns my own tags" do
      create(:tag, user: victim, name: "victimtag")
      create(:tag, user: attacker, name: "minetag")

      get tags_search_path(q: "tag")

      names = JSON.parse(response.body).map { |t| t["name"] }
      expect(names).to include("minetag")
      expect(names).not_to include("victimtag")
    end
  end

  describe "signed out" do
    before { sign_out attacker }

    it "redirects protected pages to sign in" do
      [meal_plans_path, grocery_lists_path, recipe_collections_path, pantry_path, new_recipe_path].each do |path|
        get path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
