import { Controller } from "@hotwired/stimulus"
import DatetimeLocalController from "./datetime_local_controller"

/**
 * Publication Date controller for standalone save functionality
 *
 * Usage:
 *   <div data-controller="publication-date"
 *        data-publication-date-save-url-value="/path/to/save"
 *        data-publication-date-standalone-value="true"
 *        data-publication-date-datetime-local-outlet="[data-controller='datetime-local']">
 *     <input data-controller="datetime-local"
 *            data-publication-date-target="input">
 *     <button data-publication-date-target="saveButton">保存</button>
 *   </div>
 */
export default class extends Controller {
  static targets = ["input", "saveButton"]
  static outlets = ["datetime-local"]
  static values = {
    saveUrl: String,
    standalone: Boolean,
  }

  declare inputTarget: HTMLInputElement
  declare saveButtonTarget: HTMLButtonElement
  declare hasSaveButtonTarget: boolean
  declare saveUrlValue: string
  declare standaloneValue: boolean
  declare datetimeLocalOutlet: DatetimeLocalController
  declare hasDatetimeLocalOutlet: boolean

  private originalValue: string = ""

  connect() {
    this.originalValue = this.inputTarget.value
  }

  onChange() {
    if (!this.standaloneValue || !this.hasSaveButtonTarget) return

    const hasChanged = this.inputTarget.value !== this.originalValue
    this.saveButtonTarget.disabled = !hasChanged
  }

  async save() {
    if (!this.saveUrlValue) return

    const value = this.inputTarget.value
    if (!value) return

    // Use datetime-local outlet to convert local → UTC
    const utcIso = this.hasDatetimeLocalOutlet
      ? this.datetimeLocalOutlet.toUtcIso()
      : new Date(value).toISOString() // fallback

    if (!utcIso) return

    try {
      this.saveButtonTarget.disabled = true
      this.saveButtonTarget.textContent = "保存中..."

      const response = await fetch(this.saveUrlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken,
        },
        body: JSON.stringify({ custom_published_at: utcIso }),
      })

      if (response.ok) {
        this.originalValue = value
        this.saveButtonTarget.textContent = "保存済み"
        setTimeout(() => {
          this.saveButtonTarget.textContent = "保存"
        }, 2000)
      } else {
        throw new Error("Save failed")
      }
    } catch (error) {
      console.error("Failed to save publication date:", error)
      this.saveButtonTarget.textContent = "保存"
      this.saveButtonTarget.disabled = false
    }
  }

  private get csrfToken(): string {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta?.getAttribute("content") || ""
  }
}
