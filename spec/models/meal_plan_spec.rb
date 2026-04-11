require 'rails_helper'

RSpec.describe MealPlan, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:meal_plan_recipes).dependent(:destroy) }
    it { is_expected.to have_many(:recipes).through(:meal_plan_recipes) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }

    it 'is invalid when end_date is before start_date' do
      plan = build(:meal_plan, start_date: Date.current, end_date: Date.current - 1.day)
      expect(plan).not_to be_valid
      expect(plan.errors[:end_date]).to include('must be after start date')
    end

    it 'is valid when end_date equals start_date' do
      plan = build(:meal_plan, start_date: Date.current, end_date: Date.current)
      expect(plan).to be_valid
    end
  end

  describe 'scopes' do
    let!(:active_plan) { create(:meal_plan, start_date: Date.current - 1, end_date: Date.current + 5) }
    let!(:upcoming_plan) { create(:meal_plan, start_date: Date.current + 2, end_date: Date.current + 8) }
    let!(:past_plan) { create(:meal_plan, start_date: Date.current - 10, end_date: Date.current - 3) }

    describe '.active' do
      it 'returns plans spanning today' do
        expect(MealPlan.active).to include(active_plan)
        expect(MealPlan.active).not_to include(past_plan)
      end
    end

    describe '.upcoming' do
      it 'returns future plans' do
        expect(MealPlan.upcoming).to include(upcoming_plan)
        expect(MealPlan.upcoming).not_to include(past_plan)
      end
    end

    describe '.past' do
      it 'returns past plans' do
        expect(MealPlan.past).to include(past_plan)
        expect(MealPlan.past).not_to include(active_plan)
      end
    end
  end

  describe '#clone_to' do
    it 'creates a new meal plan with offset dates' do
      plan = create(:meal_plan, start_date: Date.current, end_date: Date.current + 6)
      new_start = Date.current + 7
      new_plan = plan.clone_to(new_start)
      expect(new_plan).to be_persisted
      expect(new_plan.start_date).to eq(new_start)
      expect(new_plan.end_date).to eq(new_start + 6)
    end
  end
end
