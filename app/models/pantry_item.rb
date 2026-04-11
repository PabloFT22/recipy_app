class PantryItem < ApplicationRecord
  belongs_to :user
  belongs_to :ingredient

  validates :quantity, numericality: { greater_than: 0, allow_nil: true }

  scope :expiring_soon, -> { where(expiration_date: ..3.days.from_now).where.not(expiration_date: nil) }
  scope :by_category, -> { joins(:ingredient).order('ingredients.category') }
  scope :expired, -> { where('expiration_date < ?', Date.current) }

  def expiring?
    expiration_date.present? && expiration_date <= 3.days.from_now
  end

  def expired?
    expiration_date.present? && expiration_date < Date.current
  end
end
