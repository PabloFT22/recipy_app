import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "card",
    "basicStatus", "basicToggle", "basicBody",
    "timingToggle", "timingBody", "timeDisplay",
    "ingredientsStatus", "ingredientsToggle", "ingredientsBody",
    "quickAddSection", "quickAddTextarea", "ingredientRows", "ingredientRow", "ingredientCount",
    "instructionsStatus", "instructionsToggle", "instructionsBody", "instructionsTextarea",
    "instructionCount", "instructionPreview", "instructionPreviewContent",
    "photoToggle", "photoBody", "imagePreview",
    "sourceToggle", "sourceBody",
    "saveIndicator"
  ]

  // Known units for parsing
  static KNOWN_UNITS = new Set([
    'cups', 'cup', 'c',
    'tablespoons', 'tablespoon', 'tbsp', 'tbs',
    'teaspoons', 'teaspoon', 'tsp',
    'ounces', 'ounce', 'oz',
    'pounds', 'pound', 'lb', 'lbs',
    'grams', 'gram', 'g',
    'kilograms', 'kilogram', 'kg',
    'milliliters', 'milliliter', 'ml',
    'liters', 'liter', 'l',
    'pinch', 'dash',
    'pieces', 'piece', 'pc', 'pcs',
    'whole', 'large', 'medium', 'small',
    'slices', 'slice', 'cloves', 'clove',
    'bunches', 'bunch', 'handfuls', 'handful',
    'cans', 'can', 'bottles', 'bottle',
    'bags', 'bag', 'boxes', 'box',
    'packages', 'package', 'pkg',
    'sticks', 'stick', 'heads', 'head',
    'stalks', 'stalk', 'sprigs', 'sprig',
    'leaves', 'leaf', 'strips', 'strip',
    'spoons', 'spoon', 'to_taste'
  ])

  static UNIT_NORMALIZE = {
    'cup': 'cups', 'c': 'cups',
    'tablespoon': 'tablespoons', 'tbsp': 'tablespoons', 'tbs': 'tablespoons',
    'teaspoon': 'teaspoons', 'tsp': 'teaspoons',
    'ounce': 'ounces', 'oz': 'ounces',
    'pound': 'pounds', 'lb': 'pounds', 'lbs': 'pounds',
    'gram': 'grams', 'g': 'grams',
    'kilogram': 'kilograms', 'kg': 'kilograms',
    'milliliter': 'milliliters', 'ml': 'milliliters',
    'liter': 'liters', 'l': 'liters',
    'piece': 'pieces', 'pc': 'pieces', 'pcs': 'pieces',
    'slice': 'slices', 'clove': 'cloves',
    'bunch': 'bunches', 'handful': 'handfuls',
    'can': 'cans', 'bottle': 'bottles',
    'bag': 'bags', 'box': 'boxes',
    'package': 'packages', 'pkg': 'packages',
    'stick': 'sticks', 'head': 'heads',
    'stalk': 'stalks', 'sprig': 'sprigs',
    'leaf': 'leaves', 'strip': 'strips',
    'spoon': 'spoons'
  }

  connect() {
    console.log("Recipe form controller connected")
    // Detect new vs edit: Rails edit forms include a hidden _method=patch input
    this.isEditForm = !!this.element.querySelector('input[name="_method"][value="patch"]')
    // Only load drafts for new recipe forms, never on edit
    if (!this.isEditForm) {
      this.loadDraft()
      this.setupAutoSave()
      // Clear draft on successful form submission
      this.element.addEventListener('turbo:submit-end', (event) => {
        if (event.detail?.success) {
          localStorage.removeItem('recipe_draft')
        }
      })
    }
    this.updateIngredientCount()
  }

  toggleCard(event) {
    const card = event.currentTarget.closest('.form-card')
    const body = card.querySelector('.card-body')
    const toggle = card.querySelector('.expand-btn')

    if (body.classList.contains('collapsed')) {
      body.classList.remove('collapsed')
      toggle.classList.add('rotated')
    } else {
      body.classList.add('collapsed')
      toggle.classList.remove('rotated')
    }
  }

  updatePreview(event) {
    this.autoSave()
  }

  // ── Hybrid Ingredient System ──────────────────────────────────────

  parseIngredients() {
    const text = this.quickAddTextareaTarget.value
    if (!text.trim()) return

    const lines = text.split('\n').filter(line => line.trim())
    lines.forEach(line => {
      const parsed = this.smartParseIngredientLine(line.trim())
      this.addIngredientRowWithData(parsed)
    })

    this.quickAddTextareaTarget.value = ''
    this.updateIngredientCount()
  }

  // Unicode fraction map
  static UNICODE_FRACTIONS = {
    '¼': 0.25, '½': 0.5, '¾': 0.75,
    '⅓': 0.333, '⅔': 0.667,
    '⅕': 0.2, '⅖': 0.4, '⅗': 0.6, '⅘': 0.8,
    '⅙': 0.167, '⅚': 0.833,
    '⅛': 0.125, '⅜': 0.375, '⅝': 0.625, '⅞': 0.875
  }

  smartParseIngredientLine(line) {
    line = line.replace(/^[-•*]\s*/, '')

    // Convert Unicode fractions to decimals before parsing
    const fracs = this.constructor.UNICODE_FRACTIONS
    const fracChars = Object.keys(fracs).join('')
    const fracPattern = new RegExp(`^(\\d+)?\\s*([${fracChars}])\\s*`)
    const fracMatch = line.match(fracPattern)

    let quantity = ''
    let remaining = line

    if (fracMatch) {
      const whole = fracMatch[1] ? parseFloat(fracMatch[1]) : 0
      const fracVal = fracs[fracMatch[2]]
      quantity = String(Math.round((whole + fracVal) * 1000) / 1000)
      remaining = line.slice(fracMatch[0].length)
    } else {
      // Standard numeric quantity: 2, 2.5, 1 1/2, 1/2
      const qtyPattern = /^(\d+(?:[\.,]\d+)?|\d+\s+\d+\s*\/\s*\d+|\d+\s*\/\s*\d+)\s*/
      const qtyMatch = remaining.match(qtyPattern)

      if (qtyMatch) {
        let raw = qtyMatch[1].replace(',', '.')
        // Convert text fractions like "1 1/2" or "1/2" to decimal
        if (raw.includes('/')) {
          const mixedMatch = raw.match(/^(\d+)\s+(\d+)\s*\/\s*(\d+)$/)
          const simpleMatch = raw.match(/^(\d+)\s*\/\s*(\d+)$/)
          if (mixedMatch) {
            raw = String(parseFloat(mixedMatch[1]) + parseFloat(mixedMatch[2]) / parseFloat(mixedMatch[3]))
          } else if (simpleMatch) {
            raw = String(parseFloat(simpleMatch[1]) / parseFloat(simpleMatch[2]))
          }
        }
        quantity = raw
        remaining = line.slice(qtyMatch[0].length)
      }
    }

    const words = remaining.split(/\s+/)
    let unit = ''
    let name = ''
    let notes = ''

    if (words.length > 0) {
      const possibleUnit = words[0].toLowerCase()
      if (this.constructor.KNOWN_UNITS.has(possibleUnit) && words.length > 1) {
        unit = this.normalizeUnit(possibleUnit)
        const rest = words.slice(1).join(' ')
        const parts = rest.split(',')
        name = parts[0]?.trim() || ''
        notes = parts.slice(1).join(',').trim()
      } else {
        const parts = remaining.split(',')
        name = parts[0]?.trim() || ''
        notes = parts.slice(1).join(',').trim()
      }
    }

    if (!name) name = line

    return { quantity, unit, name, notes }
  }

  normalizeUnit(unit) {
    const lower = unit.toLowerCase()
    return this.constructor.UNIT_NORMALIZE[lower] || lower
  }

  addIngredientRow() {
    this.addIngredientRowWithData({ quantity: '', unit: '', name: '', notes: '' })
    const rows = this.ingredientRowsTarget.querySelectorAll('.ingredient-row')
    const lastRow = rows[rows.length - 1]
    if (lastRow) {
      const nameInput = lastRow.querySelector('.col-name')
      if (nameInput) nameInput.focus()
    }
    this.updateIngredientCount()
  }

  addIngredientRowWithData({ quantity, unit, name, notes }) {
    const row = document.createElement('div')
    row.classList.add('ingredient-row')
    row.setAttribute('data-recipe-form-target', 'ingredientRow')

    const unitOptions = [
      { value: '', label: '—', group: null },
      { value: 'cups', label: 'cups', group: 'Volume' },
      { value: 'tablespoons', label: 'tbsp', group: 'Volume' },
      { value: 'teaspoons', label: 'tsp', group: 'Volume' },
      { value: 'milliliters', label: 'ml', group: 'Volume' },
      { value: 'liters', label: 'liters', group: 'Volume' },
      { value: 'ounces', label: 'oz', group: 'Weight' },
      { value: 'pounds', label: 'lbs', group: 'Weight' },
      { value: 'grams', label: 'grams', group: 'Weight' },
      { value: 'kilograms', label: 'kg', group: 'Weight' },
      { value: 'whole', label: 'whole', group: 'Count' },
      { value: 'pieces', label: 'pieces', group: 'Count' },
      { value: 'large', label: 'large', group: 'Count' },
      { value: 'medium', label: 'medium', group: 'Count' },
      { value: 'small', label: 'small', group: 'Count' },
      { value: 'slices', label: 'slices', group: 'Count' },
      { value: 'cloves', label: 'cloves', group: 'Count' },
      { value: 'pinch', label: 'pinch', group: 'Other' },
      { value: 'dash', label: 'dash', group: 'Other' },
      { value: 'to_taste', label: 'to taste', group: 'Other' },
      { value: 'cans', label: 'cans', group: 'Other' },
      { value: 'bunches', label: 'bunches', group: 'Other' },
      { value: 'handfuls', label: 'handfuls', group: 'Other' },
      { value: 'packages', label: 'packages', group: 'Other' },
      { value: 'sticks', label: 'sticks', group: 'Other' },
      { value: 'spoons', label: 'spoons', group: 'Other' },
    ]

    let selectHtml = '<select name="recipe[ingredients_rows][][unit]" class="form-select col-unit">'
    let currentGroup = null
    unitOptions.forEach(opt => {
      if (opt.group !== currentGroup) {
        if (currentGroup !== null) selectHtml += '</optgroup>'
        if (opt.group) selectHtml += `<optgroup label="${opt.group}">`
        currentGroup = opt.group
      }
      const selected = opt.value === unit ? ' selected' : ''
      selectHtml += `<option value="${opt.value}"${selected}>${opt.label}</option>`
    })
    if (currentGroup) selectHtml += '</optgroup>'
    selectHtml += '</select>'

    row.innerHTML = `
      <input type="number" step="any" min="0"
             name="recipe[ingredients_rows][][quantity]"
             value="${this.escapeAttr(quantity)}"
             placeholder="2"
             class="form-input col-qty">
      ${selectHtml}
      <input type="text"
             name="recipe[ingredients_rows][][name]"
             value="${this.escapeAttr(name)}"
             placeholder="e.g., flour"
             class="form-input col-name">
      <input type="text"
             name="recipe[ingredients_rows][][notes]"
             value="${this.escapeAttr(notes)}"
             placeholder="optional"
             class="form-input col-notes">
      <button type="button" class="btn-remove-row" data-action="click->recipe-form#removeIngredientRow" title="Remove">✕</button>
    `

    this.ingredientRowsTarget.appendChild(row)
  }

  removeIngredientRow(event) {
    const row = event.currentTarget.closest('.ingredient-row')
    row.style.opacity = '0'
    row.style.transform = 'translateX(20px)'
    setTimeout(() => {
      row.remove()
      this.updateIngredientCount()
    }, 200)
  }

  updateIngredientCount() {
    const count = this.ingredientRowsTarget.querySelectorAll('.ingredient-row').length
    if (this.hasIngredientCountTarget) {
      this.ingredientCountTarget.innerHTML = `<p class="helper-text">${count} ${count === 1 ? 'ingredient' : 'ingredients'}</p>`
    }
  }

  escapeAttr(str) {
    if (!str) return ''
    return String(str).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  }

  // ── Instructions ──────────────────────────────────────────────────

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

    const steps = text.split(/\n\n+/).filter(step => step.trim())
    if (steps.length === 0) {
      this.instructionPreviewTarget.style.display = 'none'
      return
    }

    let html = '<div class="preview-steps-list">'
    steps.forEach((step, index) => {
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

  // ── Image Preview ─────────────────────────────────────────────────

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

  // ── Draft Save / Load ─────────────────────────────────────────────

  saveDraft() {
    // Don't save drafts when editing an existing recipe
    if (this.isEditForm) return

    const form = this.element.closest('form') || this.element
    if (!form) return

    const formData = new FormData(form)
    const draft = {
      title: formData.get('recipe[title]'),
      description: formData.get('recipe[description]'),
      difficulty: formData.get('recipe[difficulty]'),
      servings: formData.get('recipe[servings]'),
      prep_time: formData.get('recipe[prep_time]'),
      cook_time: formData.get('recipe[cook_time]'),
      instructions: formData.get('recipe[instructions]'),
      source_url: formData.get('recipe[source_url]'),
      is_public: formData.get('recipe[is_public]'),
      saved_at: new Date().toISOString()
    }

    const rows = this.ingredientRowsTarget.querySelectorAll('.ingredient-row')
    draft.ingredients = Array.from(rows).map(row => ({
      quantity: row.querySelector('.col-qty')?.value || '',
      unit: row.querySelector('.col-unit')?.value || '',
      name: row.querySelector('.col-name')?.value || '',
      notes: row.querySelector('.col-notes')?.value || ''
    }))

    localStorage.setItem('recipe_draft', JSON.stringify(draft))
    this.showSaveIndicator()
  }

  loadDraft() {
    const draft = localStorage.getItem('recipe_draft')
    if (!draft) return

    try {
      const data = JSON.parse(draft)
      const form = this.element.closest('form') || this.element

      if (data.title) form.querySelector('[name="recipe[title]"]').value = data.title
      if (data.description) form.querySelector('[name="recipe[description]"]').value = data.description
      if (data.difficulty) form.querySelector('[name="recipe[difficulty]"]').value = data.difficulty
      if (data.servings) form.querySelector('[name="recipe[servings]"]').value = data.servings
      if (data.prep_time) form.querySelector('[name="recipe[prep_time]"]').value = data.prep_time
      if (data.cook_time) form.querySelector('[name="recipe[cook_time]"]').value = data.cook_time
      if (data.instructions) {
        const textarea = form.querySelector('[name="recipe[instructions]"]')
        if (textarea) {
          textarea.value = data.instructions
          textarea.dispatchEvent(new Event('input'))
        }
      }
      if (data.source_url) form.querySelector('[name="recipe[source_url]"]').value = data.source_url

      if (data.ingredients && data.ingredients.length > 0) {
        // Only add draft ingredients if no rows already exist (avoid duplication)
        const existingRows = this.ingredientRowsTarget.querySelectorAll('.ingredient-row')
        if (existingRows.length === 0) {
          data.ingredients.forEach(ing => {
            if (ing.name) this.addIngredientRowWithData(ing)
          })
          this.updateIngredientCount()
        }
      }

      console.log('Draft loaded from', data.saved_at)
    } catch (e) {
      console.error('Error loading draft:', e)
    }
  }

  setupAutoSave() {
    this.autoSaveInterval = setInterval(() => {
      this.autoSave()
    }, 30000)
  }

  autoSave() {
    if (this.autoSaveTimeout) clearTimeout(this.autoSaveTimeout)
    this.autoSaveTimeout = setTimeout(() => {
      this.saveDraft()
    }, 2000)
  }

  showSaveIndicator() {
    if (this.hasSaveIndicatorTarget) {
      this.saveIndicatorTarget.classList.add('visible')
      setTimeout(() => {
        this.saveIndicatorTarget.classList.remove('visible')
      }, 2000)
    }
  }

  disconnect() {
    if (this.autoSaveInterval) clearInterval(this.autoSaveInterval)
    if (this.autoSaveTimeout) clearTimeout(this.autoSaveTimeout)
  }
}
