require 'rails_helper'

RSpec.describe Review, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:recipe) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:rating) }

    it 'validates rating inclusion 1..5' do
      [1, 2, 3, 4, 5].each do |r|
        review = build(:review, rating: r)
        expect(review).to be_valid
      end
    end

    it 'rejects rating 0' do
      review = build(:review, rating: 0)
      expect(review).not_to be_valid
    end

    it 'rejects rating 6' do
      review = build(:review, rating: 6)
      expect(review).not_to be_valid
    end

    it 'enforces unique review per user per recipe' do
      recipe = create(:recipe)
      user = create(:user)
      create(:review, user: user, recipe: recipe, rating: 4)
      duplicate = build(:review, user: user, recipe: recipe, rating: 5)
      expect(duplicate).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'updates recipe average_rating after save' do
      recipe = create(:recipe)
      create(:review, recipe: recipe, rating: 4)
      create(:review, recipe: recipe, rating: 2)
      expect(recipe.reload.average_rating.to_f).to eq(3.0)
    end

    it 'updates recipe reviews_count after save' do
      recipe = create(:recipe)
      create(:review, recipe: recipe)
      expect(recipe.reload.reviews_count).to eq(1)
    end

    it 'updates recipe rating after destroy' do
      recipe = create(:recipe)
      review = create(:review, recipe: recipe, rating: 5)
      review.destroy
      expect(recipe.reload.reviews_count).to eq(0)
    end
  end
end
