require 'rails_helper'

RSpec.describe MealPlanRecipe, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:meal_plan) }
    it { is_expected.to belong_to(:recipe) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:scheduled_for) }

    it 'validates meal_type inclusion' do
      mpr = build(:meal_plan_recipe, meal_type: 'invalid')
      expect(mpr).not_to be_valid
    end

    it 'allows valid meal types' do
      %w[breakfast lunch dinner snack].each do |type|
        mpr = build(:meal_plan_recipe, meal_type: type)
        expect(mpr).to be_valid
      end
    end

    it 'validates servings greater than 0' do
      mpr = build(:meal_plan_recipe, servings: 0)
      expect(mpr).not_to be_valid
    end
  end
end
