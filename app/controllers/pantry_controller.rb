class PantryController < ApplicationController
  before_action :authenticate_user!

  def show
    # Seed defaults on first visit if user has no pantry items
    PantryItem.seed_defaults_for(current_user) unless current_user.pantry_items.exists?

    @pantry_items = current_user.pantry_items
      .includes(:ingredient)
      .joins(:ingredient)
      .order('ingredients.category ASC, ingredients.name ASC')

    @items_by_category = @pantry_items.group_by { |pi| pi.ingredient.category || 'other' }
  end

  def add_item
    name = params[:ingredient_name]&.strip
    if name.blank?
      redirect_to pantry_path, alert: 'Please enter an ingredient name.'
      return
    end

    finder = IngredientFinderService.new(name)
    ingredient = finder.find_or_create

    if current_user.pantry_items.exists?(ingredient: ingredient)
      redirect_to pantry_path, notice: "#{ingredient.name} is already in your pantry."
    else
      current_user.pantry_items.create!(ingredient: ingredient)
      redirect_to pantry_path, notice: "#{ingredient.name} added to pantry."
    end
  end

  def remove_item
    pantry_item = current_user.pantry_items.find_by(ingredient_id: params[:ingredient_id])
    if pantry_item
      name = pantry_item.ingredient.name
      pantry_item.destroy
      redirect_to pantry_path, notice: "#{name} removed from pantry."
    else
      redirect_to pantry_path, alert: 'Item not found in pantry.'
    end
  end

  def seed_defaults
    # Reset and re-seed defaults
    current_user.pantry_items.destroy_all
    PantryItem.seed_defaults_for(current_user)
    # Re-seed won't work because seed_defaults_for checks exists?, so we call it differently
    PantryItem::DEFAULT_STAPLES.each do |name|
      normalized = name.downcase.strip
      ingredient = Ingredient.find_or_create_by(normalized_name: normalized) do |ing|
        ing.name = name
        ing.category = PantryItem.send(:guess_category, normalized)
      end
      current_user.pantry_items.find_or_create_by(ingredient: ingredient)
    end
    redirect_to pantry_path, notice: 'Pantry reset to default staples.'
  end
end
