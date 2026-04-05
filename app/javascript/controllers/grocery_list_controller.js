import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category", "categoryItems", "chevron", "progressFill"]

  // ── Category Collapse / Expand ─────────────────
  toggleCategory(event) {
    const category = event.currentTarget.closest(".gl-category")
    const items = category.querySelector(".gl-category-items")
    const chevron = category.querySelector(".gl-category-chevron")

    if (items.classList.contains("gl-category-items--collapsed")) {
      items.classList.remove("gl-category-items--collapsed")
      chevron.textContent = "▼"
    } else {
      items.classList.add("gl-category-items--collapsed")
      chevron.textContent = "▶"
    }
  }
}
