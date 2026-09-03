module NavigationHelper
  # A top-nav link that marks itself as the current page.
  #
  # `match` is the controller name (or names) the link represents, so
  # /recipes/chili-con-carne still highlights "Recipes".
  def nav_link_to(name, path, match: nil, **options)
    matches = Array(match).map(&:to_s)
    current = matches.include?(controller_name) || current_page?(path)

    classes = ["nav-link", options.delete(:class)]
    classes << "nav-link--current" if current

    data = { action: "click->navbar#closeFromLink" }.merge(options.delete(:data) || {})

    link_to name, path,
            class: classes.compact.join(" "),
            "aria-current": (current ? "page" : nil),
            data: data,
            **options
  end
end
