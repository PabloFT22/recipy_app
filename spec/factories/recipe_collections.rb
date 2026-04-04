FactoryBot.define do
  factory :recipe_collection do
    association :user
    sequence(:name) { |n| "Collection #{n}" }
    description { "A recipe collection" }
  end
end
