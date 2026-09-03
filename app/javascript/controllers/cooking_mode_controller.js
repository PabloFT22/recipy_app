import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "step", "stepsContainer", "currentStepNumber",
    "prevBtn", "nextBtn", "progressBar",
    "ingredientItem", "stepText"
  ]
  static values = { stepsCount: Number }

  connect() {
    this.currentIndex = 0
    this.largeText = false
    this.showStep(0)
  }

  next() {
    if (this.currentIndex < this.stepsCountValue - 1) {
      this.currentIndex++
      this.showStep(this.currentIndex)
    }
  }

  previous() {
    if (this.currentIndex > 0) {
      this.currentIndex--
      this.showStep(this.currentIndex)
    }
  }

  showStep(index) {
    this.stepTargets.forEach((step, i) => {
      step.style.display = i === index ? '' : 'none'
    })

    const total = this.stepsCountValue
    const percent = total > 0 ? ((index + 1) / total) * 100 : 100

    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${percent}%`
    }

    if (this.hasCurrentStepNumberTarget) {
      this.currentStepNumberTarget.textContent = index + 1
    }

    if (this.hasPrevBtnTarget) {
      this.prevBtnTarget.disabled = index === 0
    }

    if (this.hasNextBtnTarget) {
      this.nextBtnTarget.disabled = index === total - 1
    }
  }

  // Toggle a class rather than writing font sizes inline, so the size stays
  // defined in the stylesheet alongside the rest of the cooking-mode type.
  toggleLargeText() {
    this.largeText = !this.largeText
    this.element.classList.toggle('large-text', this.largeText)
  }

  toggleIngredient(event) {
    const item = event.currentTarget
    item.style.textDecoration = item.style.textDecoration === 'line-through' ? '' : 'line-through'
    item.style.opacity = item.style.opacity === '0.5' ? '1' : '0.5'
  }
}
