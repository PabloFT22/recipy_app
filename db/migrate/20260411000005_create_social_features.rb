class CreateSocialFeatures < ActiveRecord::Migration[7.1]
  def change
    create_table :follows do |t|
      t.bigint :follower_id, null: false
      t.bigint :following_id, null: false
      t.timestamps
    end

    add_index :follows, [:follower_id, :following_id], unique: true
    add_index :follows, :following_id
    add_foreign_key :follows, :users, column: :follower_id
    add_foreign_key :follows, :users, column: :following_id

    create_table :likes do |t|
      t.bigint :user_id, null: false
      t.bigint :recipe_id, null: false
      t.timestamps
    end

    add_index :likes, [:user_id, :recipe_id], unique: true
    add_index :likes, :recipe_id
    add_foreign_key :likes, :users
    add_foreign_key :likes, :recipes
  end
end
