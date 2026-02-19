class CreateGroceryListItems < ActiveRecord::Migration[7.1]
  def change
    create_table :grocery_list_items do |t|
      t.references :grocery_list, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.decimal :quantity
      t.string :unit
      t.boolean :checked
      t.boolean :on_hand

      t.timestamps
    end
  end
end
