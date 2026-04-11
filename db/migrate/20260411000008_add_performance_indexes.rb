class AddPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    add_index :recipes, [:user_id, :is_public]
    add_index :recipes, [:user_id, :difficulty]
    add_index :meal_plan_recipes, [:meal_plan_id, :scheduled_for]
    add_index :grocery_list_items, [:grocery_list_id, :checked]
    add_index :recipes, [:average_rating]
  end
end
