class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe
  before_action :set_review, only: [:edit, :update, :destroy]
  before_action :authorize_review, only: [:edit, :update, :destroy]

  def create
    @review = @recipe.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to @recipe, notice: 'Review submitted successfully.'
    else
      redirect_to @recipe, alert: @review.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to @recipe, notice: 'Review updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    redirect_to @recipe, notice: 'Review deleted.'
  end

  private

  def set_recipe
    @recipe = Recipe.friendly.find(params[:recipe_id])
  end

  def set_review
    @review = @recipe.reviews.find(params[:id])
  end

  def authorize_review
    unless @review.user == current_user
      redirect_to @recipe, alert: 'Not authorized.'
    end
  end

  def review_params
    params.require(:review).permit(:rating, :body)
  end
end
