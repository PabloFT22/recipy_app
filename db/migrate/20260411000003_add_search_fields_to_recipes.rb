class AddSearchFieldsToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :cuisine_type, :string
    add_column :recipes, :dietary_tags, :string

    # This originally created a MySQL FULLTEXT index, which does not exist on
    # Postgres. The Postgres equivalent for the ILIKE search in Recipe.search
    # is a pg_trgm GIN index: it makes leading-wildcard "%term%" matches fast,
    # which a normal B-tree cannot do.
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    add_index :recipes, :title,
              using: :gin, opclass: :gin_trgm_ops,
              name: "index_recipes_on_title_trgm"
    add_index :recipes, :description,
              using: :gin, opclass: :gin_trgm_ops,
              name: "index_recipes_on_description_trgm"
  end
end
