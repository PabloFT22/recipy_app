class MealPlansController < ApplicationController
  before_action :set_meal_plan, only: [:show, :edit, :update, :destroy, :generate_grocery_list]
  
  def index
    @meal_plans = current_user.meal_plans.recent.page(params[:page])
    @active_meal_plan = current_user.meal_plans.active.first
  end
  
  def show
    @recipes_by_date = @meal_plan.recipes_by_date
  end
  
  def new
    @meal_plan = current_user.meal_plans.build(
      start_date: Date.current.beginning_of_week,
      end_date: Date.current.end_of_week
    )
  end
  
  def create
    @meal_plan = current_user.meal_plans.build(meal_plan_params)
    
    if @meal_plan.save
      redirect_to @meal_plan, notice: 'Meal plan was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @meal_plan.update(meal_plan_params)
      redirect_to @meal_plan, notice: 'Meal plan was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @meal_plan.destroy
    redirect_to meal_plans_url, notice: 'Meal plan was successfully deleted.'
  end
  
  def generate_grocery_list
    @grocery_list = @meal_plan.generate_grocery_list
    redirect_to @grocery_list, notice: 'Grocery list generated from meal plan!'
  end
  
  private
  
  def set_meal_plan
    @meal_plan = current_user.meal_plans.find(params[:id])
  end
  
  def meal_plan_params
    params.require(:meal_plan).permit(:name, :start_date, :end_date)
  end
end
