FactoryBot.define do
  factory :grocery_list do
    association :user
    name { "#{Faker::Food.dish} Shopping List" }
    status { 'active' }

    trait :completed do
      status { 'completed' }
    end

    trait :archived do
      status { 'archived' }
    end
  end
end
