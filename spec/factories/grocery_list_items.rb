FactoryBot.define do
  factory :grocery_list_item do
    grocery_list { nil }
    ingredient { nil }
    quantity { "9.99" }
    unit { "MyString" }
    checked { false }
    on_hand { false }
  end
end
