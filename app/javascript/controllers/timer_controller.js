import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]

  connect() {
    this.totalSeconds = 0
    this.remaining = 0
    this.interval = null
    this.running = false
  }

  disconnect() {
    this.stop()
  }

  toggle() {
    if (this.running) {
      this.pause()
    } else {
      this.start()
    }
  }

  start() {
    if (this.remaining === 0 && this.totalSeconds === 0) return
    if (this.remaining === 0) this.remaining = this.totalSeconds

    this.running = true
    this.interval = setInterval(() => {
      this.remaining--
      this.updateDisplay()
      if (this.remaining <= 0) {
        this.stop()
        this.ring()
      }
    }, 1000)
    this.updateButtonText('Pause')
  }

  pause() {
    this.running = false
    clearInterval(this.interval)
    this.updateButtonText('Resume')
  }

  stop() {
    this.running = false
    clearInterval(this.interval)
    this.interval = null
  }

  reset() {
    this.stop()
    this.remaining = this.totalSeconds
    this.updateDisplay()
    this.updateButtonText('Start Timer')
  }

  startFromStep(event) {
    const text = event.currentTarget.dataset.timerText
    const minutes = this.parseMinutes(text)
    if (minutes > 0) {
      this.totalSeconds = minutes * 60
      this.remaining = this.totalSeconds
      this.updateDisplay()
      this.start()
    }
  }

  parseMinutes(text) {
    const hourMatch = text.match(/(\d+)\s*hour/i)
    const minMatch = text.match(/(\d+)\s*min/i)
    let total = 0
    if (hourMatch) total += parseInt(hourMatch[1]) * 60
    if (minMatch) total += parseInt(minMatch[1])
    return total
  }

  updateDisplay() {
    const mins = Math.floor(this.remaining / 60)
    const secs = this.remaining % 60
    const display = `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = display
    }
  }

  updateButtonText(text) {
    const btn = this.element.querySelector('[data-action*="timer#toggle"]')
    if (btn) btn.textContent = text
  }

  ring() {
    if (typeof Notification === 'undefined') {
      alert('Timer finished!')
      return
    }

    if (Notification.permission === 'granted') {
      new Notification('Timer Done!', { body: 'Your cooking timer has finished.' })
    } else if (Notification.permission !== 'denied') {
      Notification.requestPermission().then(permission => {
        if (permission === 'granted') {
          new Notification('Timer Done!', { body: 'Your cooking timer has finished.' })
        } else {
          alert('Timer finished!')
        }
      })
    } else {
      alert('Timer finished!')
    }
  }
}
