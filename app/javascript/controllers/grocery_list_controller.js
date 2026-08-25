import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category", "categoryItems", "chevron", "progressFill"]

  // ── Category Collapse / Expand ─────────────────
  // The chevron is an SVG now, so it rotates via CSS instead of swapping glyphs.
  toggleCategory(event) {
    const header = event.currentTarget
    const category = header.closest(".gl-category")
    const items = category.querySelector(".gl-category-items")
    const collapsed = items.classList.toggle("gl-category-items--collapsed")

    header.setAttribute("aria-expanded", String(!collapsed))
    category.classList.toggle("gl-category--collapsed", collapsed)
  }

  // The header is a div acting as a button, so wire up the keyboard.
  toggleCategoryOnKey(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault()
      this.toggleCategory(event)
    }
  }
}
