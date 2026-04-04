FactoryBot.define do
  factory :grocery_list do
    association :user
    sequence(:name) { |n| "Grocery List #{n}" }
    status { "active" }
  end
end
