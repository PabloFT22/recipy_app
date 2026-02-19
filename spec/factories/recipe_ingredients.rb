FactoryBot.define do
  factory :recipe_ingredient do
    recipe { nil }
    ingredient { nil }
    quantity { "9.99" }
    unit { "MyString" }
    notes { "MyString" }
  end
end
