class MealPlan < ApplicationRecord
  belongs_to :user
  has_many :meal_plan_recipes, dependent: :destroy
  has_many :recipes, through: :meal_plan_recipes
  
  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date
  
  scope :active, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }
  scope :upcoming, -> { where('start_date > ?', Date.current) }
  scope :past, -> { where('end_date < ?', Date.current) }
  scope :recent, -> { order(start_date: :desc) }
  
  def generate_grocery_list(name: nil)
    list_name = name || "#{self.name} - Grocery List"
    grocery_list = user.grocery_lists.create!(name: list_name, status: 'active')
    
    meal_plan_recipes.includes(recipe: [:recipe_ingredients, :ingredients]).each do |meal_plan_recipe|
      multiplier = meal_plan_recipe.servings.to_f / meal_plan_recipe.recipe.servings
      grocery_list.add_recipes([meal_plan_recipe.recipe], multiplier)
    end
    
    grocery_list
  end
  
  def recipes_by_date
    meal_plan_recipes
      .includes(:recipe)
      .group_by(&:scheduled_for)
      .sort_by { |date, _| date }
  end
  
  def total_recipes
    meal_plan_recipes.count
  end
  
  private
  
  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    
    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
