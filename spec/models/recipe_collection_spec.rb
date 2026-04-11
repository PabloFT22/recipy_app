require 'rails_helper'

RSpec.describe RecipeCollection, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:recipe_collection_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:recipes).through(:recipe_collection_memberships) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#add_recipe' do
    it 'adds a recipe to the collection' do
      collection = create(:recipe_collection)
      recipe = create(:recipe)
      collection.add_recipe(recipe)
      expect(collection.recipes).to include(recipe)
    end

    it 'does not duplicate a recipe' do
      collection = create(:recipe_collection)
      recipe = create(:recipe)
      collection.add_recipe(recipe)
      collection.add_recipe(recipe)
      expect(collection.recipes.count).to eq(1)
    end
  end

  describe '#remove_recipe' do
    it 'removes a recipe from the collection' do
      collection = create(:recipe_collection)
      recipe = create(:recipe)
      collection.add_recipe(recipe)
      collection.remove_recipe(recipe)
      expect(collection.recipes).not_to include(recipe)
    end
  end
end
