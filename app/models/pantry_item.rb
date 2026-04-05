class PantryItem < ApplicationRecord
  belongs_to :user
  belongs_to :ingredient

  validates :ingredient_id, uniqueness: { scope: :user_id, message: "is already in your pantry" }

  # Default pantry staples — normalized ingredient names that most people keep stocked.
  # These get seeded when a user first visits their pantry.
  DEFAULT_STAPLES = %w[
    salt
    pepper
    sugar
    flour
    olive\ oil
    vegetable\ oil
    butter
    garlic
    baking\ soda
    baking\ powder
    vanilla\ extract
    soy\ sauce
    vinegar
    black\ pepper
    cinnamon
    paprika
    cumin
    oregano
    red\ pepper\ flakes
    onion\ powder
    garlic\ powder
    chili\ powder
    bay\ leaves
  ].freeze

  # Seed default pantry items for a user, finding or creating ingredients as needed.
  def self.seed_defaults_for(user)
    return if user.pantry_items.exists? # Don't re-seed if they already have pantry items

    DEFAULT_STAPLES.each do |name|
      normalized = name.downcase.strip
      ingredient = Ingredient.find_or_create_by(normalized_name: normalized) do |ing|
        ing.name = name
        ing.category = guess_category(normalized)
      end
      user.pantry_items.find_or_create_by(ingredient: ingredient)
    end
  end

  private

  def self.guess_category(name)
    spices = %w[salt pepper cinnamon paprika cumin oregano chili\ powder onion\ powder
                garlic\ powder black\ pepper bay\ leaves red\ pepper\ flakes]
    pantry = %w[sugar flour baking\ soda baking\ powder vanilla\ extract soy\ sauce vinegar]
    dairy = %w[butter]

    if spices.include?(name)
      'spices'
    elsif pantry.include?(name)
      'pantry'
    elsif dairy.include?(name)
      'dairy'
    elsif name.include?('oil')
      'pantry'
    else
      'other'
    end
  end
end
