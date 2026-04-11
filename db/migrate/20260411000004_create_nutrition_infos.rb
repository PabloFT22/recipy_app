class CreateNutritionInfos < ActiveRecord::Migration[7.1]
  def change
    create_table :nutrition_infos do |t|
      t.bigint :recipe_id, null: false
      t.decimal :calories, precision: 8, scale: 2
      t.decimal :protein_g, precision: 8, scale: 2
      t.decimal :carbs_g, precision: 8, scale: 2
      t.decimal :fat_g, precision: 8, scale: 2
      t.decimal :fiber_g, precision: 8, scale: 2
      t.decimal :sugar_g, precision: 8, scale: 2
      t.decimal :sodium_mg, precision: 8, scale: 2
      t.integer :per_servings
      t.datetime :fetched_at
      t.timestamps
    end

    add_index :nutrition_infos, :recipe_id, unique: true
    add_foreign_key :nutrition_infos, :recipes
  end
end
