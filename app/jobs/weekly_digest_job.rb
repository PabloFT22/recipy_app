class WeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      next if user.following.empty?

      new_recipes = Recipe.public_recipes
                          .where(user: user.following)
                          .where('created_at >= ?', 1.week.ago)
                          .recent
                          .limit(10)

      next if new_recipes.empty?

      UserMailer.weekly_digest(user, new_recipes).deliver_later
    end
  end
end
