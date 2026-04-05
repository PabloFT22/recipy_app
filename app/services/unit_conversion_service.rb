class UnitConversionService
  # All conversions stored as ratios to a base unit per family.
  # Volume base: teaspoons
  # Weight (metric) base: grams
  # Weight (imperial) base: ounces

  VOLUME_TO_TSP = {
    'teaspoons'   => 1,
    'tablespoons' => 3,
    'cups'        => 48,
    'milliliters' => 0.202884,
    'liters'      => 202.884,
    'pinch'       => 0.125,    # ~1/8 tsp
    'dash'        => 0.25      # ~1/4 tsp
  }.freeze

  WEIGHT_METRIC_TO_G = {
    'grams'     => 1,
    'kilograms' => 1000
  }.freeze

  WEIGHT_IMPERIAL_TO_OZ = {
    'ounces' => 1,
    'pounds' => 16
  }.freeze

  # Units that describe size/count — not real measurement units.
  # These should be stripped and the item treated as a plain count.
  SIZE_QUALIFIERS = %w[large medium small whole pieces piece].freeze

  # Preferred display unit per volume tier (smallest sensible unit first)
  VOLUME_DISPLAY_TIERS = [
    { threshold: 0,  unit: 'teaspoons' },
    { threshold: 3,  unit: 'tablespoons' },   # 3+ tsp → tablespoons
    { threshold: 24, unit: 'cups' }            # 24+ tsp (½ cup) → cups
  ].freeze

  class << self
    # Normalize a unit to its canonical form for comparison.
    # Returns [family, canonical_unit] or [:count, nil] for size qualifiers,
    # or [:other, unit] for non-convertible units.
    def unit_family(unit)
      return [:count, nil] if unit.blank?
      return [:count, nil] if SIZE_QUALIFIERS.include?(unit)

      if VOLUME_TO_TSP.key?(unit)
        [:volume, unit]
      elsif WEIGHT_METRIC_TO_G.key?(unit)
        [:weight_metric, unit]
      elsif WEIGHT_IMPERIAL_TO_OZ.key?(unit)
        [:weight_imperial, unit]
      else
        [:other, unit]
      end
    end

    # Can two units be combined?
    def combinable?(unit_a, unit_b)
      family_a, canonical_a = unit_family(unit_a)
      family_b, canonical_b = unit_family(unit_b)

      return false unless family_a == family_b

      # For :other (non-convertible units like cloves, cans), only combine if same unit
      if family_a == :other
        canonical_a == canonical_b
      else
        true
      end
    end

    # Convert a quantity from one unit to another within the same family.
    # Returns nil if not convertible.
    def convert(quantity, from_unit, to_unit)
      return quantity if from_unit == to_unit
      return nil unless quantity

      family_from, = unit_family(from_unit)
      family_to, = unit_family(to_unit)
      return nil unless family_from == family_to

      case family_from
      when :volume
        base = quantity * VOLUME_TO_TSP[from_unit]
        base / VOLUME_TO_TSP[to_unit]
      when :weight_metric
        base = quantity * WEIGHT_METRIC_TO_G[from_unit]
        base / WEIGHT_METRIC_TO_G[to_unit]
      when :weight_imperial
        base = quantity * WEIGHT_IMPERIAL_TO_OZ[from_unit]
        base / WEIGHT_IMPERIAL_TO_OZ[to_unit]
      when :count
        quantity # Counts just add up directly
      else
        nil
      end
    end

    # Given a total in teaspoons, pick the best display unit.
    # Returns [quantity, unit] — e.g., [1.333, "tablespoons"] for 4 tsp
    def best_volume_unit(total_tsp)
      # Work backwards from largest to find the best fit
      best = VOLUME_DISPLAY_TIERS.first
      VOLUME_DISPLAY_TIERS.each do |tier|
        best = tier if total_tsp >= tier[:threshold]
      end
      [total_tsp / VOLUME_TO_TSP[best[:unit]], best[:unit]]
    end

    # Given a total in grams, pick grams or kilograms.
    def best_metric_weight_unit(total_g)
      if total_g >= 1000
        [total_g / 1000.0, 'kilograms']
      else
        [total_g, 'grams']
      end
    end

    # Given a total in ounces, pick ounces or pounds.
    def best_imperial_weight_unit(total_oz)
      if total_oz >= 16
        [total_oz / 16.0, 'pounds']
      else
        [total_oz, 'ounces']
      end
    end

    # Smart merge: given a quantity and unit, convert to base and pick the best display unit.
    # Returns [rounded_quantity, display_unit]
    def smart_display(quantity, unit)
      return [quantity, unit] unless quantity

      family, = unit_family(unit)

      case family
      when :volume
        total_tsp = quantity * VOLUME_TO_TSP[unit]
        qty, display_unit = best_volume_unit(total_tsp)
        [round_nicely(qty), display_unit]
      when :weight_metric
        total_g = quantity * WEIGHT_METRIC_TO_G[unit]
        qty, display_unit = best_metric_weight_unit(total_g)
        [round_nicely(qty), display_unit]
      when :weight_imperial
        total_oz = quantity * WEIGHT_IMPERIAL_TO_OZ[unit]
        qty, display_unit = best_imperial_weight_unit(total_oz)
        [round_nicely(qty), display_unit]
      else
        [round_nicely(quantity), unit]
      end
    end

    private

    # Round to a reasonable precision — avoid ugly floats like 5.333333
    def round_nicely(value)
      rounded = value.round(2)
      rounded == rounded.to_i ? rounded.to_i.to_f : rounded
    end
  end
end
