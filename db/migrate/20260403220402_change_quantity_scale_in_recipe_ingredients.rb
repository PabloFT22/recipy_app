class ChangeQuantityScaleInRecipeIngredients < ActiveRecord::Migration[7.1]
  def change
    # Change from decimal(10,0) to decimal(10,3) so fractions like 0.5, 0.25 are preserved
    change_column :recipe_ingredients, :quantity, :decimal, precision: 10, scale: 3
  end
end
