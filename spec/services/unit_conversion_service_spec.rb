require 'rails_helper'

RSpec.describe UnitConversionService do
  describe '.unit_family' do
    it 'identifies volume units' do
      expect(UnitConversionService.unit_family('cups')).to eq([:volume, 'cups'])
      expect(UnitConversionService.unit_family('teaspoons')).to eq([:volume, 'teaspoons'])
      expect(UnitConversionService.unit_family('tablespoons')).to eq([:volume, 'tablespoons'])
    end

    it 'identifies weight units' do
      expect(UnitConversionService.unit_family('ounces')).to eq([:weight_imperial, 'ounces'])
      expect(UnitConversionService.unit_family('pounds')).to eq([:weight_imperial, 'pounds'])
      expect(UnitConversionService.unit_family('grams')).to eq([:weight_metric, 'grams'])
    end

    it 'treats size qualifiers as count' do
      %w[large medium small whole pieces].each do |unit|
        expect(UnitConversionService.unit_family(unit)).to eq([:count, nil])
      end
    end

    it 'treats nil/blank as count' do
      expect(UnitConversionService.unit_family(nil)).to eq([:count, nil])
      expect(UnitConversionService.unit_family('')).to eq([:count, nil])
    end

    it 'treats non-convertible units as other' do
      expect(UnitConversionService.unit_family('cloves')).to eq([:other, 'cloves'])
      expect(UnitConversionService.unit_family('cans')).to eq([:other, 'cans'])
    end
  end

  describe '.combinable?' do
    it 'allows combining volume units' do
      expect(UnitConversionService.combinable?('teaspoons', 'tablespoons')).to be true
      expect(UnitConversionService.combinable?('tablespoons', 'cups')).to be true
    end

    it 'allows combining size qualifiers with nil (plain count)' do
      expect(UnitConversionService.combinable?(nil, 'small')).to be true
      expect(UnitConversionService.combinable?('large', nil)).to be true
    end

    it 'does not combine across families' do
      expect(UnitConversionService.combinable?('cups', 'ounces')).to be false
      expect(UnitConversionService.combinable?('grams', 'pounds')).to be false
    end

    it 'does not combine different non-convertible units' do
      expect(UnitConversionService.combinable?('cloves', 'cans')).to be false
    end
  end

  describe '.convert' do
    it 'converts teaspoons to tablespoons' do
      expect(UnitConversionService.convert(3, 'teaspoons', 'tablespoons')).to eq(1.0)
    end

    it 'converts tablespoons to cups' do
      expect(UnitConversionService.convert(48, 'tablespoons', 'cups')).to eq(3.0)
    end

    it 'converts ounces to pounds' do
      expect(UnitConversionService.convert(16, 'ounces', 'pounds')).to eq(1.0)
    end
  end

  describe '.best_volume_unit' do
    it 'uses teaspoons for small amounts' do
      qty, unit = UnitConversionService.best_volume_unit(2)
      expect(unit).to eq('teaspoons')
      expect(qty).to eq(2.0)
    end

    it 'upgrades to tablespoons at 3+ tsp' do
      qty, unit = UnitConversionService.best_volume_unit(6)
      expect(unit).to eq('tablespoons')
      expect(qty).to eq(2.0)
    end

    it 'upgrades to cups at 24+ tsp (half cup)' do
      qty, unit = UnitConversionService.best_volume_unit(96)
      expect(unit).to eq('cups')
      expect(qty).to eq(2.0)
    end
  end
end

RSpec.describe 'GroceryList ingredient merging', type: :model do
  let(:user) { create(:user) }
  let(:grocery_list) { create(:grocery_list, user: user) }

  it 'combines teaspoons and tablespoons of the same ingredient' do
    salt = create(:ingredient, name: 'salt', normalized_name: 'salt')

    grocery_list.add_or_update_ingredient(salt, 1, 'tablespoons')  # 3 tsp
    grocery_list.add_or_update_ingredient(salt, 1, 'teaspoons')    # 1 tsp → total 4 tsp

    items = grocery_list.grocery_list_items.reload
    expect(items.count).to eq(1)
    expect(items.first.unit).to eq('tablespoons')
    expect(items.first.quantity.to_f).to be_within(0.01).of(1.33)
  end

  it 'combines eggs with different size qualifiers' do
    egg = create(:ingredient, name: 'egg', normalized_name: 'egg')

    grocery_list.add_or_update_ingredient(egg, 4, nil)
    grocery_list.add_or_update_ingredient(egg, 2, 'large')
    grocery_list.add_or_update_ingredient(egg, 3, 'small')

    items = grocery_list.grocery_list_items.reload
    expect(items.count).to eq(1)
    expect(items.first.quantity.to_f).to eq(9.0)
    expect(items.first.unit).to be_nil
  end

  it 'keeps non-convertible units separate' do
    garlic = create(:ingredient, name: 'garlic', normalized_name: 'garlic')

    grocery_list.add_or_update_ingredient(garlic, 3, 'cloves')
    grocery_list.add_or_update_ingredient(garlic, 1, 'heads')

    items = grocery_list.grocery_list_items.reload
    expect(items.count).to eq(2)
  end
end
