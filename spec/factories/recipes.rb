FactoryBot.define do
  factory :recipe do
    association :user
    sequence(:title) { |n| "Recipe #{n}" }
    description { "A delicious test recipe" }
    servings { 4 }
    prep_time { 15 }
    cook_time { 30 }
    instructions { "Step 1: Prep.\n\nStep 2: Cook.\n\nStep 3: Serve." }
    source_url { nil }
    difficulty { "easy" }
    is_public { false }
  end
end
