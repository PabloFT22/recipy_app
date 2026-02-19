class Ingredient < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients
  has_many :grocery_list_items, dependent: :destroy
  
  validates :name, presence: true
  validates :normalized_name, presence: true, uniqueness: true
  
  before_validation :normalize_name
  
  scope :by_category, ->(category) { where(category: category) }
  scope :search, ->(query) { where("normalized_name ILIKE ?", "%#{query.downcase}%") }
  
  CATEGORIES = %w[
    produce
    dairy
    meat
    seafood
    bakery
    pantry
    frozen
    beverages
    condiments
    spices
    other
  ].freeze
  
  validates :category, inclusion: { in: CATEGORIES, allow_nil: true }
  
  private
  
  def normalize_name
    return if name.blank?
    
    normalized = name.downcase.strip
    normalized = normalized.gsub(/\s+/, ' ')
    normalized = normalized.singularize if normalized.respond_to?(:singularize)
    
    self.normalized_name = normalized
  end
end
