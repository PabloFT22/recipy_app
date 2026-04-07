import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  static values = { delay: { type: Number, default: 4000 } }

  connect() {
    // Auto-dismiss after delay
    this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.add("alert-dismissing")
    // Remove from DOM after the CSS transition ends
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
    // Fallback removal in case transitionend doesn't fire
    setTimeout(() => this.element.remove(), 500)
  }
}
