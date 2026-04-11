class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient
  
  validates :quantity, numericality: { greater_than: 0, allow_nil: true }
  validates :ingredient_id, uniqueness: { scope: :recipe_id, message: "already added to this recipe" }
  
  UNITS = %w[
    cup cups
    tablespoon tablespoons tbsp
    teaspoon teaspoons tsp
    ounce ounces oz
    pound pounds lb
    gram grams g
    kilogram kilograms kg
    milliliter milliliters ml
    liter liters l
    pinch
    dash
    piece pieces
    whole
    to_taste
  ].freeze
  
  validates :unit, inclusion: { in: UNITS, allow_blank: true }
  
  def display_quantity
    return "To taste" if unit == "to_taste"
    return "" unless quantity

    # Convert decimal to fraction if possible
    fraction = to_fraction(quantity)
    fraction || quantity.to_s
  end
  
  private
  
  def to_fraction(decimal)
    return nil unless decimal.is_a?(Numeric)
    
    fractions = {
      0.25 => "1/4",
      0.33 => "1/3",
      0.5 => "1/2",
      0.66 => "2/3",
      0.75 => "3/4",
      1.5 => "1 1/2",
      2.5 => "2 1/2"
    }
    
    fractions[decimal]
  end
end
