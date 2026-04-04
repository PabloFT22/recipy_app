FactoryBot.define do
  factory :meal_plan do
    association :user
    sequence(:name) { |n| "Meal Plan #{n}" }
    start_date { Date.current }
    end_date { Date.current + 7.days }
  end
end
