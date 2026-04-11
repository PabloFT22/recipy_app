FactoryBot.define do
  factory :recipe_collection do
    association :user
    name { Faker::Lorem.words(number: 3).map(&:capitalize).join(' ') }
    description { Faker::Lorem.sentence }
  end
end
