FactoryBot.define do
  factory :meal_plan do
    association :user
    name { "#{Faker::Date.forward(days: 7).strftime('%B')} Meal Plan" }
    start_date { Date.current.beginning_of_week }
    end_date { Date.current.end_of_week }
    is_template { false }

    trait :template do
      is_template { true }
    end
  end
end
