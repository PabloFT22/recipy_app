class CreateRecipeCollectionMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :recipe_collection_memberships do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :recipe_collection, null: false, foreign_key: true

      t.timestamps
    end
  end
end
