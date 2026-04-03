import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "card", "basicBody", "basicToggle", "basicStatus",
    "timingBody", "timingToggle",
    "ingredientsBody", "ingredientsToggle", "ingredientsStatus", "ingredientPreview", "ingredientList",
    "instructionsBody", "instructionsToggle", "instructionsStatus", "instructionCount", 
    "instructionsTextarea", "instructionPreview", "instructionPreviewContent",
    "photoBody", "photoToggle", "imagePreview",
    "sourceBody", "sourceToggle",
    "timeDisplay", "saveIndicator"
  ]

  connect() {
    console.log("Recipe form controller connected")
    this.loadDraft()
    this.setupAutoSave()
  }

  toggleCard(event) {
    const card = event.currentTarget.closest('.form-card')
    const cardType = card.dataset.card
    const body = card.querySelector('.card-body')
    const toggle = card.querySelector('.expand-btn')
    
    if (body.classList.contains('collapsed')) {
      // Expand
      body.classList.remove('collapsed')
      toggle.classList.add('rotated')
    } else {
      // Collapse
      body.classList.add('collapsed')
      toggle.classList.remove('rotated')
    }
  }

  updatePreview(event) {
    // Could add live preview functionality here
    this.autoSave()
  }

  updateIngredientPreview(event) {
    const text = event.target.value
    if (!text.trim()) {
      this.ingredientListTarget.innerHTML = '<p class="text-muted">Start typing to see parsed ingredients...</p>'
      return
    }

    const lines = text.split('\n').filter(line => line.trim())
    let html = '<ul class="parsed-ingredients">'
    
    lines.forEach(line => {
      const parsed = this.parseIngredientLine(line)
      html += `<li>
        <span class="quantity">${parsed.quantity || ''}</span>
        <span class="unit">${parsed.unit || ''}</span>
        <span class="ingredient">${parsed.name}</span>
        ${parsed.notes ? `<span class="notes">(${parsed.notes})</span>` : ''}
      </li>`
    })
    
    html += '</ul>'
    this.ingredientListTarget.innerHTML = html
    this.autoSave()
  }

  parseIngredientLine(line) {
    // Simple client-side parsing (matches server logic)
    const pattern = /^(\d+(?:[\.,]\d+)?|\d+\s*\/\s*\d+|\d+\s+\d+\s*\/\s*\d+)?\s*([a-zA-Z]+)?\s+(.+)$/
    const match = line.trim().match(pattern)
    
    if (!match) {
      return { name: line.trim() }
    }

    const [, quantity, unit, rest] = match
    const parts = rest.split(',')
    const name = parts[0].trim()
    const notes = parts[1]?.trim()

    return { quantity, unit, name, notes }
  }

  updateInstructionCount(event) {
    const text = event.target.value
    const steps = text.split('\n\n').filter(step => step.trim()).length
    this.instructionCountTarget.innerHTML = `<p class="helper-text">${steps} ${steps === 1 ? 'step' : 'steps'}</p>`
    this.autoSave()
  }

  updateInstructionPreview(event) {
    const text = event.target.value
    
    if (!text.trim()) {
      this.instructionPreviewTarget.style.display = 'none'
      return
    }

    // Split by double line breaks and remove any manual numbering
    const steps = text.split(/\n\n+/).filter(step => step.trim())
    
    if (steps.length === 0) {
      this.instructionPreviewTarget.style.display = 'none'
      return
    }

    let html = '<div class="preview-steps-list">'
    steps.forEach((step, index) => {
      // Remove leading numbers like "1.", "2)", "Step 1:", etc.
      const cleanedStep = step.replace(/^\d+[\.\)]\s*|^Step\s+\d+:?\s*/i, '').trim()
      html += `
        <div class="preview-step">
          <div class="preview-step-number">${index + 1}</div>
          <div class="preview-step-text">${this.escapeHtml(cleanedStep)}</div>
        </div>
      `
    })
    html += '</div>'

    this.instructionPreviewContentTarget.innerHTML = html
    this.instructionPreviewTarget.style.display = 'block'
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML.replace(/\n/g, '<br>')
  }

  previewImage(event) {
    const file = event.target.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      this.imagePreviewTarget.innerHTML = `
        <img src="${e.target.result}" alt="Recipe preview" style="max-width: 100%; border-radius: 8px;">
        <p class="text-success" style="margin-top: 10px;">✓ Image selected</p>
      `
    }
    reader.readAsDataURL(file)
  }

  saveDraft() {
    const formData = new FormData(this.element.querySelector('form'))
    const draft = {
      title: formData.get('recipe[title]'),
      description: formData.get('recipe[description]'),
      difficulty: formData.get('recipe[difficulty]'),
      servings: formData.get('recipe[servings]'),
      prep_time: formData.get('recipe[prep_time]'),
      cook_time: formData.get('recipe[cook_time]'),
      ingredients_text: formData.get('recipe[ingredients_text]'),
      instructions: formData.get('recipe[instructions]'),
      source_url: formData.get('recipe[source_url]'),
      is_public: formData.get('recipe[is_public]'),
      saved_at: new Date().toISOString()
    }

    localStorage.setItem('recipe_draft', JSON.stringify(draft))
    this.showSaveIndicator()
  }

  loadDraft() {
    const draft = localStorage.getItem('recipe_draft')
    if (!draft) return

    try {
      const data = JSON.parse(draft)
      const form = this.element.querySelector('form')
      
      if (data.title) form.querySelector('[name="recipe[title]"]').value = data.title
      if (data.description) form.querySelector('[name="recipe[description]"]').value = data.description
      if (data.difficulty) form.querySelector('[name="recipe[difficulty]"]').value = data.difficulty
      if (data.servings) form.querySelector('[name="recipe[servings]"]').value = data.servings
      if (data.prep_time) form.querySelector('[name="recipe[prep_time]"]').value = data.prep_time
      if (data.cook_time) form.querySelector('[name="recipe[cook_time]"]').value = data.cook_time
      if (data.ingredients_text) {
        const textarea = form.querySelector('[name="recipe[ingredients_text]"]')
        textarea.value = data.ingredients_text
        // Trigger preview update
        textarea.dispatchEvent(new Event('input'))
      }
      if (data.instructions) {
        const textarea = form.querySelector('[name="recipe[instructions]"]')
        textarea.value = data.instructions
        textarea.dispatchEvent(new Event('input'))
      }
      if (data.source_url) form.querySelector('[name="recipe[source_url]"]').value = data.source_url

      console.log('Draft loaded from', data.saved_at)
    } catch (e) {
      console.error('Error loading draft:', e)
    }
  }

  setupAutoSave() {
    // Auto-save every 30 seconds
    this.autoSaveInterval = setInterval(() => {
      this.autoSave()
    }, 30000)
  }

  autoSave() {
    if (this.autoSaveTimeout) {
      clearTimeout(this.autoSaveTimeout)
    }

    this.autoSaveTimeout = setTimeout(() => {
      this.saveDraft()
    }, 2000) // Debounce for 2 seconds
  }

  showSaveIndicator() {
    this.saveIndicatorTarget.classList.add('visible')
    setTimeout(() => {
      this.saveIndicatorTarget.classList.remove('visible')
    }, 2000)
  }

  disconnect() {
    if (this.autoSaveInterval) {
      clearInterval(this.autoSaveInterval)
    }
    if (this.autoSaveTimeout) {
      clearTimeout(this.autoSaveTimeout)
    }
  }
}
