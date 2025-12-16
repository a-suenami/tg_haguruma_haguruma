import { Controller } from "@hotwired/stimulus"

interface Tag {
  id: string
  name: string
}

export default class extends Controller {
  static targets = [
    "input",
    "dropdown",
    "selectedTags",
    "hiddenInput",
    "tagSelector",
    "visibilityRadio",
    "saveButton",
    "inputWrapper",
  ]
  static values = {
    tags: Array,
    selected: String,
    saveUrl: String,
    standalone: Boolean,
    visibility: String,
  }

  declare inputTarget: HTMLInputElement
  declare dropdownTarget: HTMLElement
  declare selectedTagsTarget: HTMLElement
  declare hiddenInputTarget: HTMLInputElement
  declare tagSelectorTarget: HTMLElement
  declare visibilityRadioTargets: HTMLInputElement[]
  declare saveButtonTarget: HTMLButtonElement
  declare inputWrapperTarget: HTMLElement
  declare tagsValue: Tag[]
  declare selectedValue: string
  declare saveUrlValue: string
  declare standaloneValue: boolean
  declare visibilityValue: string
  declare hasTagSelectorTarget: boolean
  declare hasInputTarget: boolean
  declare hasSaveButtonTarget: boolean
  declare hasInputWrapperTarget: boolean
  declare hasVisibilityRadioTarget: boolean

  private isDirty = false

  connect() {
    this.renderSelectedTag()
    this.updateTagSelectorVisibility()
  }

  onInput() {
    if (!this.hasInputTarget) return
    const query = this.inputTarget.value.toLowerCase().trim()
    this.showFilteredTags(query)
  }

  onFocus() {
    if (!this.hasInputTarget) return
    const query = this.inputTarget.value.toLowerCase().trim()
    this.showFilteredTags(query)
  }

  onBlur(event: FocusEvent) {
    const relatedTarget = event.relatedTarget as HTMLElement
    if (relatedTarget?.closest('[data-authorization-tags-target="dropdown"]')) {
      return
    }
    setTimeout(() => this.hideDropdown(), 150)
  }

  onWrapperClick(event: Event) {
    const target = event.target as HTMLElement
    if (target.closest(".authorization-tag-pill-remove")) {
      return
    }
    if (this.hasInputTarget) {
      this.inputTarget.focus()
    }
  }

  private showFilteredTags(query: string) {
    // Don't show dropdown if a tag is already selected
    if (this.selectedValue) {
      this.hideDropdown()
      return
    }

    const availableTags = this.tagsValue.filter(
      (tag) => query === "" || tag.name.toLowerCase().includes(query)
    )

    const tagsToShow = availableTags.slice(0, 5)

    if (tagsToShow.length === 0) {
      this.hideDropdown()
      return
    }

    this.showDropdown(tagsToShow)
  }

  selectTag(event: Event) {
    const button = event.currentTarget as HTMLElement
    const tagId = button.dataset.tagId
    if (!tagId) return

    this.selectedValue = tagId
    this.renderSelectedTag()
    this.markDirty()

    if (this.hasInputTarget) {
      this.inputTarget.value = ""
    }
    this.hideDropdown()
  }

  removeTag(event: Event) {
    event.stopPropagation()
    this.selectedValue = ""
    this.renderSelectedTag()
    this.markDirty()
    if (this.hasInputTarget) {
      this.inputTarget.focus()
    }
  }

  onVisibilityChange() {
    const selectedRadio = this.visibilityRadioTargets.find((r) => r.checked)
    if (selectedRadio) {
      this.visibilityValue = selectedRadio.value
    }
    this.updateTagSelectorVisibility()
    this.markDirty()
  }

  private updateTagSelectorVisibility() {
    if (!this.hasTagSelectorTarget) return

    if (this.visibilityValue === "restricted") {
      this.tagSelectorTarget.style.display = "block"
    } else {
      this.tagSelectorTarget.style.display = "none"
      this.selectedValue = ""
      this.renderSelectedTag()
    }
  }

  private markDirty() {
    if (!this.standaloneValue) return

    this.isDirty = true
    if (this.hasSaveButtonTarget) {
      this.saveButtonTarget.disabled = false
      this.saveButtonTarget.classList.add("has-changes")
    }
  }

  async save(event: Event) {
    event.preventDefault()

    if (!this.isDirty || !this.standaloneValue) return
    if (!this.hasSaveButtonTarget) return

    this.saveButtonTarget.disabled = true
    this.saveButtonTarget.textContent = "保存中..."

    try {
      const csrfToken = document.querySelector<HTMLMetaElement>(
        'meta[name="csrf-token"]'
      )?.content

      const response = await fetch(this.saveUrlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken || "",
        },
        body: JSON.stringify({
          visibility: this.visibilityValue,
          authorization_tag_id: this.selectedValue || null,
        }),
      })

      if (response.ok) {
        this.isDirty = false
        this.saveButtonTarget.textContent = "保存しました"
        this.saveButtonTarget.classList.remove("has-changes")
        setTimeout(() => {
          this.saveButtonTarget.textContent = "保存"
          this.saveButtonTarget.disabled = true
        }, 2000)
      } else {
        throw new Error("Save failed")
      }
    } catch (error) {
      this.saveButtonTarget.textContent = "保存"
      this.saveButtonTarget.disabled = false
      alert("保存に失敗しました")
    }
  }

  private showDropdown(tags: Tag[]) {
    this.dropdownTarget.innerHTML = tags
      .map(
        (tag) => `
        <button type="button"
                class="authorization-tag-dropdown-item"
                data-tag-id="${tag.id}"
                data-action="click->authorization-tags#selectTag">
          ${this.escapeHtml(tag.name)}
        </button>
      `
      )
      .join("")
    this.dropdownTarget.classList.add("show")
  }

  private hideDropdown() {
    this.dropdownTarget.classList.remove("show")
  }

  private renderSelectedTag() {
    const selectedTag = this.tagsValue.find((tag) => tag.id === this.selectedValue)

    if (selectedTag) {
      this.selectedTagsTarget.innerHTML = `
        <span class="authorization-tag-inline">
          ${this.escapeHtml(selectedTag.name)}
          <button type="button"
                  class="authorization-tag-pill-remove"
                  data-action="click->authorization-tags#removeTag">
            &times;
          </button>
        </span>
      `
      this.hiddenInputTarget.value = selectedTag.id
      if (this.hasInputWrapperTarget) {
        this.inputWrapperTarget.classList.add("has-selection")
      }
    } else {
      this.selectedTagsTarget.innerHTML = ""
      this.hiddenInputTarget.value = ""
      if (this.hasInputWrapperTarget) {
        this.inputWrapperTarget.classList.remove("has-selection")
      }
    }
  }

  private escapeHtml(text: string): string {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
