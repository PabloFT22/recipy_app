class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe

  def create
    unless @recipe.liked_by?(current_user)
      current_user.likes.create!(recipe: @recipe)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @recipe }
    end
  end

  def destroy
    like = current_user.likes.find_by(recipe: @recipe)
    like&.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @recipe }
    end
  end

  private

  def set_recipe
    @recipe = Recipe.friendly.find(params[:recipe_id])
  end
end
