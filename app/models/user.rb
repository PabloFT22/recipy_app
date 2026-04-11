class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :recipes, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :grocery_lists, dependent: :destroy
  has_many :recipe_collections, dependent: :destroy
  has_many :meal_plans, dependent: :destroy
  has_many :pantry_items, dependent: :destroy
  has_many :pantry_ingredients, through: :pantry_items, source: :ingredient
  
  validates :email, presence: true, uniqueness: true
end
