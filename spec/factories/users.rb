FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    name { Faker::Name.name }
    username { Faker::Internet.unique.username(specifier: 5..15) }
    bio { Faker::Lorem.sentence }
  end
end
