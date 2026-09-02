require 'rails_helper'

RSpec.describe GroceryListItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:grocery_list) }
    it { is_expected.to belong_to(:ingredient) }
  end

  describe 'validations' do
    it 'allows nil quantity' do
      item = build(:grocery_list_item, quantity: nil)
      expect(item).to be_valid
    end

    it 'validates quantity numericality' do
      item = build(:grocery_list_item, quantity: -1)
      expect(item).not_to be_valid
    end
  end

  describe '#toggle_checked!' do
    it 'toggles checked status' do
      item = create(:grocery_list_item, checked: false)
      item.toggle_checked!
      expect(item.reload.checked).to be true
    end
  end

  describe '#toggle_on_hand!' do
    it 'toggles on_hand status' do
      item = create(:grocery_list_item, on_hand: false)
      item.toggle_on_hand!
      expect(item.reload.on_hand).to be true
    end
  end
end
