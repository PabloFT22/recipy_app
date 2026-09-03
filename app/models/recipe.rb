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
  has_many :recipe_tags, dependent: :destroy
  has_many :tags, through: :recipe_tags
  has_many :reviews, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_one :nutrition_info, dependent: :destroy
  has_one_attached :image

  # The form's difficulty select submits "" when nothing is chosen; the
  # inclusion validation below only tolerates nil, so blank has to become nil.
  normalizes :difficulty, with: ->(value) { value.presence }

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
  # left_joins rather than includes: Postgres will not let an eager-loaded
  # association's columns sit outside GROUP BY.
  scope :popular, -> { left_joins(:meal_plan_recipes).group(:id).order(Arel.sql('COUNT(meal_plan_recipes.id) DESC')) }
  scope :by_cuisine, ->(cuisine) { where(cuisine_type: cuisine) }

  # dietary_tags is a comma-separated string. MySQL's FIND_IN_SET does not
  # exist on Postgres, so match the tag between delimiters instead — same
  # semantics ("vegan" must not match "vegan-ish"), and portable.
  scope :by_dietary_tag, lambda { |tag|
    needle = "%,#{sanitize_sql_like(tag.to_s.strip)},%"
    where(Arel.sql("',' || COALESCE(dietary_tags, '') || ','").matches(needle))
  }

  scope :by_max_time, ->(minutes) { where("(COALESCE(prep_time, 0) + COALESCE(cook_time, 0)) <= ?", minutes) }

  # Arel#matches is case-insensitive on every adapter Rails supports (it emits
  # ILIKE on Postgres, LIKE on MySQL). A bare LIKE would be case-SENSITIVE on
  # Postgres, so searching "chicken" would miss "Chicken Soup".
  #
  # This replaces main's MATCH ... AGAINST full-text scope, which is MySQL-only.
  # The equivalent speed-up on Postgres is the pg_trgm GIN index added in
  # AddSearchFieldsToRecipes, which makes exactly this ILIKE fast.
  scope :search, ->(query) do
    term = "%#{sanitize_sql_like(query.to_s.strip)}%"
    t = arel_table
    where(t[:title].matches(term).or(t[:description].matches(term)))
  end
  scope :by_tag, ->(tag_id) { joins(:tags).where(tags: { id: tag_id }) }

  # Nutrition is looked up from the ingredient list, which the controllers write
  # *after* the recipe row is saved, so a save callback cannot see it. The
  # controllers call this once the ingredients are in place instead.
  def refresh_nutrition_later
    NutritionFetchJob.perform_later(id) if recipe_ingredients.exists?
  end

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
end
