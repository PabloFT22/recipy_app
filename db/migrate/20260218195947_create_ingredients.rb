class CreateIngredients < ActiveRecord::Migration[7.1]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false
      t.string :normalized_name, null: false
      t.string :category

      t.timestamps
    end
    
    add_index :ingredients, :normalized_name, unique: true
    add_index :ingredients, :category
  end
end
