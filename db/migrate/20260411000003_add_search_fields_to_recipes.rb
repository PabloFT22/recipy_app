class AddSearchFieldsToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :cuisine_type, :string
    add_column :recipes, :dietary_tags, :string

    reversible do |dir|
      dir.up do
        execute "ALTER TABLE recipes ADD FULLTEXT INDEX fulltext_recipes_search (title, description)"
      end
      dir.down do
        execute "ALTER TABLE recipes DROP INDEX fulltext_recipes_search"
      end
    end
  end
end
