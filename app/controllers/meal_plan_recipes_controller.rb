class MealPlanRecipesController < ApplicationController
  before_action :set_meal_plan
  before_action :set_meal_plan_recipe, only: [:update, :destroy]
  
  def create
    @meal_plan_recipe = @meal_plan.meal_plan_recipes.build(meal_plan_recipe_params)
    
    if @meal_plan_recipe.save
      redirect_to @meal_plan, notice: 'Recipe added to meal plan.'
    else
      redirect_to @meal_plan, alert: 'Failed to add recipe to meal plan.'
    end
  end
  
  def update
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
  
  def meal_plan_recipe_params
    params.require(:meal_plan_recipe).permit(:recipe_id, :scheduled_for, :meal_type, :servings)
  end
end
