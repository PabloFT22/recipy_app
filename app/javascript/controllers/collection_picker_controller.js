import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown"]

  connect() {
    this.closeOnOutsideClick = this.closeOnOutsideClick.bind(this)
  }

  toggle() {
    if (this.dropdownTarget.style.display === "none") {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.dropdownTarget.style.display = "block"
    // Delay adding the listener so the current click doesn't immediately close it
    setTimeout(() => {
      document.addEventListener("click", this.closeOnOutsideClick)
    }, 0)
  }

  close() {
    this.dropdownTarget.style.display = "none"
    document.removeEventListener("click", this.closeOnOutsideClick)
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
  }
}
