class Recipe < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  belongs_to :user
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_collection_memberships, dependent: :destroy
  has_many :recipe_collections, through: :recipe_collection_memberships
  has_many :meal_plan_recipes, dependent: :destroy
  has_many :meal_plans, through: :meal_plan_recipes
  has_one_attached :image
  
  validates :title, presence: true
  validates :servings, numericality: { greater_than: 0, allow_nil: true }
  validates :prep_time, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :cook_time, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :difficulty, inclusion: { in: %w[easy medium hard], allow_nil: true }
  
  scope :public_recipes, -> { where(is_public: true) }
  scope :private_recipes, -> { where(is_public: false) }
  scope :by_difficulty, ->(difficulty) { where(difficulty: difficulty) }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { includes(:meal_plan_recipes).group(:id).order('COUNT(meal_plan_recipes.id) DESC') }
  scope :search, ->(query) do
    where("title LIKE ? OR description LIKE ?", "%#{query}%", "%#{query}%")
  end
  
  def total_time
    return nil unless prep_time && cook_time
    prep_time + cook_time
  end
  
  def scale_servings(new_servings)
    multiplier = new_servings.to_f / servings
    recipe_ingredients.map do |ri|
      {
        ingredient: ri.ingredient,
        quantity: (ri.quantity * multiplier).round(2),
        unit: ri.unit,
        notes: ri.notes
      }
    end
  end
  
  def should_generate_new_friendly_id?
    title_changed? || super
  end
end
