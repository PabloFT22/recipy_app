require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:recipe_ingredients).dependent(:destroy) }
    it { is_expected.to have_many(:ingredients).through(:recipe_ingredients) }
    it { is_expected.to have_many(:recipe_collection_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:recipe_collections).through(:recipe_collection_memberships) }
    it { is_expected.to have_many(:meal_plan_recipes).dependent(:destroy) }
    it { is_expected.to have_many(:meal_plans).through(:meal_plan_recipes) }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_one(:nutrition_info).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }

    it 'validates servings numericality greater than 0' do
      recipe = build(:recipe, servings: 0)
      expect(recipe).not_to be_valid
    end

    it 'allows nil servings' do
      recipe = build(:recipe, servings: nil)
      expect(recipe).to be_valid
    end

    it 'validates difficulty inclusion' do
      recipe = build(:recipe, difficulty: 'extreme')
      expect(recipe).not_to be_valid
    end

    it 'allows valid difficulty values' do
      %w[easy medium hard].each do |diff|
        recipe = build(:recipe, difficulty: diff)
        expect(recipe).to be_valid
      end
    end

    it 'allows nil difficulty' do
      recipe = build(:recipe, difficulty: nil)
      expect(recipe).to be_valid
    end

    it 'validates prep_time is >= 0' do
      recipe = build(:recipe, prep_time: -1)
      expect(recipe).not_to be_valid
    end

    it 'validates cook_time is >= 0' do
      recipe = build(:recipe, cook_time: -1)
      expect(recipe).not_to be_valid
    end
  end

  describe 'scopes' do
    let!(:public_recipe) { create(:recipe, :public) }
    let!(:private_recipe) { create(:recipe, :private) }
    let!(:easy_recipe) { create(:recipe, difficulty: 'easy') }
    let!(:hard_recipe) { create(:recipe, difficulty: 'hard') }

    describe '.public_recipes' do
      it 'returns only public recipes' do
        expect(Recipe.public_recipes).to include(public_recipe)
        expect(Recipe.public_recipes).not_to include(private_recipe)
      end
    end

    describe '.private_recipes' do
      it 'returns only private recipes' do
        expect(Recipe.private_recipes).to include(private_recipe)
        expect(Recipe.private_recipes).not_to include(public_recipe)
      end
    end

    describe '.by_difficulty' do
      it 'filters by difficulty' do
        expect(Recipe.by_difficulty('easy')).to include(easy_recipe)
        expect(Recipe.by_difficulty('easy')).not_to include(hard_recipe)
      end
    end

    describe '.recent' do
      it 'orders by created_at desc' do
        old_recipe = create(:recipe, created_at: 1.week.ago)
        new_recipe = create(:recipe, created_at: Time.current)
        expect(Recipe.recent.first).to eq(new_recipe)
      end
    end

    describe '.search' do
      it 'returns recipes matching title' do
        recipe = create(:recipe, title: 'Unique Pasta Carbonara Test')
        expect(Recipe.search('Carbonara')).to include(recipe)
      end
    end
  end

  describe '#total_time' do
    it 'returns sum of prep and cook times' do
      recipe = build(:recipe, prep_time: 15, cook_time: 30)
      expect(recipe.total_time).to eq(45)
    end

    it 'returns nil if prep_time is nil' do
      recipe = build(:recipe, prep_time: nil, cook_time: 30)
      expect(recipe.total_time).to be_nil
    end

    it 'returns nil if cook_time is nil' do
      recipe = build(:recipe, prep_time: 15, cook_time: nil)
      expect(recipe.total_time).to be_nil
    end
  end

  describe '#scale_servings' do
    let(:recipe) { create(:recipe, servings: 4) }
    let(:ingredient) { create(:ingredient) }

    before do
      create(:recipe_ingredient, recipe: recipe, ingredient: ingredient, quantity: 2.0, unit: 'cup')
    end

    it 'scales ingredient quantities' do
      scaled = recipe.scale_servings(8)
      expect(scaled.first[:quantity]).to eq(4.0)
    end
  end
end
