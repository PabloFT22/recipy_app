class RecipesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :duplicate, :add_to_collection]
  before_action :authorize_recipe, only: [:edit, :update, :destroy]
  
  def index
    if user_signed_in?
      @recipes = current_user.recipes.recent.page(params[:page])
    else
      @recipes = Recipe.public_recipes.recent.page(params[:page])
    end
    
    if params[:search].present?
      @recipes = @recipes.search(params[:search])
    end
    
    if params[:difficulty].present?
      @recipes = @recipes.by_difficulty(params[:difficulty])
    end
  end
  
  def show
    unless @recipe.is_public || (user_signed_in? && @recipe.user == current_user)
      redirect_to recipes_path, alert: "Recipe not found or is private"
    end
  end
  
  def new
    @recipe = current_user.recipes.build
  end
  
  def create
    ingredients_rows = params[:recipe].delete(:ingredients_rows)
    @recipe = current_user.recipes.build(recipe_params)
    
    if @recipe.save
      save_structured_ingredients(ingredients_rows) if ingredients_rows.present?
      redirect_to @recipe, notice: 'Recipe was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    ingredients_rows = params[:recipe].delete(:ingredients_rows)
    
    if @recipe.update(recipe_params)
      if ingredients_rows.present?
        @recipe.recipe_ingredients.destroy_all
        save_structured_ingredients(ingredients_rows)
      end
      
      redirect_to @recipe, notice: 'Recipe was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @recipe.destroy
    redirect_to recipes_url, notice: 'Recipe was successfully deleted.'
  end
  
  def import
  end
  
  def import_from_url
    url = params[:url]
    scraper = RecipeScraperService.new(url)
    recipe_data = scraper.scrape
    
    if recipe_data
      @recipe = current_user.recipes.build(
        title: recipe_data[:title],
        description: recipe_data[:description],
        prep_time: recipe_data[:prep_time],
        cook_time: recipe_data[:cook_time],
        servings: recipe_data[:servings],
        instructions: recipe_data[:instructions],
        source_url: url
      )
      
      if recipe_data[:ingredients].present?
        ingredients_text = recipe_data[:ingredients].join("\n")
        parse_and_add_ingredients(ingredients_text)
      end
      
      if @recipe.save
        redirect_to @recipe, notice: 'Recipe imported successfully!'
      else
        render :import, alert: 'Failed to import recipe'
      end
    else
      redirect_to import_recipes_path, alert: "Failed to scrape recipe: #{scraper.errors.join(', ')}"
    end
  end
  
  def duplicate
    new_recipe = @recipe.dup
    new_recipe.title = "#{@recipe.title} (Copy)"
    new_recipe.user = current_user
    new_recipe.slug = nil
    
    if new_recipe.save
      @recipe.recipe_ingredients.each do |ri|
        new_recipe.recipe_ingredients.create(
          ingredient: ri.ingredient,
          quantity: ri.quantity,
          unit: ri.unit,
          notes: ri.notes
        )
      end
      
      redirect_to new_recipe, notice: 'Recipe duplicated successfully.'
    else
      redirect_to @recipe, alert: 'Failed to duplicate recipe.'
    end
  end
  
  def add_to_collection
    collection = current_user.recipe_collections.find(params[:collection_id])
    collection.add_recipe(@recipe)
    
    redirect_to @recipe, notice: 'Recipe added to collection.'
  end
  
  private
  
  def set_recipe
    @recipe = Recipe.friendly.find(params[:id])
  end
  
  def authorize_recipe
    unless @recipe.user == current_user
      redirect_to recipes_path, alert: "You are not authorized to modify this recipe"
    end
  end
  
  def recipe_params
    params.require(:recipe).permit(
      :title,
      :description,
      :servings,
      :prep_time,
      :cook_time,
      :instructions,
      :source_url,
      :difficulty,
      :is_public,
      :image
    )
  end
  
  def save_structured_ingredients(rows)
    rows.each do |row|
      next if row[:name].blank?
      
      finder = IngredientFinderService.new(row[:name].strip)
      ingredient = finder.find_or_create
      
      unit = row[:unit].presence
      notes = row[:notes].presence
      quantity = row[:quantity].present? ? row[:quantity].to_f : nil
      
      # Validate unit — if not recognized, move to notes
      if unit.present? && !RecipeIngredient::UNITS.include?(unit)
        notes = [unit, notes].compact.join(', ')
        unit = nil
      end
      
      @recipe.recipe_ingredients.create(
        ingredient: ingredient,
        quantity: quantity,
        unit: unit,
        notes: notes
      )
    end
  end
  
  def parse_and_add_ingredients(ingredients_text)
    parser = RecipeParserService.new(ingredients_text)
    parsed_ingredients = parser.parse
    
    parsed_ingredients.each do |ingredient_data|
      finder = IngredientFinderService.new(ingredient_data[:ingredient_name])
      ingredient = finder.find_or_create
      
      # If unit is not recognized, store it as nil and move the unit text to notes
      unit = ingredient_data[:unit]
      notes = ingredient_data[:notes]
      
      unless unit.blank? || RecipeIngredient::UNITS.include?(unit)
        notes = [unit, notes].compact.join(', ')
        unit = nil
      end

      @recipe.recipe_ingredients.create(
        ingredient: ingredient,
        quantity: ingredient_data[:quantity],
        unit: unit,
        notes: notes
      )
    end
  end
end
