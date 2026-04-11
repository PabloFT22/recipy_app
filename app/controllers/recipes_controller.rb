class RecipesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :cook]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :duplicate, :add_to_collection, :cook]
  before_action :authorize_recipe, only: [:edit, :update, :destroy]

  def index
    if user_signed_in?
      @recipes = current_user.recipes.recent
    else
      @recipes = Recipe.public_recipes.recent
    end

    if params[:search].present?
      @recipes = @recipes.search(params[:search])
    end

    if params[:difficulty].present?
      @recipes = @recipes.by_difficulty(params[:difficulty])
    end

    if params[:cuisine_type].present?
      @recipes = @recipes.by_cuisine(params[:cuisine_type])
    end

    if params[:dietary_tag].present?
      @recipes = @recipes.by_dietary_tag(params[:dietary_tag])
    end

    if params[:max_time].present?
      @recipes = @recipes.by_max_time(params[:max_time].to_i)
    end

    case params[:sort]
    when 'rating'
      @recipes = @recipes.by_rating
    when 'recent'
      @recipes = @recipes.recent
    end

    @recipes = @recipes.page(params[:page])
  end

  def show
    unless @recipe.is_public || (user_signed_in? && @recipe.user == current_user)
      redirect_to recipes_path, alert: "Recipe not found or is private"
      return
    end
    @user_review = current_user.reviews.find_by(recipe: @recipe) if user_signed_in?
    @reviews = @recipe.reviews.includes(:user).order(created_at: :desc)
  end

  def new
    @recipe = current_user.recipes.build
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)

    if @recipe.save
      if params[:recipe][:ingredients_text].present?
        parse_and_add_ingredients(params[:recipe][:ingredients_text])
        @recipe.ingredients_changed = true
      end

      redirect_to @recipe, notice: 'Recipe was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @recipe.update(recipe_params)
      if params[:recipe][:ingredients_text].present?
        @recipe.recipe_ingredients.destroy_all
        parse_and_add_ingredients(params[:recipe][:ingredients_text])
        @recipe.ingredients_changed = true
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

  def cook
    unless @recipe.is_public || (user_signed_in? && @recipe.user == current_user)
      redirect_to recipes_path, alert: "Recipe not found or is private"
      return
    end
    @steps = @recipe.parse_instructions_into_steps
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
      :image,
      :cuisine_type,
      :dietary_tags
    )
  end

  def parse_and_add_ingredients(ingredients_text)
    parser = RecipeParserService.new(ingredients_text)
    parsed_ingredients = parser.parse

    parsed_ingredients.each do |ingredient_data|
      finder = IngredientFinderService.new(ingredient_data[:ingredient_name])
      ingredient = finder.find_or_create

      @recipe.recipe_ingredients.create(
        ingredient: ingredient,
        quantity: ingredient_data[:quantity],
        unit: ingredient_data[:unit],
        notes: ingredient_data[:notes]
      )
    end
  end
end
