FactoryBot.define do
  factory :ingredient do
    sequence(:name) { |n| "Ingredient #{n}" }
    sequence(:normalized_name) { |n| "ingredient #{n}" }
    category { "pantry" }
  end
end
