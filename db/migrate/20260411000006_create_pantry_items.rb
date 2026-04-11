class CreatePantryItems < ActiveRecord::Migration[7.1]
  def change
    create_table :pantry_items do |t|
      t.bigint :user_id, null: false
      t.bigint :ingredient_id, null: false
      t.decimal :quantity, precision: 8, scale: 2
      t.string :unit
      t.date :expiration_date
      t.string :notes
      t.timestamps
    end

    add_index :pantry_items, :user_id
    add_index :pantry_items, :ingredient_id
    add_index :pantry_items, [:user_id, :ingredient_id], unique: true
    add_foreign_key :pantry_items, :users
    add_foreign_key :pantry_items, :ingredients
  end
end
