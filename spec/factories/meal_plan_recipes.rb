FactoryBot.define do
  factory :meal_plan_recipe do
    association :meal_plan
    association :recipe
    scheduled_for { Date.current }
    meal_type { "dinner" }
    servings { 4 }
  end
end
