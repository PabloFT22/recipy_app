FactoryBot.define do
  factory :grocery_list_item do
    association :grocery_list
    association :ingredient
    quantity { 1.0 }
    unit { "cup" }
    checked { false }
    on_hand { false }
  end
end
