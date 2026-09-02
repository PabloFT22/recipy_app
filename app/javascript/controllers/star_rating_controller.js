import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "stars"]
  static values = { value: Number }

  connect() {
    this.updateStars(this.valueValue)
  }

  select(event) {
    const value = parseInt(event.currentTarget.dataset.value)
    this.valueValue = value
    this.inputTarget.value = value
    this.updateStars(value)
  }

  hover(event) {
    const value = parseInt(event.currentTarget.dataset.value)
    this.highlightStars(value)
  }

  unhover() {
    this.updateStars(this.valueValue)
  }

  updateStars(value) {
    this.element.querySelectorAll('.star-btn').forEach((star, idx) => {
      star.classList.toggle('selected', idx < value)
    })
  }

  highlightStars(value) {
    this.element.querySelectorAll('.star-btn').forEach((star, idx) => {
      star.classList.toggle('hovered', idx < value)
    })
  }
}
