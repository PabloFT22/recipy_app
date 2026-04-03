module ApplicationHelper
  # Convert a decimal quantity to a friendly fraction string for display
  # Examples: 0.25 → "¼", 0.5 → "½", 1.5 → "1 ½", 2.333 → "2 ⅓", 3.0 → "3"
  def display_quantity(qty)
    return '' if qty.blank?

    whole = qty.floor
    decimal = (qty - whole).round(3)

    fraction = case decimal
               when 0.0   then nil
               when 0.125 then '⅛'
               when 0.167 then '⅙'
               when 0.2   then '⅕'
               when 0.25  then '¼'
               when 0.333 then '⅓'
               when 0.375 then '⅜'
               when 0.4   then '⅖'
               when 0.5   then '½'
               when 0.6   then '⅗'
               when 0.625 then '⅝'
               when 0.667 then '⅔'
               when 0.75  then '¾'
               when 0.8   then '⅘'
               when 0.833 then '⅚'
               when 0.875 then '⅞'
               else nil
               end

    if fraction
      whole > 0 ? "#{whole} #{fraction}" : fraction
    elsif decimal == 0.0
      whole.to_s
    else
      # Fallback: show the decimal as-is, stripped of trailing zeros
      number_with_precision(qty, strip_insignificant_zeros: true)
    end
  end
end
