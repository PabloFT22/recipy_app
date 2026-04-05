FactoryBot.define do
  factory :pantry_item do
    association :user
    association :ingredient
  end
end
