import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["datetimeInput", "scheduleForm", "scheduledInfo", "message"]
  static values = {
    url: String,
  }

  declare datetimeInputTarget: HTMLInputElement
  declare scheduleFormTarget: HTMLElement
  declare scheduledInfoTarget: HTMLElement
  declare messageTarget: HTMLElement
  declare urlValue: string
  declare hasDatetimeInputTarget: boolean
  declare hasScheduleFormTarget: boolean
  declare hasScheduledInfoTarget: boolean

  async schedule(event: Event) {
    event.preventDefault()

    if (!this.hasDatetimeInputTarget) return

    const scheduledAt = this.datetimeInputTarget.value
    if (!scheduledAt) {
      this.showMessage("日時を入力してください", "error")
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
        body: JSON.stringify({ scheduled_at: scheduledAt }),
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
}
