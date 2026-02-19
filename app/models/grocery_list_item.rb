class GroceryListItem < ApplicationRecord
  belongs_to :grocery_list
  belongs_to :ingredient
  
  validates :quantity, numericality: { greater_than: 0, allow_nil: true }
  
  scope :unchecked, -> { where(checked: false) }
  scope :checked, -> { where(checked: true) }
  scope :needed, -> { where(on_hand: false) }
  scope :on_hand, -> { where(on_hand: true) }
  
  def toggle_checked!
    update(checked: !checked)
  end
  
  def toggle_on_hand!
    update(on_hand: !on_hand)
  end
  
  def display_quantity
    return "To taste" unless quantity
    
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
