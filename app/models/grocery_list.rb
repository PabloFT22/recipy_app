class GroceryList < ApplicationRecord
  belongs_to :user
  has_many :grocery_list_items, dependent: :destroy
  has_many :ingredients, through: :grocery_list_items
  
  validates :name, presence: true
  validates :status, inclusion: { in: %w[active completed archived] }
  
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :recent, -> { order(created_at: :desc) }
  
  def add_recipes(recipes, servings_multiplier = 1)
    recipes.each do |recipe|
      recipe.recipe_ingredients.each do |recipe_ingredient|
        add_or_update_ingredient(
          recipe_ingredient.ingredient,
          recipe_ingredient.quantity * servings_multiplier,
          recipe_ingredient.unit
        )
      end
    end
  end
  
  def add_or_update_ingredient(ingredient, quantity, unit)
    item = grocery_list_items.find_or_initialize_by(ingredient: ingredient, unit: unit)
    
    if item.persisted?
      item.quantity = (item.quantity || 0) + (quantity || 0)
      item.save
    else
      item.quantity = quantity
      item.checked = false
      item.on_hand = false
      item.save
    end
    
    item
  end
  
  def complete!
    update(status: 'completed')
  end
  
  def archive!
    update(status: 'archived')
  end
  
  def items_by_category
    grocery_list_items
      .includes(:ingredient)
      .group_by { |item| item.ingredient.category || 'other' }
      .sort_by { |category, _| Ingredient::CATEGORIES.index(category) || 999 }
  end
  
  def total_items
    grocery_list_items.count
  end
  
  def checked_items
    grocery_list_items.where(checked: true).count
  end
  
  def progress_percentage
    return 0 if total_items.zero?
    ((checked_items.to_f / total_items) * 100).round
  end
end
