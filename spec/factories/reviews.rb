FactoryBot.define do
  factory :review do
    association :user
    association :recipe
    rating { rand(1..5) }
    body { Faker::Lorem.sentence }
  end
end
