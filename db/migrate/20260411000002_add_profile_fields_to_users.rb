class AddProfileFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :name, :string
    add_column :users, :username, :string
    add_column :users, :bio, :text
    add_column :users, :notification_preferences, :text
    add_index :users, :username, unique: true
  end
end
