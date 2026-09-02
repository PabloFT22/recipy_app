class NutritionFetchJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find_by(id: recipe_id)
    return unless recipe

    service = NutritionFetchService.new(recipe)
    data = service.fetch
    return unless data

    nutrition = recipe.nutrition_info || recipe.build_nutrition_info
    nutrition.update!(
      calories: data[:calories],
      protein_g: data[:protein_g],
      carbs_g: data[:carbs_g],
      fat_g: data[:fat_g],
      fiber_g: data[:fiber_g],
      sugar_g: data[:sugar_g],
      sodium_mg: data[:sodium_mg],
      per_servings: recipe.servings,
      fetched_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error "NutritionFetchJob failed for recipe #{recipe_id}: #{e.message}"
  end
end
