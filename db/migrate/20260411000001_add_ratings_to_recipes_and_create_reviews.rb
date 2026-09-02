class AddRatingsToRecipesAndCreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.bigint :user_id, null: false
      t.bigint :recipe_id, null: false
      t.integer :rating, null: false
      t.text :body
      t.timestamps
    end

    add_index :reviews, [:user_id, :recipe_id], unique: true
    add_foreign_key :reviews, :users
    add_foreign_key :reviews, :recipes

    add_column :recipes, :average_rating, :decimal, precision: 3, scale: 2
    add_column :recipes, :reviews_count, :integer, default: 0
  end
end
