import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hiddenField", "tagList", "suggestions"]

  connect() {
    this.tags = []
    this._debounceTimer = null
    this._boundCloseOnOutsideClick = this.closeOnOutsideClick.bind(this)
    document.addEventListener("click", this._boundCloseOnOutsideClick)

    // Parse existing tags from hidden field
    const existing = this.hiddenFieldTarget.value
    if (existing.trim() !== "") {
      existing.split(",").forEach(name => {
        const trimmed = name.trim()
        if (trimmed !== "") {
          this.tags.push(trimmed)
        }
      })
    }
    this.renderTags()
  }

  disconnect() {
    document.removeEventListener("click", this._boundCloseOnOutsideClick)
  }

  suggest() {
    clearTimeout(this._debounceTimer)
    const query = this.inputTarget.value.trim()

    if (query.length === 0) {
      this.hideSuggestions()
      return
    }

    this._debounceTimer = setTimeout(() => {
      fetch(`/tags/search?q=${encodeURIComponent(query)}`, {
        headers: { "Accept": "application/json" }
      })
        .then(response => response.json())
        .then(data => {
          this.showSuggestions(data)
        })
        .catch(() => {
          this.hideSuggestions()
        })
    }, 200)
  }

  handleKeydown(event) {
    if (event.key === "Enter" || event.key === ",") {
      event.preventDefault()
      this.addCurrentInput()
    }
  }

  addCurrentInput() {
    const value = this.inputTarget.value.replace(/,/g, "").trim().toLowerCase()
    if (value === "") return
    if (this.tags.includes(value)) {
      this.inputTarget.value = ""
      this.hideSuggestions()
      return
    }

    this.tags.push(value)
    this.updateHiddenField()
    this.renderTags()
    this.inputTarget.value = ""
    this.hideSuggestions()
  }

  selectSuggestion(event) {
    const name = event.currentTarget.dataset.tagName
    if (name && !this.tags.includes(name)) {
      this.tags.push(name)
      this.updateHiddenField()
      this.renderTags()
    }
    this.inputTarget.value = ""
    this.hideSuggestions()
    this.inputTarget.focus()
  }

  removeTag(event) {
    const name = event.currentTarget.dataset.tagName
    this.tags = this.tags.filter(t => t !== name)
    this.updateHiddenField()
    this.renderTags()
  }

  // Private helpers

  updateHiddenField() {
    this.hiddenFieldTarget.value = this.tags.join(", ")
  }

  renderTags() {
    this.tagListTarget.innerHTML = ""
    this.tags.forEach(name => {
      const pill = document.createElement("span")
      pill.className = "tag-input-pill"
      pill.innerHTML = `
        ${this.escapeHtml(name)}
        <button type="button" class="tag-remove" data-action="click->tag-input#removeTag" data-tag-name="${this.escapeHtml(name)}">✕</button>
      `
      this.tagListTarget.appendChild(pill)
    })
  }

  showSuggestions(data) {
    const filtered = data.filter(t => !this.tags.includes(t.name))
    if (filtered.length === 0) {
      this.hideSuggestions()
      return
    }

    this.suggestionsTarget.innerHTML = ""
    filtered.forEach(tag => {
      const item = document.createElement("div")
      item.className = "tag-suggestion-item"
      item.dataset.tagName = tag.name
      item.dataset.action = "click->tag-input#selectSuggestion"
      item.textContent = tag.name
      this.suggestionsTarget.appendChild(item)
    })
    this.suggestionsTarget.style.display = "block"
  }

  hideSuggestions() {
    this.suggestionsTarget.style.display = "none"
    this.suggestionsTarget.innerHTML = ""
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.hideSuggestions()
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
