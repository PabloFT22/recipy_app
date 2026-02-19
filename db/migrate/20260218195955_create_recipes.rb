class CreateRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :servings, default: 1
      t.integer :prep_time
      t.integer :cook_time
      t.text :instructions
      t.string :source_url
      t.string :difficulty
      t.string :slug
      t.boolean :is_public, default: false

      t.timestamps
    end
    
    add_index :recipes, :slug, unique: true
    add_index :recipes, [:user_id, :created_at]
    add_index :recipes, :is_public
  end
end
