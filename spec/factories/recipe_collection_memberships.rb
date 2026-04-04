FactoryBot.define do
  factory :recipe_collection_membership do
    association :recipe
    association :recipe_collection
  end
end
