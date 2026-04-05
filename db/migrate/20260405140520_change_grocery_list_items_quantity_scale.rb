class ChangeGroceryListItemsQuantityScale < ActiveRecord::Migration[7.1]
  def change
    change_column :grocery_list_items, :quantity, :decimal, precision: 10, scale: 3
  end
end
