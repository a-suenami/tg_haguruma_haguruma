import { Controller } from "@hotwired/stimulus"
import DatetimeLocalController from "./datetime_local_controller"

/**
 * Scheduled publication controller with timezone handling
 *
 * Uses datetime-local controller outlet for timezone conversion:
 * - Display: datetime-local controller converts UTC to local on connect
 * - Submit: Uses datetimeLocalOutlet.toUtcIso() for local → UTC conversion
 */
export default class extends Controller {
  static targets = [
    "datetimeInput",
    "scheduleForm",
    "scheduledInfo",
    "scheduledDatetime",
    "message",
  ]
  static outlets = ["datetime-local"]
  static values = {
    url: String,
    utc: String, // UTC datetime string for scheduled time (for display controller)
  }

  declare datetimeInputTarget: HTMLInputElement
  declare scheduleFormTarget: HTMLElement
  declare scheduledInfoTarget: HTMLElement
  declare scheduledDatetimeTarget: HTMLElement
  declare messageTarget: HTMLElement
  declare urlValue: string
  declare utcValue: string
  declare hasDatetimeInputTarget: boolean
  declare hasScheduleFormTarget: boolean
  declare hasScheduledInfoTarget: boolean
  declare hasScheduledDatetimeTarget: boolean
  declare hasUtcValue: boolean
  declare datetimeLocalOutlet: DatetimeLocalController
  declare hasDatetimeLocalOutlet: boolean

  connect() {
    // Set min attribute to current local time
    if (this.hasDatetimeInputTarget) {
      this.datetimeInputTarget.min = this.toDatetimeLocalString(new Date())
    }
  }

  async schedule(event: Event) {
    event.preventDefault()

    if (!this.hasDatetimeInputTarget) return

    const localValue = this.datetimeInputTarget.value
    if (!localValue) {
      this.showMessage("日時を入力してください", "error")
      return
    }

    // Use datetime-local outlet to convert local → UTC
    const utcIso = this.hasDatetimeLocalOutlet
      ? this.datetimeLocalOutlet.toUtcIso()
      : new Date(localValue).toISOString() // fallback

    if (!utcIso) {
      this.showMessage("無効な日時です", "error")
      return
    }

    const url = (event.currentTarget as HTMLElement).dataset
      .scheduledPublicationUrlValue
    if (!url) return

    try {
      const csrfToken = document.querySelector<HTMLMetaElement>(
        'meta[name="csrf-token"]'
      )?.content

      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken || "",
        },
        body: JSON.stringify({ scheduled_at: utcIso }),
      })

      const data = await response.json()

      if (response.ok && data.success) {
        this.showMessage(data.message, "success")
        // Reload to show updated state
        setTimeout(() => window.location.reload(), 1000)
      } else {
        this.showMessage(data.error || "エラーが発生しました", "error")
      }
    } catch {
      this.showMessage("エラーが発生しました", "error")
    }
  }

  async cancel(event: Event) {
    event.preventDefault()

    if (!confirm("公開予約を解除しますか？")) return

    const url = (event.currentTarget as HTMLElement).dataset
      .scheduledPublicationUrlValue
    if (!url) return

    try {
      const csrfToken = document.querySelector<HTMLMetaElement>(
        'meta[name="csrf-token"]'
      )?.content

      const response = await fetch(url, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken || "",
        },
      })

      const data = await response.json()

      if (response.ok && data.success) {
        this.showMessage(data.message, "success")
        // Reload to show updated state
        setTimeout(() => window.location.reload(), 1000)
      } else {
        this.showMessage(data.error || "エラーが発生しました", "error")
      }
    } catch {
      this.showMessage("エラーが発生しました", "error")
    }
  }

  private showMessage(text: string, type: "success" | "error") {
    this.messageTarget.textContent = text
    this.messageTarget.className = `schedule-message-inline ${type}`
    this.messageTarget.style.display = "block"

    if (type === "success") {
      setTimeout(() => {
        this.messageTarget.style.display = "none"
      }, 3000)
    }
  }

  // Format Date to datetime-local input value (YYYY-MM-DDTHH:MM) in local timezone
  // Used for setting min attribute on input
  private toDatetimeLocalString(date: Date): string {
    const pad = (n: number) => String(n).padStart(2, "0")
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`
  }
}
