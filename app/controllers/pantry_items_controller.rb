class PantryItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pantry_item, only: [:update, :destroy]

  def index
    @pantry_items = current_user.pantry_items.by_category.includes(:ingredient)
    @items_by_category = @pantry_items.group_by { |item| item.ingredient.category || 'other' }
    @expiring_soon = current_user.pantry_items.expiring_soon.includes(:ingredient)
  end

  def create
    ingredient = IngredientFinderService.new(params[:pantry_item][:ingredient_name]).find_or_create
    @pantry_item = current_user.pantry_items.build(pantry_item_params)
    @pantry_item.ingredient = ingredient

    if @pantry_item.save
      redirect_to pantry_items_path, notice: 'Item added to pantry.'
    else
      @pantry_items = current_user.pantry_items.by_category.includes(:ingredient)
      @items_by_category = @pantry_items.group_by { |i| i.ingredient.category || 'other' }
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @pantry_item.update(pantry_item_params)
      redirect_to pantry_items_path, notice: 'Pantry item updated.'
    else
      redirect_to pantry_items_path, alert: @pantry_item.errors.full_messages.to_sentence
    end
  end

  def destroy
    @pantry_item.destroy
    redirect_to pantry_items_path, notice: 'Item removed from pantry.'
  end

  def suggest
    @suggestions = RecipeSuggesterService.new(current_user).suggest
  end

  private

  def set_pantry_item
    @pantry_item = current_user.pantry_items.find(params[:id])
  end

  def pantry_item_params
    params.require(:pantry_item).permit(:quantity, :unit, :expiration_date, :notes)
  end
end
