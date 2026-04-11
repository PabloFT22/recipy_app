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
    const percent = total > 1 ? (index / (total - 1)) * 100 : 100

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

  toggleLargeText() {
    this.largeText = !this.largeText
    const fontSize = this.largeText ? '1.75rem' : '1.25rem'
    this.stepTargets.forEach(step => {
      const textEl = step.querySelector('[data-cooking-mode-target="stepText"]')
      if (textEl) textEl.style.fontSize = fontSize
    })
  }

  toggleIngredient(event) {
    const item = event.currentTarget
    item.style.textDecoration = item.style.textDecoration === 'line-through' ? '' : 'line-through'
    item.style.opacity = item.style.opacity === '0.5' ? '1' : '0.5'
  }
}
