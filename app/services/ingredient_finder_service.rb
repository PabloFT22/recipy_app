class IngredientFinderService
  attr_reader :name
  
  def initialize(name)
    @name = name
  end
  
  def find_or_create
    return nil if name.blank?
    
    normalized = normalize_name(name)
    ingredient = Ingredient.find_by(normalized_name: normalized)
    
    ingredient ||= Ingredient.create(
      name: name,
      normalized_name: normalized,
      category: guess_category(normalized)
    )
    
    ingredient
  end
  
  private
  
  def normalize_name(text)
    normalized = text.downcase.strip.gsub(/\s+/, ' ')
    
    descriptors = %w[fresh dried chopped diced sliced minced crushed whole ground]
    descriptors.each do |descriptor|
      normalized = normalized.gsub(/\b#{descriptor}\b/, '').strip
    end
    
    normalized = normalized.singularize
    normalized
  end
  
  def guess_category(normalized_name)
    produce = %w[
      tomato potato onion garlic carrot celery pepper lettuce spinach
      apple banana orange lemon lime avocado cucumber zucchini
      broccoli cauliflower cabbage mushroom
    ]
    
    dairy = %w[
      milk cream cheese butter yogurt sour\ cream half-and-half
      mozzarella cheddar parmesan
    ]
    
    meat = %w[
      chicken beef pork turkey bacon sausage ham
      ground\ beef ground\ turkey
    ]
    
    seafood = %w[
      fish salmon tuna shrimp crab lobster
    ]
    
    pantry = %w[
      flour sugar salt pepper oil olive\ oil vegetable\ oil
      rice pasta bread
    ]
    
    spices = %w[
      oregano basil thyme rosemary cumin paprika cinnamon
      nutmeg ginger turmeric bay\ leaf
    ]
    
    return 'produce' if produce.any? { |item| normalized_name.include?(item) }
    return 'dairy' if dairy.any? { |item| normalized_name.include?(item) }
    return 'meat' if meat.any? { |item| normalized_name.include?(item) }
    return 'seafood' if seafood.any? { |item| normalized_name.include?(item) }
    return 'pantry' if pantry.any? { |item| normalized_name.include?(item) }
    return 'spices' if spices.any? { |item| normalized_name.include?(item) }
    
    'other'
  end
end
