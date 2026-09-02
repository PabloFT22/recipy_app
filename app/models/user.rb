class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :recipes, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :grocery_lists, dependent: :destroy
  has_many :recipe_collections, dependent: :destroy
  has_many :meal_plans, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_recipes, through: :likes, source: :recipe
  has_many :pantry_items, dependent: :destroy
  has_many :pantry_ingredients, through: :pantry_items, source: :ingredient
  has_many :follows_as_follower, class_name: 'Follow', foreign_key: :follower_id, dependent: :destroy
  has_many :follows_as_following, class_name: 'Follow', foreign_key: :following_id, dependent: :destroy
  has_many :following, through: :follows_as_follower, source: :following
  has_many :followers, through: :follows_as_following, source: :follower
  has_one_attached :avatar

  validates :email, presence: true, uniqueness: true
  validates :username, uniqueness: true, allow_nil: true

  def following?(user)
    follows_as_follower.exists?(following: user)
  end

  def display_name
    name.presence || username.presence || email.split('@').first
  end
end
