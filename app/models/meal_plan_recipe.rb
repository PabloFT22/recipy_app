class MealPlanRecipe < ApplicationRecord
  belongs_to :meal_plan
  belongs_to :recipe
  
  # Validations
  validates :scheduled_for, presence: true
  validates :servings, numericality: { greater_than: 0 }
  validates :meal_type, inclusion: { in: %w[breakfast lunch dinner snack] }
  
  # Scopes
  scope :for_date, ->(date) { where(scheduled_for: date) }
  scope :breakfast, -> { where(meal_type: 'breakfast') }
  scope :lunch, -> { where(meal_type: 'lunch') }
  scope :dinner, -> { where(meal_type: 'dinner') }
  scope :snack, -> { where(meal_type: 'snack') }
  
  # Before validation, set default servings from recipe
  before_validation :set_default_servings, on: :create
  
  private
  
  def set_default_servings
    self.servings ||= recipe.servings if recipe
  end
end
