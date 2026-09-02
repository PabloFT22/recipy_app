FactoryBot.define do
  factory :ingredient do
    name { Faker::Food.ingredient }
    normalized_name { name.downcase.strip }
    category { Ingredient::CATEGORIES.sample }
  end
end
