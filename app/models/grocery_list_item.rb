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
    return "To taste" if unit == "to_taste"
    return nil unless quantity

    display_friendly_number(quantity)
  end

  # Smart display: "8 egg" → "8 eggs", "1 cups" → "1 cup"
  def display_unit
    return nil if unit.blank?
    return "to taste" if unit == "to_taste"

    if quantity && quantity <= 1
      singularize_unit(unit)
    else
      pluralize_unit(unit)
    end
  end

  # Smart display of ingredient name with plural awareness
  def display_name
    name = ingredient.name
    return name if unit.present? # Unit carries the plural, name stays as-is
    return name unless quantity  # No quantity, no plural logic

    # No unit — the name itself should be pluralized if qty > 1
    # e.g., "8 egg" → "8 eggs"
    if quantity > 1
      smart_pluralize(name)
    elsif quantity <= 1
      smart_singularize(name)
    else
      name
    end
  end

  private

  # Convert a number to a clean display string with fractions where appropriate
  def display_friendly_number(value)
    return nil unless value

    float_val = value.to_f
    whole = float_val.floor
    remainder = (float_val - whole).round(3)

    # Map common remainders to fractions
    fraction_map = {
      0.125 => "⅛", 0.167 => "⅙",
      0.2   => "⅕", 0.25  => "¼",
      0.333 => "⅓",
      0.375 => "⅜", 0.4   => "⅖",
      0.5   => "½", 0.6   => "⅗",
      0.625 => "⅝", 0.667 => "⅔",
      0.75  => "¾", 0.8   => "⅘",
      0.833 => "⅚", 0.875 => "⅞"
    }

    # Find the closest fraction within a small tolerance
    fraction_str = nil
    fraction_map.each do |dec, str|
      if (remainder - dec).abs < 0.02
        fraction_str = str
        break
      end
    end

    if fraction_str
      whole > 0 ? "#{whole} #{fraction_str}" : fraction_str
    elsif remainder == 0.0
      whole.to_s
    else
      # No clean fraction match — round to 1 decimal
      ("%.1f" % float_val).sub(/\.0$/, '')
    end
  end

  SINGULAR_TO_PLURAL = {
    'cup' => 'cups', 'tablespoon' => 'tablespoons', 'teaspoon' => 'teaspoons',
    'ounce' => 'ounces', 'pound' => 'pounds', 'gram' => 'grams',
    'kilogram' => 'kilograms', 'milliliter' => 'milliliters', 'liter' => 'liters',
    'piece' => 'pieces', 'slice' => 'slices', 'clove' => 'cloves',
    'bunch' => 'bunches', 'handful' => 'handfuls', 'can' => 'cans',
    'bottle' => 'bottles', 'bag' => 'bags', 'box' => 'boxes',
    'package' => 'packages', 'stick' => 'sticks', 'head' => 'heads',
    'stalk' => 'stalks', 'sprig' => 'sprigs', 'leaf' => 'leaves',
    'strip' => 'strips', 'spoon' => 'spoons', 'sheet' => 'sheets',
    'ear' => 'ears', 'breast' => 'breasts', 'thigh' => 'thighs',
    'fillet' => 'fillets', 'leg' => 'legs', 'rack' => 'racks'
  }.freeze

  PLURAL_TO_SINGULAR = SINGULAR_TO_PLURAL.invert.freeze

  def singularize_unit(u)
    PLURAL_TO_SINGULAR[u] || u
  end

  def pluralize_unit(u)
    SINGULAR_TO_PLURAL[u] || u
  end

  # Simple English pluralization for ingredient names (no unit case)
  def smart_pluralize(name)
    return name if name.blank?
    word = name.strip

    # Already plural-looking
    return word if word.end_with?('s') && !word.end_with?('ss')

    # Common irregular plurals
    irregulars = { 'leaf' => 'leaves', 'loaf' => 'loaves', 'potato' => 'potatoes',
                   'tomato' => 'tomatoes', 'mango' => 'mangoes' }
    irregulars.each do |sing, plur|
      return word.sub(/#{sing}$/i, plur) if word.downcase.end_with?(sing)
    end

    # Standard rules
    if word.end_with?('sh', 'ch', 'x', 'ss', 'z')
      "#{word}es"
    elsif word.end_with?('y') && !word[-2]&.match?(/[aeiou]/i)
      "#{word[0..-2]}ies"
    else
      "#{word}s"
    end
  end

  # Simple English singularization for ingredient names
  def smart_singularize(name)
    return name if name.blank?
    word = name.strip

    # Common irregular plurals (reverse)
    irregulars = { 'leaves' => 'leaf', 'loaves' => 'loaf', 'potatoes' => 'potato',
                   'tomatoes' => 'tomato', 'mangoes' => 'mango', 'eggs' => 'egg' }
    irregulars.each do |plur, sing|
      return word.sub(/#{plur}$/i, sing) if word.downcase.end_with?(plur)
    end

    # Don't singularize words that aren't obviously plural
    return word unless word.end_with?('s') && !word.end_with?('ss')

    # Standard rules
    if word.end_with?('ies') && word.length > 4
      "#{word[0..-4]}y"
    elsif word.end_with?('es') && word[-3]&.match?(/[shxz]/)
      word[0..-3]
    elsif word.end_with?('s')
      word[0..-2]
    else
      word
    end
  end
end
