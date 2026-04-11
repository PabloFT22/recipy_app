FactoryBot.define do
  factory :recipe_ingredient do
    association :recipe
    association :ingredient
    quantity { Faker::Number.decimal(l_digits: 1, r_digits: 2).to_f }
    unit { RecipeIngredient::UNITS.sample }
    notes { nil }
  end
end
