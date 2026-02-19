class CreateMealPlanRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :meal_plan_recipes do |t|
      t.references :meal_plan, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true
      t.date :scheduled_for
      t.string :meal_type
      t.integer :servings

      t.timestamps
    end
  end
end
