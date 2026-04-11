require 'rails_helper'

RSpec.describe GroceryList, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:grocery_list_items).dependent(:destroy) }
    it { is_expected.to have_many(:ingredients).through(:grocery_list_items) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it 'validates status inclusion' do
      list = build(:grocery_list, status: 'invalid')
      expect(list).not_to be_valid
    end

    it 'allows valid statuses' do
      %w[active completed archived].each do |status|
        list = build(:grocery_list, status: status)
        expect(list).to be_valid
      end
    end
  end

  describe '#complete!' do
    it 'changes status to completed' do
      list = create(:grocery_list, status: 'active')
      list.complete!
      expect(list.reload.status).to eq('completed')
    end
  end

  describe '#archive!' do
    it 'changes status to archived' do
      list = create(:grocery_list, status: 'active')
      list.archive!
      expect(list.reload.status).to eq('archived')
    end
  end

  describe '#add_or_update_ingredient' do
    let(:list) { create(:grocery_list) }
    let(:ingredient) { create(:ingredient) }

    it 'creates a new item' do
      expect { list.add_or_update_ingredient(ingredient, 2, 'cup') }.to change { list.grocery_list_items.count }.by(1)
    end

    it 'updates quantity for existing item' do
      list.add_or_update_ingredient(ingredient, 2, 'cup')
      list.add_or_update_ingredient(ingredient, 3, 'cup')
      expect(list.grocery_list_items.where(ingredient: ingredient).first.quantity).to eq(5)
    end
  end

  describe '#progress_percentage' do
    let(:list) { create(:grocery_list) }

    it 'returns 0 when no items' do
      expect(list.progress_percentage).to eq(0)
    end

    it 'returns correct percentage' do
      i1 = create(:ingredient)
      i2 = create(:ingredient)
      create(:grocery_list_item, grocery_list: list, ingredient: i1, checked: true)
      create(:grocery_list_item, grocery_list: list, ingredient: i2, checked: false)
      expect(list.progress_percentage).to eq(50)
    end
  end

  describe '#items_by_category' do
    it 'groups items by category' do
      list = create(:grocery_list)
      produce_ing = create(:ingredient, category: 'produce')
      dairy_ing = create(:ingredient, category: 'dairy')
      create(:grocery_list_item, grocery_list: list, ingredient: produce_ing)
      create(:grocery_list_item, grocery_list: list, ingredient: dairy_ing)
      grouped = list.items_by_category
      expect(grouped.map(&:first)).to include('produce', 'dairy')
    end
  end
end
