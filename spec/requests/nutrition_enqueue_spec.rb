require 'rails_helper'

# The nutrition panel only ever appears if NutritionFetchJob runs, and the job
# is only useful once the ingredient rows exist. Ingredients are written after
# the recipe row is saved, so the enqueue has to happen from the controller,
# not from a save callback. (Found on the first production deploy: no path
# enqueued the job at all.)
RSpec.describe "Nutrition fetch enqueueing", type: :request do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  before { sign_in user }

  let(:rows) { [{ quantity: "2", unit: "cups", name: "flour", notes: "" }] }

  it "enqueues a fetch when a recipe is created with ingredients" do
    expect {
      post recipes_path, params: { recipe: { title: "Bread", servings: "4", ingredients_rows: rows } }
    }.to have_enqueued_job(NutritionFetchJob).with(kind_of(Integer))
  end

  it "enqueues a fetch when a recipe's ingredients are edited" do
    recipe = create(:recipe, user: user)

    expect {
      patch recipe_path(recipe), params: { recipe: { title: recipe.title, ingredients_rows: rows } }
    }.to have_enqueued_job(NutritionFetchJob).with(recipe.id)
  end

  it "does not enqueue a fetch when a recipe has no ingredients" do
    expect {
      post recipes_path, params: { recipe: { title: "Water", servings: "1" } }
    }.not_to have_enqueued_job(NutritionFetchJob)
  end
end
