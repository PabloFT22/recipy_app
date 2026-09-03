require 'rails_helper'

# Regressions found on the first production deploy (2026-09-03).
RSpec.describe "Recipes form", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "POST /recipes" do
    it "saves a recipe when the difficulty select is left on its prompt" do
      post recipes_path, params: { recipe: { title: "Fried Chicken", difficulty: "", servings: "4" } }

      expect(response).to redirect_to(recipe_path(Recipe.last))
      expect(Recipe.last.difficulty).to be_nil
    end
  end

  describe "PATCH /recipes/:id with a photo and an invalid field" do
    let(:recipe) { create(:recipe, user: user) }

    it "re-renders the form with the error instead of raising on the unsaved photo" do
      photo = fixture_file_upload("photo.png", "image/png")
      patch recipe_path(recipe), params: { recipe: { title: "", image: photo } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Title can")
      expect(recipe.reload.image).not_to be_attached
    end
  end
end
