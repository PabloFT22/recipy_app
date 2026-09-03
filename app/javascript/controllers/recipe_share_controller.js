import { Controller } from "@hotwired/stimulus"

// Print / share actions for the recipe show page.
// Replaces the inline onclick handlers these buttons used to carry.
export default class extends Controller {
  static values = { title: String }

  print() {
    window.print()
  }

  async share(event) {
    const url = window.location.href
    const title = this.titleValue || document.title

    if (navigator.share) {
      try {
        await navigator.share({ title, url })
        return
      } catch (error) {
        // The user dismissed the share sheet — nothing to do.
        if (error.name === "AbortError") return
      }
    }

    if (navigator.clipboard) {
      try {
        await navigator.clipboard.writeText(url)
        this.confirm(event.currentTarget, "Link copied")
        return
      } catch (error) {
        // Clipboard unavailable (insecure context, permissions) — fall through.
      }
    }

    window.prompt("Copy this recipe's link:", url)
  }

  // Briefly swap the button label so the copy actually feels like it happened.
  confirm(button, message) {
    if (!button) return

    const original = button.innerHTML
    button.textContent = message
    button.disabled = true

    setTimeout(() => {
      button.innerHTML = original
      button.disabled = false
    }, 1800)
  }
}
