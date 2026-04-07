import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "hamburger"]

  connect() {
    // Close menu on escape key
    this.handleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.handleEscape)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleEscape)
  }

  toggle() {
    const isOpen = this.menuTarget.classList.contains("navbar-menu--open")
    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.add("navbar-menu--open")
    this.hamburgerTarget.classList.add("navbar-hamburger--active")
    this.hamburgerTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    this.menuTarget.classList.remove("navbar-menu--open")
    this.hamburgerTarget.classList.remove("navbar-hamburger--active")
    this.hamburgerTarget.setAttribute("aria-expanded", "false")
  }

  // Close menu when a nav link is clicked
  closeFromLink() {
    this.close()
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
