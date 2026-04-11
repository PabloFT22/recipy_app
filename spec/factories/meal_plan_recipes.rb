FactoryBot.define do
  factory :meal_plan_recipe do
    association :meal_plan
    association :recipe
    scheduled_for { Date.current }
    meal_type { %w[breakfast lunch dinner snack].sample }
    servings { Faker::Number.between(from: 1, to: 8) }
  end
end
