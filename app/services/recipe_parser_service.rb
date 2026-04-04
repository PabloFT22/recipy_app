class RecipeParserService
  attr_reader :text, :errors

  # Words that represent numbers
  WORD_NUMBERS = {
    'one' => 1, 'two' => 2, 'three' => 3, 'four' => 4, 'five' => 5,
    'six' => 6, 'seven' => 7, 'eight' => 8, 'nine' => 9, 'ten' => 10,
    'eleven' => 11, 'twelve' => 12, 'a' => 1, 'an' => 1
  }.freeze

  # Known units (singular forms — normalize_unit maps them)
  UNIT_WORDS = %w[
    cup cups tablespoon tablespoons tbsp tbs teaspoon teaspoons tsp
    ounce ounces oz pound pounds lb lbs gram grams g kilogram kilograms kg
    milliliter milliliters ml liter liters l
    pinch dash piece pieces whole
    spoon spoons slice slices clove cloves bunch bunches handful handfuls
    can cans bottle bottles bag bags box boxes package packages pkg
    stick sticks head heads stalk stalks sprig sprigs leaf leaves
    strip strips fillet fillets breast breasts thigh thighs leg legs
    rack racks ear ears sheet sheets pint pints quart quarts gallon gallons
    pc pcs
  ].freeze

  def initialize(text)
    @text = text
    @errors = []
  end

  def parse
    return [] if text.blank?

    ingredients = []
    lines = text.split("\n").map(&:strip).reject(&:blank?)

    lines.each do |line|
      parsed = parse_ingredient_line(line)
      ingredients << parsed if parsed
    end

    ingredients
  end

  private

  def parse_ingredient_line(line)
    # Strip leading bullets, dashes, numbers with periods ("1.") but NOT decimals ("1.5")
    line = line.gsub(/^[-•*▪]\s*/, '').gsub(/^\d+\.(?!\d)\s*/, '').strip
    return nil if line.blank?

    remaining = line.dup
    quantity = nil
    unit = nil
    notes = nil

    # --- Extract quantity ---
    # Match patterns like: "1/2", "1 1/2", "2.5", "2,5", "One", "10"
    quantity_pattern = /^(\d+\s+\d+\s*\/\s*\d+|\d+\s*\/\s*\d+|\d+(?:[.,]\d+)?)/
    word_number_pattern = /^(#{WORD_NUMBERS.keys.join('|')})\b/i

    if remaining.match?(quantity_pattern)
      match = remaining.match(quantity_pattern)
      quantity = parse_quantity(match[0])
      remaining = remaining[match[0].length..].strip
    elsif remaining.match?(word_number_pattern)
      match = remaining.match(word_number_pattern)
      quantity = WORD_NUMBERS[match[0].downcase].to_f
      remaining = remaining[match[0].length..].strip
    end

    # --- Strip parenthetical info before unit check ---
    # e.g., "(20 ounces)" or "(about 2 cups)" — move to notes
    paren_notes = []
    while remaining.match?(/^\(([^)]*)\)/)
      match = remaining.match(/^\(([^)]*)\)/)
      paren_notes << match[1].strip
      remaining = remaining[match[0].length..].strip
    end

    # --- Extract unit ---
    # Check if the next word(s) are a known unit
    # Handle compound units like "8-ounce" as in "8-ounce block"
    compound_unit_pattern = /^(\d+)\s*-\s*(#{UNIT_WORDS.join('|')})\b/i
    simple_unit_pattern = /^(#{UNIT_WORDS.join('|')})\b/i

    if remaining.match?(compound_unit_pattern)
      match = remaining.match(compound_unit_pattern)
      # "8-ounce block feta" → quantity=8, unit=ounces, rest="block feta"
      quantity = match[1].to_f
      unit = normalize_unit(match[2])
      remaining = remaining[match[0].length..].strip
    elsif remaining.match?(simple_unit_pattern)
      match = remaining.match(simple_unit_pattern)
      unit = normalize_unit(match[1])
      remaining = remaining[match[0].length..].strip
    end

    # --- Strip parenthetical info again (may appear after the unit) ---
    # e.g., "2 pints (20 ounces) cherry tomatoes" → after unit extraction: "(20 ounces) cherry tomatoes"
    while remaining.match?(/^\(([^)]*)\)/)
      match = remaining.match(/^\(([^)]*)\)/)
      paren_notes << match[1].strip
      remaining = remaining[match[0].length..].strip
    end

    # --- Extract ingredient name and notes ---
    # Split on comma — first part is name, rest is notes
    parts = remaining.split(',', 2)
    ingredient_name = parts[0].strip
    comma_notes = parts[1]&.strip

    # Combine all notes
    all_notes = (paren_notes + [comma_notes].compact).reject(&:blank?)
    notes = all_notes.join(', ') if all_notes.any?

    # Handle "to taste" in ingredient name
    if ingredient_name.match?(/to taste/i)
      ingredient_name = ingredient_name.gsub(/to taste/i, '').strip
      unit = 'to_taste'
      quantity = nil
    end

    # Handle "optional" in notes or name
    if ingredient_name.match?(/\boptional\b/i)
      ingredient_name = ingredient_name.gsub(/\boptional\b/i, '').strip
      notes = [notes, 'optional'].compact.join(', ')
    end

    # If we still have no ingredient name, use the whole line
    ingredient_name = line if ingredient_name.blank?

    # Clean up ingredient name
    ingredient_name = ingredient_name.gsub(/\s+/, ' ').strip

    return nil if ingredient_name.blank?

    {
      ingredient_name: ingredient_name,
      quantity: quantity,
      unit: unit,
      notes: notes
    }
  rescue StandardError => e
    @errors << "Error parsing line '#{line}': #{e.message}"
    nil
  end
  
  def parse_quantity(quantity_str)
    return nil if quantity_str.blank?
    
    if quantity_str.include?('/')
      parts = quantity_str.split(/\s+/)
      
      if parts.length == 2
        whole = parts[0].to_f
        fraction_parts = parts[1].split('/')
        fraction = fraction_parts[0].to_f / fraction_parts[1].to_f
        return whole + fraction
      else
        fraction_parts = quantity_str.split('/')
        return fraction_parts[0].to_f / fraction_parts[1].to_f
      end
    end
    
    quantity_str.gsub(',', '.').to_f
  end
  
  def normalize_unit(unit)
    return nil if unit.blank?
    
    unit = unit.downcase.strip
    
    unit_map = {
      'cup' => 'cups',
      'c' => 'cups',
      'tablespoon' => 'tablespoons',
      'tbsp' => 'tablespoons',
      'tbs' => 'tablespoons',
      'teaspoon' => 'teaspoons',
      'tsp' => 'teaspoons',
      'ounce' => 'ounces',
      'oz' => 'ounces',
      'pound' => 'pounds',
      'lb' => 'pounds',
      'lbs' => 'pounds',
      'gram' => 'grams',
      'g' => 'grams',
      'kilogram' => 'kilograms',
      'kg' => 'kilograms',
      'milliliter' => 'milliliters',
      'ml' => 'milliliters',
      'liter' => 'liters',
      'l' => 'liters',
      'spoon' => 'spoons',
      'slice' => 'slices',
      'clove' => 'cloves',
      'bunch' => 'bunches',
      'handful' => 'handfuls',
      'can' => 'cans',
      'bottle' => 'bottles',
      'bag' => 'bags',
      'box' => 'boxes',
      'package' => 'packages',
      'pkg' => 'packages',
      'stick' => 'sticks',
      'head' => 'heads',
      'stalk' => 'stalks',
      'sprig' => 'sprigs',
      'leaf' => 'leaves',
      'strip' => 'strips',
      'fillet' => 'fillets',
      'breast' => 'breasts',
      'thigh' => 'thighs',
      'leg' => 'legs',
      'rack' => 'racks',
      'ear' => 'ears',
      'sheet' => 'sheets',
      'piece' => 'pieces',
      'pc' => 'pieces',
      'pcs' => 'pieces'
    }
    
    unit_map[unit] || unit
  end
end
