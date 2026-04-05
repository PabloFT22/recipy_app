import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startDate", "endDate", "dateHint", "dateError",
    "pickerOverlay", "picker", "pickerMealLabel",
    "searchInput", "recipeList", "confirmSection",
    "recipeIdField", "dateField", "mealTypeField",
    "servingsField", "selectedRecipeName"
  ]

  connect() {
    // Close picker on Escape key
    this.boundKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.closePicker()
    }
  }

  // ── Date Validation ────────────────────────────
  validateDates() {
    if (!this.hasStartDateTarget || !this.hasEndDateTarget) return

    const start = this.startDateTarget.value
    const end = this.endDateTarget.value

    if (start && end) {
      const startDate = new Date(start)
      const endDate = new Date(end)

      if (endDate < startDate) {
        this.dateErrorTarget.textContent = "End date must be after start date"
        this.dateErrorTarget.style.display = "block"
        this.dateHintTarget.textContent = ""
      } else {
        this.dateErrorTarget.style.display = "none"
        const days = Math.round((endDate - startDate) / (1000 * 60 * 60 * 24)) + 1
        this.dateHintTarget.textContent = `${days} day${days !== 1 ? 's' : ''} selected`
      }
    }
  }

  // ── Recipe Picker ──────────────────────────────
  openPicker(event) {
    const date = event.currentTarget.dataset.date
    const mealType = event.currentTarget.dataset.mealType

    // Store context for the form
    this.dateFieldTarget.value = date
    this.mealTypeFieldTarget.value = mealType

    // Format label
    const formattedDate = new Date(date + "T12:00:00").toLocaleDateString("en-US", {
      weekday: "short",
      month: "short",
      day: "numeric"
    })
    this.pickerMealLabelTarget.textContent = `${mealType.charAt(0).toUpperCase() + mealType.slice(1)} — ${formattedDate}`

    // Reset state
    this.searchInputTarget.value = ""
    this.filterRecipes()
    this.showRecipeList()

    // Show overlay
    this.pickerOverlayTarget.style.display = "flex"
    this.searchInputTarget.focus()
  }

  closePicker() {
    if (this.hasPickerOverlayTarget) {
      this.pickerOverlayTarget.style.display = "none"
    }
  }

  filterRecipes() {
    const query = this.searchInputTarget.value.toLowerCase()
    const recipes = this.recipeListTarget.querySelectorAll(".mp-picker-recipe")

    recipes.forEach(recipe => {
      const title = recipe.dataset.recipeTitle || ""
      recipe.style.display = title.includes(query) ? "flex" : "none"
    })
  }

  selectRecipe(event) {
    const recipeId = event.currentTarget.dataset.recipeId
    const recipeName = event.currentTarget.closest(".mp-picker-recipe").querySelector("strong").textContent

    this.recipeIdFieldTarget.value = recipeId
    this.selectedRecipeNameTarget.textContent = recipeName

    // Hide recipe list, show confirm section
    this.recipeListTarget.style.display = "none"
    this.element.querySelector(".mp-picker-search").style.display = "none"
    this.confirmSectionTarget.style.display = "block"
  }

  cancelSelect() {
    this.showRecipeList()
  }

  showRecipeList() {
    this.recipeListTarget.style.display = "block"
    if (this.element.querySelector(".mp-picker-search")) {
      this.element.querySelector(".mp-picker-search").style.display = "block"
    }
    this.confirmSectionTarget.style.display = "none"
  }
}
