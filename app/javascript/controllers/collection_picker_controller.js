import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown"]

  connect() {
    this.closeOnOutsideClick = this.closeOnOutsideClick.bind(this)
    this.closeOnEscape = this.closeOnEscape.bind(this)
  }

  toggle(event) {
    this.trigger = event.currentTarget
    this.dropdownTarget.hidden ? this.open() : this.close()
  }

  open() {
    this.dropdownTarget.hidden = false
    this.trigger?.setAttribute("aria-expanded", "true")

    // Delay adding the listener so the current click doesn't immediately close it
    setTimeout(() => {
      document.addEventListener("click", this.closeOnOutsideClick)
      document.addEventListener("keydown", this.closeOnEscape)
    }, 0)
  }

  close() {
    this.dropdownTarget.hidden = true
    this.trigger?.setAttribute("aria-expanded", "false")
    document.removeEventListener("click", this.closeOnOutsideClick)
    document.removeEventListener("keydown", this.closeOnEscape)
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
      this.trigger?.focus()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
    document.removeEventListener("keydown", this.closeOnEscape)
  }
}
