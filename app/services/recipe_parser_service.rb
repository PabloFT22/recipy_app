class RecipeParserService
  attr_reader :text, :errors
  
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
    line = line.gsub(/^[-•*]\s*/, '')
    
    pattern = /^(\d+(?:[\.,]\d+)?|\d+\s*\/\s*\d+|\d+\s+\d+\s*\/\s*\d+)?\s*([a-zA-Z]+)?\s+(.+)$/
    match = line.match(pattern)
    
    return nil unless match
    
    quantity_str = match[1]
    unit = match[2]
    rest = match[3]
    
    parts = rest.split(',', 2)
    ingredient_name = parts[0].strip
    notes = parts[1]&.strip
    
    quantity = parse_quantity(quantity_str)
    unit = normalize_unit(unit)
    
    if ingredient_name.match?(/to taste/i)
      ingredient_name = ingredient_name.gsub(/to taste/i, '').strip
      unit = 'to_taste'
      quantity = nil
    end
    
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
