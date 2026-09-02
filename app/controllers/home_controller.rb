class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    if user_signed_in?
      @recent_recipes = current_user.recipes.recent.limit(6)
      @active_meal_plan = current_user.meal_plans.active.first
      @active_grocery_lists = current_user.grocery_lists.active.limit(3)
      @expiring_soon_items = current_user.pantry_items.expiring_soon.includes(:ingredient)
    end
  end
end
