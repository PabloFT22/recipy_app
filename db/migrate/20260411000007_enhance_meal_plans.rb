class EnhanceMealPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :meal_plans, :is_template, :boolean, default: false
  end
end
