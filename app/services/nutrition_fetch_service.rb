class NutritionFetchService
  USDA_API_URL = "https://api.nal.usda.gov/fdc/v1/foods/search".freeze

  NUTRIENT_IDS = {
    calories: 1008,
    protein_g: 1003,
    carbs_g: 1005,
    fat_g: 1004,
    fiber_g: 1079,
    sugar_g: 2000,
    sodium_mg: 1093
  }.freeze

  def initialize(recipe)
    @recipe = recipe
  end

  def fetch
    return nil unless ENV['USDA_API_KEY'].present?
    return nil if @recipe.recipe_ingredients.empty?

    totals = Hash.new(0.0)

    @recipe.recipe_ingredients.includes(:ingredient).each do |ri|
      data = search_ingredient(ri.ingredient.name)
      next unless data

      quantity_grams = estimate_grams(ri.quantity, ri.unit)
      next unless quantity_grams > 0

      nutrients = extract_nutrients(data)
      per_100g_factor = quantity_grams / 100.0

      NUTRIENT_IDS.each_key do |key|
        totals[key] += (nutrients[key] || 0) * per_100g_factor
      end
    end

    totals.transform_values { |v| v.round(2) }
  rescue StandardError => e
    Rails.logger.error "NutritionFetchService error: #{e.message}"
    nil
  end

  private

  def search_ingredient(name)
    response = HTTParty.get(USDA_API_URL, query: {
      query: name,
      api_key: ENV['USDA_API_KEY'],
      pageSize: 1,
      dataType: 'Foundation,SR Legacy'
    })

    return nil unless response.success?

    foods = response.parsed_response['foods']
    foods&.first
  end

  def extract_nutrients(food_data)
    nutrients = {}
    food_nutrients = food_data['foodNutrients'] || []

    NUTRIENT_IDS.each do |key, nutrient_id|
      nutrient = food_nutrients.find { |n| n['nutrientId'] == nutrient_id }
      nutrients[key] = nutrient&.dig('value') || 0
    end

    nutrients
  end

  def estimate_grams(quantity, unit)
    return 0 unless quantity&.positive?

    conversions = {
      'cup' => 240, 'cups' => 240,
      'tablespoon' => 15, 'tablespoons' => 15, 'tbsp' => 15,
      'teaspoon' => 5, 'teaspoons' => 5, 'tsp' => 5,
      'ounce' => 28, 'ounces' => 28, 'oz' => 28,
      'pound' => 454, 'pounds' => 454, 'lb' => 454,
      'gram' => 1, 'grams' => 1, 'g' => 1,
      'kilogram' => 1000, 'kilograms' => 1000, 'kg' => 1000,
      'milliliter' => 1, 'milliliters' => 1, 'ml' => 1,
      'liter' => 1000, 'liters' => 1000, 'l' => 1000,
      'piece' => 100, 'pieces' => 100, 'whole' => 100
    }

    grams_per_unit = conversions[unit&.downcase] || 100
    quantity * grams_per_unit
  end
end
