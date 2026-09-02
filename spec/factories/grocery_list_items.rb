FactoryBot.define do
  factory :grocery_list_item do
    association :grocery_list
    association :ingredient
    quantity { Faker::Number.decimal(l_digits: 1, r_digits: 1).to_f }
    unit { 'cup' }
    checked { false }
    on_hand { false }
  end
end
