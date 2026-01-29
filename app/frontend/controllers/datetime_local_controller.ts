import { Controller } from "@hotwired/stimulus"

/**
 * Reusable datetime display controller for timezone conversion
 *
 * Converts UTC datetime to user's local timezone for display.
 *
 * Usage:
 *   <span data-controller="datetime-local"
 *         data-datetime-local-utc-value="2025-01-29T10:00:00Z"
 *         data-datetime-local-format-value="datetime">
 *     2025-01-29 19:00 <%# Server-side fallback %>
 *   </span>
 *
 * Format options:
 *   - "datetime" (default): "2025/01/29 19:00"
 *   - "date": "2025/01/29"
 *   - "time": "19:00"
 *   - "full": "2025年01月29日 19:00"
 */
export default class extends Controller {
  static values = {
    utc: String,
    format: { type: String, default: "datetime" },
  }

  declare utcValue: string
  declare formatValue: string
  declare hasUtcValue: boolean

  connect() {
    if (!this.hasUtcValue || !this.utcValue) return

    const utcDate = new Date(this.utcValue)
    if (isNaN(utcDate.getTime())) return

    this.element.textContent = this.formatDatetime(utcDate)
  }

  private formatDatetime(date: Date): string {
    const pad = (n: number) => String(n).padStart(2, "0")
    const year = date.getFullYear()
    const month = pad(date.getMonth() + 1)
    const day = pad(date.getDate())
    const hours = pad(date.getHours())
    const minutes = pad(date.getMinutes())

    switch (this.formatValue) {
      case "date":
        return `${year}/${month}/${day}`
      case "time":
        return `${hours}:${minutes}`
      case "full":
        return `${year}年${month}月${day}日 ${hours}:${minutes}`
      case "datetime":
      default:
        return `${year}/${month}/${day} ${hours}:${minutes}`
    }
  }
}
