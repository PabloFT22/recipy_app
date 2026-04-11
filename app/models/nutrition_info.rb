class NutritionInfo < ApplicationRecord
  belongs_to :recipe

  def per_serving(servings_count = nil)
    servings_count ||= recipe.servings
    return self unless servings_count && servings_count > 0 && recipe.servings && recipe.servings > 0

    ratio = recipe.servings.to_f / servings_count
    OpenStruct.new(
      calories: (calories.to_f / ratio).round(2),
      protein_g: (protein_g.to_f / ratio).round(2),
      carbs_g: (carbs_g.to_f / ratio).round(2),
      fat_g: (fat_g.to_f / ratio).round(2),
      fiber_g: (fiber_g.to_f / ratio).round(2),
      sugar_g: (sugar_g.to_f / ratio).round(2),
      sodium_mg: (sodium_mg.to_f / ratio).round(2)
    )
  end
end
