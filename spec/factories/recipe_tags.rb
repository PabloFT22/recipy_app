FactoryBot.define do
  factory :recipe_tag do
    association :recipe
    association :tag
  end
end
