class UserMailer < ApplicationMailer
  def meal_plan_reminder(user, meal_plan)
    @user = user
    @meal_plan = meal_plan
    @today_recipes = meal_plan.meal_plan_recipes
                               .includes(:recipe)
                               .where(scheduled_for: Date.current)
    mail(to: user.email, subject: "Today's Meal Plan: #{meal_plan.name}")
  end

  def weekly_digest(user, recipes)
    @user = user
    @recipes = recipes
    mail(to: user.email, subject: "Your Weekly Recipe Digest from Recipy")
  end

  def grocery_list_share(user, grocery_list, recipient_email)
    @user = user
    @grocery_list = grocery_list
    @items_by_category = grocery_list.items_by_category
    mail(to: recipient_email, subject: "#{user.display_name} shared a grocery list with you")
  end
end
