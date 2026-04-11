require 'rails_helper'

RSpec.describe RecipeCollectionMembership, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:recipe) }
    it { is_expected.to belong_to(:recipe_collection) }
  end

  describe 'validations' do
    it 'validates uniqueness of recipe_id scoped to recipe_collection_id' do
      membership = create(:recipe_collection_membership)
      duplicate = build(:recipe_collection_membership,
                        recipe: membership.recipe,
                        recipe_collection: membership.recipe_collection)
      expect(duplicate).not_to be_valid
    end
  end
end
