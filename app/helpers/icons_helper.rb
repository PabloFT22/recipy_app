module IconsHelper
  # Inline SVG icon set — replaces the emoji that used to be scattered through
  # the views. Everything is stroke-based on a 24x24 grid and inherits
  # `currentColor`, so an icon always matches the text it sits next to.
  #
  #   <%= icon(:clock) %>
  #   <%= icon(:cart, size: 18, class: "gl-icon") %>
  #   <%= icon(:trash, title: "Delete item") %>   # standalone -> gets a label
  #
  # Icons are decorative by default (aria-hidden). Pass `title:` when the icon
  # is the only content of a control and needs an accessible name.
  ICON_PATHS = {
    # ── Time ──────────────────────────────────────────────
    clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
    alarm: '<circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 1.5M5 3 2.5 5.5M19 3l2.5 2.5"/>',
    calendar: '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>',
    sunrise: '<path d="M12 3v5M5.6 10.6 4.2 9.2M18.4 10.6l1.4-1.4M2 18h20M6 18a6 6 0 0 1 12 0"/>',
    sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
    moon: '<path d="M20 14.5A8.5 8.5 0 1 1 9.5 4a7 7 0 0 0 10.5 10.5Z"/>',
    apple: '<path d="M12 8c-1.5-2.5-5-2.5-6.5 0-1.8 3 .5 11 3.5 11 1 0 1.5-.6 3-.6s2 .6 3 .6c3 0 5.3-8 3.5-11-1.5-2.5-5-2.5-6.5 0Z"/><path d="M12 8c0-2 1-3.5 3-4"/>',

    # ── Cooking ───────────────────────────────────────────
    plate: '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="4.5"/>',
    pot: '<path d="M4 9h16v6a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4Z"/><path d="M2 11h2M20 11h2M8 6V4M12 6V3M16 6V4"/>',
    chef: '<path d="M7 20h10M6.5 16h11a4.5 4.5 0 0 0 .5-8.9 4 4 0 0 0-7.6-1.6A3.5 3.5 0 0 0 6.5 16Z"/>',
    flame: '<path d="M12 21a6 6 0 0 0 6-6c0-4-3-5-3-9-3 1.5-4.5 4-4.5 6.5C10.5 10 9 9 9 7c-1.9 1.7-3 4-3 8a6 6 0 0 0 6 6Z"/>',
    scale: '<path d="M12 4v16M6 8h12M8 8l-3 6a3 3 0 0 0 6 0ZM16 8l-3 6a3 3 0 0 0 6 0Z"/>',

    # ── Objects ───────────────────────────────────────────
    cart: '<circle cx="9" cy="20" r="1.5"/><circle cx="18" cy="20" r="1.5"/><path d="M2 3h3l2.6 11.4a2 2 0 0 0 2 1.6h7.7a2 2 0 0 0 2-1.5L21 7H6"/>',
    book: '<path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v18H6.5A2.5 2.5 0 0 0 4 22Z"/><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>',
    books: '<path d="M4 3h4v18H4zM10 3h4v18h-4z"/><path d="m16.5 4.5 3.6 1-4 15-3.6-1"/>',
    box: '<path d="m12 2 9 5v10l-9 5-9-5V7Z"/><path d="m3 7 9 5 9-5M12 12v10"/>',
    folder: '<path d="M3 7a2 2 0 0 1 2-2h4l2 2.5h8a2 2 0 0 1 2 2V17a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2Z"/>',
    clipboard: '<rect x="6" y="4" width="12" height="17" rx="2"/><path d="M9 4a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2M9 11h6M9 15h4"/>',
    note: '<path d="M5 3h9l5 5v13H5Z"/><path d="M14 3v5h5M8 13h8M8 17h5"/>',
    tag: '<path d="M3 12V5a2 2 0 0 1 2-2h7l9 9-9 9Z"/><circle cx="7.5" cy="7.5" r="1.5"/>',
    link: '<path d="M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7L11.5 7"/><path d="M14 10a4 4 0 0 0-5.7 0l-3 3A4 4 0 0 0 11 18.7L12.5 17"/>',
    printer: '<path d="M7 8V3h10v5"/><rect x="3" y="8" width="18" height="8" rx="2"/><path d="M7 14h10v7H7Z"/>',
    camera: '<path d="M3 8a2 2 0 0 1 2-2h2.5L9 4h6l1.5 2H19a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2Z"/><circle cx="12" cy="13" r="3.5"/>',
    bulb: '<path d="M9.5 18h5M10 21h4"/><path d="M12 3a6 6 0 0 0-3.5 10.9c.6.5 1 1.2 1 2h5c0-.8.4-1.5 1-2A6 6 0 0 0 12 3Z"/>',
    lock: '<rect x="4" y="10" width="16" height="11" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/>',
    users: '<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20a6.5 6.5 0 0 1 13 0"/><path d="M16 5a3.5 3.5 0 0 1 0 7M17.5 20a6.6 6.6 0 0 0-2-4.7"/>',
    home: '<path d="m3 10 9-7 9 7v10a1.5 1.5 0 0 1-1.5 1.5h-15A1.5 1.5 0 0 1 3 20Z"/><path d="M9.5 21.5V14h5v7.5"/>',
    chart: '<path d="M3 21h18"/><path d="M6 21v-7M11 21V6M16 21v-11M21 21V13"/>',
    star: '<path d="m12 3.5 2.6 5.4 5.9.8-4.3 4.1 1.1 5.9-5.3-2.9-5.3 2.9 1.1-5.9L3.5 9.7l5.9-.8Z"/>',
    heart: '<path d="M12 20.5 4.8 13.4a4.6 4.6 0 0 1 6.5-6.5l.7.7.7-.7a4.6 4.6 0 0 1 6.5 6.5Z"/>',
    globe: '<circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a15 15 0 0 1 0 18 15 15 0 0 1 0-18Z"/>',

    # ── Actions ───────────────────────────────────────────
    plus: '<path d="M12 5v14M5 12h14"/>',
    close: '<path d="M6 6l12 12M18 6 6 18"/>',
    check: '<path d="m4.5 12.5 5 5 10-11"/>',
    check_circle: '<circle cx="12" cy="12" r="9"/><path d="m8 12.5 2.5 2.5L16 9.5"/>',
    pencil: '<path d="M4 20h4L20 8a2.8 2.8 0 0 0-4-4L4 16Z"/><path d="m14.5 5.5 4 4"/>',
    trash: '<path d="M4 7h16M10 4h4M9 7v12M15 7v12"/><path d="M6 7h12l-.8 13a1.5 1.5 0 0 1-1.5 1.4H8.3A1.5 1.5 0 0 1 6.8 20Z"/>',
    search: '<circle cx="11" cy="11" r="7"/><path d="m16.5 16.5 4.5 4.5"/>',
    refresh: '<path d="M20 12a8 8 0 1 1-2.3-5.6"/><path d="M20 3v5h-5"/>',
    share: '<path d="M12 15V3M8.5 6.5 12 3l3.5 3.5"/><path d="M4 13v6a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-6"/>',
    bolt: '<path d="M13 2 4 14h7l-1 8 9-12h-7Z"/>',
    arrow_left: '<path d="M20 12H4M10 6l-6 6 6 6"/>',
    chevron_down: '<path d="m6 9 6 6 6-6"/>',
    chevron_right: '<path d="m9 6 6 6-6 6"/>',
    copy: '<rect x="9" y="9" width="12" height="12" rx="2"/><path d="M5 15H4a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h10a1 1 0 0 1 1 1v1"/>',
    download: '<path d="M12 3v12M8 11l4 4 4-4"/><path d="M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-2"/>',
    info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>',
    warning: '<path d="M12 3 2 20h20Z"/><path d="M12 10v4M12 17h.01"/>',

    # ── Pantry / ingredient categories ────────────────────
    cat_produce: '<path d="M11 21c-4 0-7-3.5-7-8 0-3 2-5 4.5-5 1.3 0 2 .5 2.5 1 .5-.5 1.2-1 2.5-1 2.5 0 4.5 2 4.5 5 0 4.5-3 8-7 8Z"/><path d="M11 21V8M11 8c0-2.5 1.5-4.5 4-5"/>',
    cat_dairy: '<path d="M7 3h10l-1 4v13a1 1 0 0 1-1 1H9a1 1 0 0 1-1-1V7Z"/><path d="M8 7h8"/>',
    cat_meat: '<path d="M6.5 17.5a5 5 0 0 1 0-7l4-4a5 5 0 0 1 7 7l-4 4a5 5 0 0 1-7 0Z"/><circle cx="10" cy="14" r="2"/>',
    cat_seafood: '<path d="M3 12c3-4 7-6 11-6 3 0 5 1.5 7 3-2 3-4 4.5-7 4.5-4 0-8-1.5-11-1.5Z"/><path d="M21 9v6M14 9.5h.01"/>',
    cat_bakery: '<path d="M4 14a5 5 0 0 1 5-5h6a5 5 0 0 1 0 10H9a5 5 0 0 1-5-5Z"/><path d="M9 9.5 7.5 19M13 9.5 11.5 19"/>',
    cat_pantry: '<path d="M6 8h12v11a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2Z"/><path d="M8 8V5a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v3M9 13h6"/>',
    cat_frozen: '<path d="M12 2v20M3 7l18 10M21 7 3 17"/><path d="m9 4 3 2 3-2M9 20l3-2 3 2"/>',
    cat_beverages: '<path d="M6 5h12l-1.4 15a1.6 1.6 0 0 1-1.6 1.5H9a1.6 1.6 0 0 1-1.6-1.5Z"/><path d="M6.6 11h10.8"/>',
    cat_condiments: '<path d="M7 9h10v10a2 2 0 0 1-2 2H9a2 2 0 0 1-2-2Z"/><path d="M9 9V6h6v3M10 3h4"/>',
    cat_spices: '<path d="M8 9h8l1 12H7Z"/><path d="M9 9V6a3 3 0 0 1 6 0v3"/><path d="M11 3.5h2"/>',
    cat_other: '<circle cx="12" cy="12" r="9"/><path d="M12 16v.01M12 13a2.5 2.5 0 1 0-2.5-2.9"/>'
  }.freeze

  # Category name (as stored on Ingredient/PantryItem) -> icon key.
  CATEGORY_ICONS = {
    "produce" => :cat_produce,
    "dairy" => :cat_dairy,
    "meat" => :cat_meat,
    "seafood" => :cat_seafood,
    "bakery" => :cat_bakery,
    "pantry" => :cat_pantry,
    "frozen" => :cat_frozen,
    "beverages" => :cat_beverages,
    "condiments" => :cat_condiments,
    "spices" => :cat_spices,
    "other" => :cat_other
  }.freeze

  def icon(name, size: 20, title: nil, **options)
    key = name.to_s.tr("-", "_").to_sym
    paths = ICON_PATHS[key]
    return "".html_safe if paths.nil?

    classes = ["icon", "icon--#{key.to_s.tr('_', '-')}", options.delete(:class)].compact.join(" ")

    attrs = {
      class: classes,
      width: size,
      height: size,
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      "stroke-width": 1.75,
      "stroke-linecap": "round",
      "stroke-linejoin": "round",
      focusable: "false"
    }.merge(options)

    if title.present?
      attrs[:role] = "img"
      attrs["aria-label"] = title
    else
      attrs["aria-hidden"] = "true"
    end

    tag.svg(paths.html_safe, **attrs)
  end

  # Icon for an ingredient / pantry category, falling back to a neutral glyph.
  def category_icon(category, **options)
    icon(CATEGORY_ICONS.fetch(category.to_s.downcase, :cat_other), **options)
  end

  # Meal-type icon used by meal plans.
  def meal_type_icon(meal_type, **options)
    key = case meal_type.to_s.downcase
          when "breakfast" then :sunrise
          when "lunch"     then :sun
          when "dinner"    then :moon
          when "snack"     then :apple
          else :plate
          end
    icon(key, **options)
  end
end
