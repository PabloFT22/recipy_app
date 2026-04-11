require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:recipe_ingredients).dependent(:destroy) }
    it { is_expected.to have_many(:recipes).through(:recipe_ingredients) }
    it { is_expected.to have_many(:grocery_list_items).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:normalized_name) }

    it 'requires unique normalized_name' do
      create(:ingredient, normalized_name: 'garlic')
      ingredient = build(:ingredient, name: 'Garlic', normalized_name: 'garlic')
      expect(ingredient).not_to be_valid
    end

    it 'validates category inclusion' do
      ingredient = build(:ingredient, category: 'invalid_category')
      expect(ingredient).not_to be_valid
    end

    it 'allows nil category' do
      ingredient = build(:ingredient, category: nil)
      expect(ingredient).to be_valid
    end

    it 'allows valid categories' do
      Ingredient::CATEGORIES.each do |cat|
        ingredient = build(:ingredient, category: cat)
        expect(ingredient).to be_valid
      end
    end
  end

  describe 'callbacks' do
    describe '#normalize_name' do
      it 'sets normalized_name from name' do
        ingredient = create(:ingredient, name: 'Chicken Breast')
        expect(ingredient.normalized_name).to eq('chicken breast')
      end

      it 'strips whitespace' do
        ingredient = create(:ingredient, name: '  onion  ')
        expect(ingredient.normalized_name).to eq('onion')
      end

      it 'downcases the name' do
        ingredient = create(:ingredient, name: 'TOMATO')
        expect(ingredient.normalized_name).to eq('tomato')
      end
    end
  end

  describe 'scopes' do
    describe '.by_category' do
      it 'filters by category' do
        produce = create(:ingredient, category: 'produce')
        dairy = create(:ingredient, category: 'dairy')
        expect(Ingredient.by_category('produce')).to include(produce)
        expect(Ingredient.by_category('produce')).not_to include(dairy)
      end
    end
  end
end
