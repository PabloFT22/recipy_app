class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :recipes, dependent: :destroy
  has_many :grocery_lists, dependent: :destroy
  has_many :recipe_collections, dependent: :destroy
  has_many :meal_plans, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true
end
