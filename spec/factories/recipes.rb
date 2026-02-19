FactoryBot.define do
  factory :recipe do
    user { nil }
    title { "MyString" }
    description { "MyText" }
    servings { 1 }
    prep_time { 1 }
    cook_time { 1 }
    instructions { "MyText" }
    source_url { "MyString" }
    difficulty { "MyString" }
    slug { "MyString" }
    is_public { false }
  end
end
