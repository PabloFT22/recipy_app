FactoryBot.define do
  factory :meal_plan_recipe do
    meal_plan { nil }
    recipe { nil }
    scheduled_for { "2026-02-18" }
    meal_type { "MyString" }
    servings { 1 }
  end
end
