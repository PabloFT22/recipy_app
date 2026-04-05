class GroceryListItemsController < ApplicationController
  before_action :set_grocery_list
  before_action :set_grocery_list_item, only: [:update, :destroy, :toggle_checked, :toggle_on_hand]
  
  def create
    @item = @grocery_list.grocery_list_items.build(grocery_list_item_params)
    
    # Find or create ingredient
    if params[:grocery_list_item][:ingredient_name].present?
      finder = IngredientFinderService.new(params[:grocery_list_item][:ingredient_name])
      @item.ingredient = finder.find_or_create
    end
    
    if @item.save
      redirect_to @grocery_list, notice: 'Item added to grocery list.'
    else
      redirect_to @grocery_list, alert: 'Failed to add item.'
    end
  end
  
  def update
    if @item.update(grocery_list_item_params)
      redirect_to @grocery_list, notice: 'Item updated.'
    else
      redirect_to @grocery_list, alert: 'Failed to update item.'
    end
  end
  
  def destroy
    @item.destroy
    redirect_to @grocery_list, notice: 'Item removed from list.'
  end
  
  def toggle_checked
    @item.toggle_checked!
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace("grocery_item_#{@item.id}",
            partial: "grocery_list_items/item",
            locals: { item: @item, grocery_list: @grocery_list }),
          turbo_stream.replace("grocery_list_progress",
            partial: "grocery_lists/progress",
            locals: { grocery_list: @grocery_list.reload })
        ]
      }
      format.html { redirect_to @grocery_list }
    end
  end
  
  def toggle_on_hand
    @item.toggle_on_hand!
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace("grocery_item_#{@item.id}",
          partial: "grocery_list_items/item",
          locals: { item: @item, grocery_list: @grocery_list })
      }
      format.html { redirect_to @grocery_list }
    end
  end
  
  private
  
  def set_grocery_list
    @grocery_list = current_user.grocery_lists.find(params[:grocery_list_id])
  end
  
  def set_grocery_list_item
    @item = @grocery_list.grocery_list_items.find(params[:id])
  end
  
  def grocery_list_item_params
    params.require(:grocery_list_item).permit(:ingredient_id, :quantity, :unit, :checked, :on_hand)
  end
end
