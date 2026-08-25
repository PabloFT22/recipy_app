class MealPlanRecipesController < ApplicationController
  before_action :set_meal_plan
  before_action :set_meal_plan_recipe, only: [:update, :destroy]
  
  def create
    @meal_plan_recipe = @meal_plan.meal_plan_recipes.build(meal_plan_recipe_params)

    # recipe_id arrives from the client, so it must be re-checked here: without
    # this a user could schedule (and then read) another user's private recipe.
    unless authorized_recipe?(@meal_plan_recipe.recipe)
      redirect_to @meal_plan, alert: "Recipe not found or is private."
      return
    end

    if @meal_plan_recipe.save
      respond_to do |format|
        format.turbo_stream { redirect_to @meal_plan, notice: 'Recipe added to meal plan.' }
        format.html { redirect_to @meal_plan, notice: 'Recipe added to meal plan.' }
      end
    else
      redirect_to @meal_plan, alert: "Failed to add recipe: #{@meal_plan_recipe.errors.full_messages.join(', ')}"
    end
  end
  
  def update
    if meal_plan_recipe_params[:recipe_id].present? &&
       !authorized_recipe?(Recipe.find_by(id: meal_plan_recipe_params[:recipe_id]))
      redirect_to @meal_plan, alert: "Recipe not found or is private."
      return
    end

    if @meal_plan_recipe.update(meal_plan_recipe_params)
      redirect_to @meal_plan, notice: 'Meal plan recipe updated.'
    else
      redirect_to @meal_plan, alert: 'Failed to update recipe.'
    end
  end
  
  def destroy
    @meal_plan_recipe.destroy
    redirect_to @meal_plan, notice: 'Recipe removed from meal plan.'
  end
  
  private
  
  def set_meal_plan
    @meal_plan = current_user.meal_plans.find(params[:meal_plan_id])
  end
  
  def set_meal_plan_recipe
    @meal_plan_recipe = @meal_plan.meal_plan_recipes.find(params[:id])
  end
  
  # You may schedule your own recipes and public ones — nothing else.
  def authorized_recipe?(recipe)
    recipe.present? && (recipe.user_id == current_user.id || recipe.is_public)
  end

  def meal_plan_recipe_params
    params.require(:meal_plan_recipe).permit(:recipe_id, :scheduled_for, :meal_type, :servings)
  end
end
