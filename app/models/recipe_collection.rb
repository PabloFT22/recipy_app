class RecipeCollection < ApplicationRecord
  belongs_to :user
  has_many :recipe_collection_memberships, dependent: :destroy
  has_many :recipes, through: :recipe_collection_memberships
  
  validates :name, presence: true
  
  scope :recent, -> { order(created_at: :desc) }
  
  def add_recipe(recipe)
    recipes << recipe unless recipes.include?(recipe)
  end
  
  def remove_recipe(recipe)
    recipes.delete(recipe)
  end
  
  def recipe_count
    recipes.count
  end
end
