class CreateGroceryLists < ActiveRecord::Migration[7.1]
  def change
    create_table :grocery_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :status, default: 'active'

      t.timestamps
    end
    
    add_index :grocery_lists, [:user_id, :status]
  end
end
