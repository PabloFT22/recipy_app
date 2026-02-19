class GroceryListsController < ApplicationController
  before_action :set_grocery_list, only: [:show, :edit, :update, :destroy, :complete, :archive]
  
  def index
    @grocery_lists = current_user.grocery_lists.recent.page(params[:page])
    
    @grocery_lists = @grocery_lists.where(status: params[:status]) if params[:status].present?
  end
  
  def show
    @items_by_category = @grocery_list.items_by_category
  end
  
  def new
    @grocery_list = current_user.grocery_lists.build
  end
  
  def create
    @grocery_list = current_user.grocery_lists.build(grocery_list_params)
    
    if @grocery_list.save
      redirect_to @grocery_list, notice: 'Grocery list was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @grocery_list.update(grocery_list_params)
      redirect_to @grocery_list, notice: 'Grocery list was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @grocery_list.destroy
    redirect_to grocery_lists_url, notice: 'Grocery list was successfully deleted.'
  end
  
  def complete
    @grocery_list.complete!
    redirect_to @grocery_list, notice: 'Grocery list marked as completed.'
  end
  
  def archive
    @grocery_list.archive!
    redirect_to grocery_lists_path, notice: 'Grocery list archived.'
  end
  
  def generate_from_meal_plan
    meal_plan = current_user.meal_plans.find(params[:meal_plan_id])
    @grocery_list = meal_plan.generate_grocery_list
    
    redirect_to @grocery_list, notice: 'Grocery list generated from meal plan.'
  end
  
  private
  
  def set_grocery_list
    @grocery_list = current_user.grocery_lists.find(params[:id])
  end
  
  def grocery_list_params
    params.require(:grocery_list).permit(:name, :status)
  end
end
