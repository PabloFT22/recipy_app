class RecipeCollectionsController < ApplicationController
  before_action :set_collection, only: [:show, :edit, :update, :destroy, :add_recipe, :remove_recipe]
  
  def index
    @collections = current_user.recipe_collections.recent.page(params[:page])
  end
  
  def show
    @recipes = @collection.recipes.page(params[:page])
  end
  
  def new
    @collection = current_user.recipe_collections.build
  end
  
  def create
    @collection = current_user.recipe_collections.build(collection_params)
    
    if @collection.save
      redirect_to @collection, notice: 'Collection was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @collection.update(collection_params)
      redirect_to @collection, notice: 'Collection was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @collection.destroy
    redirect_to recipe_collections_url, notice: 'Collection was successfully deleted.'
  end
  
  def add_recipe
    recipe = Recipe.friendly.find(params[:recipe_id])

    unless recipe.user == current_user || recipe.is_public
      redirect_to @collection, alert: "Recipe not found or is private"
      return
    end

    @collection.add_recipe(recipe)
    
    redirect_to @collection, notice: 'Recipe added to collection.'
  end
  
  def remove_recipe
    recipe = Recipe.friendly.find(params[:recipe_id])
    @collection.remove_recipe(recipe)
    
    redirect_to @collection, notice: 'Recipe removed from collection.'
  end
  
  private
  
  def set_collection
    @collection = current_user.recipe_collections.find(params[:id])
  end
  
  def collection_params
    params.require(:recipe_collection).permit(:name, :description)
  end
end
