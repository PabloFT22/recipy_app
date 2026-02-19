class RecipeCollectionMembership < ApplicationRecord
  belongs_to :recipe
  belongs_to :recipe_collection
  
  # Validations
  validates :recipe_id, uniqueness: { scope: :recipe_collection_id }
end
