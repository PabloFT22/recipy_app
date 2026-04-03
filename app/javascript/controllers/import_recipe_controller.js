import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["urlInput", "submitButton", "loading"]

  submit() {
    const url = this.urlInputTarget.value.trim()

    if (!url) {
      return
    }

    // Show loading state
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.value = "Importing…"
    this.loadingTarget.classList.remove("hidden")
  }
}
