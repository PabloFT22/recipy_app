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
        scaled_quantity = if recipe_ingredient.quantity
                           recipe_ingredient.quantity * servings_multiplier
                         end
        add_or_update_ingredient(
          recipe_ingredient.ingredient,
          scaled_quantity,
          recipe_ingredient.unit
        )
      end
    end
  end
  
  def add_or_update_ingredient(ingredient, quantity, unit)
    # Normalize size qualifiers (large, medium, small, whole, pieces) to plain count
    normalized_unit = if UnitConversionService::SIZE_QUALIFIERS.include?(unit)
                        nil
                      else
                        unit
                      end

    # Try to find an existing item for this ingredient with a combinable unit
    existing_item = grocery_list_items
      .where(ingredient: ingredient)
      .detect { |item| UnitConversionService.combinable?(item.unit, normalized_unit) }

    if existing_item
      if quantity && existing_item.quantity
        # Convert the new quantity into the existing item's unit family base,
        # then add and pick the best display unit
        family, = UnitConversionService.unit_family(existing_item.unit)

        case family
        when :volume
          existing_tsp = existing_item.quantity * (UnitConversionService::VOLUME_TO_TSP[existing_item.unit] || 1)
          new_tsp = quantity * (UnitConversionService::VOLUME_TO_TSP[normalized_unit] || 1)
          total_tsp = existing_tsp + new_tsp
          best_qty, best_unit = UnitConversionService.best_volume_unit(total_tsp)
          existing_item.quantity = best_qty.round(3)
          existing_item.unit = best_unit
        when :weight_metric
          existing_base = existing_item.quantity * UnitConversionService::WEIGHT_METRIC_TO_G[existing_item.unit]
          new_base = quantity * UnitConversionService::WEIGHT_METRIC_TO_G[normalized_unit]
          total = existing_base + new_base
          best_qty, best_unit = UnitConversionService.best_metric_weight_unit(total)
          existing_item.quantity = best_qty.round(3)
          existing_item.unit = best_unit
        when :weight_imperial
          existing_base = existing_item.quantity * UnitConversionService::WEIGHT_IMPERIAL_TO_OZ[existing_item.unit]
          new_base = quantity * UnitConversionService::WEIGHT_IMPERIAL_TO_OZ[normalized_unit]
          total = existing_base + new_base
          best_qty, best_unit = UnitConversionService.best_imperial_weight_unit(total)
          existing_item.quantity = best_qty.round(3)
          existing_item.unit = best_unit
        else
          # :count or :other — just add quantities
          existing_item.quantity = (existing_item.quantity || 0) + (quantity || 0)
        end
      elsif quantity
        existing_item.quantity = quantity
        existing_item.unit = normalized_unit
      end
      # If both are nil quantity, nothing to update
      existing_item.save
      existing_item
    else
      is_pantry = user.pantry_items.exists?(ingredient: ingredient)
      item = grocery_list_items.build(
        ingredient: ingredient,
        quantity: quantity,
        unit: normalized_unit,
        checked: false,
        on_hand: is_pantry
      )
      item.save
      item
    end
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
