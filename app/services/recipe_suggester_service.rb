class RecipeSuggesterService
  def initialize(user)
    @user = user
  end

  def suggest(limit: 5)
    pantry_ingredient_ids = @user.pantry_items.pluck(:ingredient_id)
    return [] if pantry_ingredient_ids.empty?

    accessible_recipes = Recipe.where(is_public: true).or(Recipe.where(user: @user))
                               .includes(:recipe_ingredients)

    results = accessible_recipes.map do |recipe|
      recipe_ingredient_ids = recipe.recipe_ingredients.map(&:ingredient_id)
      next if recipe_ingredient_ids.empty?

      match_count = (recipe_ingredient_ids & pantry_ingredient_ids).size
      total = recipe_ingredient_ids.size
      percentage = (match_count.to_f / total * 100).round

      { recipe: recipe, match_count: match_count, total_ingredients: total, match_percentage: percentage }
    end.compact

    results.sort_by { |r| -r[:match_percentage] }.first(limit)
  end
end
