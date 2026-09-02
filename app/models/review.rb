class Review < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :recipe_id, message: "can only review each recipe once" }

  after_save :update_recipe_rating
  after_destroy :update_recipe_rating

  private

  def update_recipe_rating
    avg = recipe.reviews.average(:rating)
    count = recipe.reviews.count
    recipe.update_columns(average_rating: avg, reviews_count: count)
  end
end
