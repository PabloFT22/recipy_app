import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner"]

  connect() {
    this.deferredPrompt = null
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault()
      this.deferredPrompt = e
      this.showBanner()
    })
  }

  showBanner() {
    if (this.hasBannerTarget) {
      this.bannerTarget.style.display = 'block'
    }
  }

  async install() {
    if (!this.deferredPrompt) return
    this.deferredPrompt.prompt()
    const { outcome } = await this.deferredPrompt.userChoice
    this.deferredPrompt = null
    if (this.hasBannerTarget) {
      this.bannerTarget.style.display = 'none'
    }
  }

  dismiss() {
    if (this.hasBannerTarget) {
      this.bannerTarget.style.display = 'none'
    }
  }
}
