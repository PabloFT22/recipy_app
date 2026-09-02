class DailyMealPlanReminderJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      active_plan = user.meal_plans.active.first
      next unless active_plan

      today_recipes = active_plan.meal_plan_recipes
                                 .includes(:recipe)
                                 .where(scheduled_for: Date.current)
      next if today_recipes.empty?

      UserMailer.meal_plan_reminder(user, active_plan).deliver_later
    end
  end
end
