FactoryBot.define do
  factory :recipe do
    association :user
    title { Faker::Food.dish }
    description { Faker::Food.description }
    servings { Faker::Number.between(from: 1, to: 12) }
    prep_time { Faker::Number.between(from: 5, to: 60) }
    cook_time { Faker::Number.between(from: 10, to: 120) }
    instructions { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    source_url { nil }
    difficulty { %w[easy medium hard].sample }
    is_public { true }

    trait :private do
      is_public { false }
    end

    trait :public do
      is_public { true }
    end

    trait :easy do
      difficulty { 'easy' }
    end

    trait :medium do
      difficulty { 'medium' }
    end

    trait :hard do
      difficulty { 'hard' }
    end
  end
end
