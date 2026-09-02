require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:recipes).dependent(:destroy) }
    it { is_expected.to have_many(:grocery_lists).dependent(:destroy) }
    it { is_expected.to have_many(:recipe_collections).dependent(:destroy) }
    it { is_expected.to have_many(:meal_plans).dependent(:destroy) }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:pantry_items).dependent(:destroy) }
  end

  describe 'validations' do
    it 'requires email presence' do
      user = build(:user, email: '')
      expect(user).not_to be_valid
    end

    it 'requires unique email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
    end

    it 'requires password' do
      user = build(:user, password: nil, password_confirmation: nil)
      expect(user).not_to be_valid
    end

    it 'allows nil username' do
      user = build(:user, username: nil)
      expect(user).to be_valid
    end

    it 'requires unique username when set' do
      create(:user, username: 'uniqueuser')
      user = build(:user, username: 'uniqueuser')
      expect(user).not_to be_valid
    end
  end

  describe 'social methods' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    describe '#following?' do
      it 'returns false when not following' do
        expect(user.following?(other_user)).to be false
      end

      it 'returns true after following' do
        Follow.create!(follower: user, following: other_user)
        expect(user.following?(other_user)).to be true
      end
    end
  end
end
