class Recipe < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_collection_memberships, dependent: :destroy
  has_many :recipe_collections, through: :recipe_collection_memberships
  has_many :meal_plan_recipes, dependent: :destroy
  has_many :meal_plans, through: :meal_plan_recipes
  has_many :reviews, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_one :nutrition_info, dependent: :destroy
  has_one_attached :image

  validates :title, presence: true
  validates :servings, numericality: { greater_than: 0, allow_nil: true }
  validates :prep_time, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :cook_time, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :difficulty, inclusion: { in: %w[easy medium hard], allow_nil: true }

  scope :public_recipes, -> { where(is_public: true) }
  scope :private_recipes, -> { where(is_public: false) }
  scope :by_difficulty, ->(difficulty) { where(difficulty: difficulty) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, -> { order(average_rating: :desc) }
  scope :popular, -> { includes(:meal_plan_recipes).group(:id).order('COUNT(meal_plan_recipes.id) DESC') }
  scope :by_cuisine, ->(cuisine) { where(cuisine_type: cuisine) }
  scope :by_dietary_tag, ->(tag) { where("FIND_IN_SET(?, dietary_tags) > 0", tag) }
  scope :by_max_time, ->(minutes) { where("(COALESCE(prep_time, 0) + COALESCE(cook_time, 0)) <= ?", minutes) }
  MIN_SEARCH_LENGTH = 3

  scope :full_text_search, ->(query) { where("MATCH(title, description) AGAINST(? IN BOOLEAN MODE)", query) }
  scope :search, ->(query) do
    if query.length >= MIN_SEARCH_LENGTH
      full_text_search(query)
    else
      where("title LIKE ? OR description LIKE ?", "%#{query}%", "%#{query}%")
    end
  end

  after_save :enqueue_nutrition_fetch, if: :should_fetch_nutrition?

  attr_writer :ingredients_changed

  def total_time
    return nil unless prep_time && cook_time
    prep_time + cook_time
  end

  def scale_servings(new_servings)
    multiplier = new_servings.to_f / servings
    recipe_ingredients.map do |ri|
      {
        ingredient: ri.ingredient,
        quantity: (ri.quantity * multiplier).round(2),
        unit: ri.unit,
        notes: ri.notes
      }
    end
  end

  def liked_by?(user)
    likes.exists?(user: user)
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  def parse_instructions_into_steps
    return [] if instructions.blank?

    steps = instructions.split(/\n\s*\n+/)
    if steps.length == 1
      steps = instructions.split(/(?=\d+\.)/)
                          .map(&:strip)
                          .reject(&:blank?)
    end
    steps.map(&:strip).reject(&:blank?)
  end

  private

  def should_fetch_nutrition?
    @ingredients_changed || (id_previously_changed? && recipe_ingredients.any?)
  end

  def enqueue_nutrition_fetch
    NutritionFetchJob.perform_later(id)
    @ingredients_changed = false
  end
end
