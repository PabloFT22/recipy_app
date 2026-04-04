FactoryBot.define do
  factory :recipe_ingredient do
    association :recipe
    association :ingredient
    quantity { 1.0 }
    unit { "cup" }
    notes { nil }
  end
end
