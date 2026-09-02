class AddFieldsToPantryItems < ActiveRecord::Migration[7.1]
  def change
    add_column :pantry_items, :quantity, :decimal, precision: 8, scale: 2
    add_column :pantry_items, :unit, :string
    add_column :pantry_items, :expiration_date, :date
    add_column :pantry_items, :notes, :string
  end
end
