import { Controller } from '@hotwired/stimulus';

type AutosaveStatus = 'idle' | 'saving' | 'saved' | 'error';

/**
 * Per-field autosave controller
 *
 * Attaches to individual field containers and saves to:
 * PATCH /admin/contents/types/:content_type_id/entries/:entry_id/fields/:api_identifier
 *
 * Usage:
 * <div data-controller="autosave-field"
 *      data-autosave-field-url-value="/admin/contents/types/1/entries/2/fields/title"
 *      data-autosave-field-debounce-ms-value="1000">
 *   <input data-autosave-field-target="input" ... />
 *   <span data-autosave-field-target="status"></span>
 * </div>
 */
export default class extends Controller {
  static values = {
    url: String,
    debounceMs: { type: Number, default: 1000 },
  };

  static targets = ['input', 'status'];

  declare readonly urlValue: string;
  declare readonly debounceMsValue: number;
  declare readonly inputTarget: HTMLInputElement | HTMLTextAreaElement;
  declare readonly statusTarget: HTMLElement;
  declare readonly hasInputTarget: boolean;
  declare readonly hasStatusTarget: boolean;

  private debounceTimer: ReturnType<typeof setTimeout> | null = null;
  private lastSavedValue: string | string[] = '';
  private status: AutosaveStatus = 'idle';
  private isDirty: boolean = false;

  connect() {
    this.setupEventListeners();
    this.lastSavedValue = this.getCurrentValue();
  }

  disconnect() {
    this.clearDebounce();
  }

  private setupEventListeners() {
    // Listen for input changes
    this.element.addEventListener('input', this.handleInput.bind(this));
    this.element.addEventListener('change', this.handleChange.bind(this));

    // Listen for blur - save immediately
    this.element.addEventListener('focusout', this.handleBlur.bind(this));

    // Listen for custom event from Lexical editor
    this.element.addEventListener('lexical:change', this.handleLexicalChange.bind(this));
  }

  private handleInput() {
    this.isDirty = true;
    this.debounceSave();
  }

  private handleChange() {
    this.isDirty = true;
    this.debounceSave();
  }

  private handleLexicalChange() {
    this.isDirty = true;
    this.debounceSave();
  }

  private handleBlur(event: FocusEvent) {
    const target = event.target as HTMLElement;
    // Only save on blur from actual form fields
    if (
      target.tagName === 'INPUT' ||
      target.tagName === 'TEXTAREA' ||
      target.tagName === 'SELECT'
    ) {
      if (this.isDirty) {
        this.clearDebounce();
        this.save();
      }
    }
  }

  private debounceSave() {
    this.clearDebounce();
    this.debounceTimer = setTimeout(() => {
      if (this.isDirty) {
        this.save();
      }
    }, this.debounceMsValue);
  }

  private clearDebounce() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
      this.debounceTimer = null;
    }
  }

  private getCurrentValue(): string | string[] {
    // Check for checkboxes (multi-select)
    const checkboxes = this.element.querySelectorAll(
      'input[type="checkbox"]',
    ) as NodeListOf<HTMLInputElement>;
    if (checkboxes.length > 0) {
      return Array.from(checkboxes)
        .filter((cb) => cb.checked)
        .map((cb) => cb.value);
    }

    // Check for radio buttons (single select)
    const radios = this.element.querySelectorAll(
      'input[type="radio"]',
    ) as NodeListOf<HTMLInputElement>;
    if (radios.length > 0) {
      const checked = Array.from(radios).find((r) => r.checked);
      return checked?.value || '';
    }

    if (this.hasInputTarget) {
      return this.inputTarget.value;
    }

    // Try to find any input, textarea, or hidden field
    const input = this.element.querySelector(
      'input[type="text"], input[type="hidden"], textarea, select',
    ) as HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement | null;

    return input?.value || '';
  }

  private async save() {
    const currentValue = this.getCurrentValue();

    // Skip if value hasn't changed
    if (this.valuesEqual(currentValue, this.lastSavedValue)) {
      this.isDirty = false;
      return;
    }

    this.updateStatus('saving');

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

      const response = await fetch(this.urlValue, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken || '',
        },
        body: JSON.stringify({ value: currentValue }),
      });

      if (response.ok) {
        const data = await response.json();
        this.lastSavedValue = currentValue;
        this.isDirty = false;
        this.updateStatus('saved', data.saved_at);
      } else {
        const errorData = await response.json().catch(() => ({}));
        console.error('Autosave failed:', response.statusText, errorData);
        this.updateStatus('error');
      }
    } catch (error) {
      console.error('Autosave error:', error);
      this.updateStatus('error');
    }
  }

  private updateStatus(status: AutosaveStatus, savedAt?: string) {
    this.status = status;

    if (!this.hasStatusTarget) return;

    this.statusTarget.className = `autosave-status autosave-status--${status}`;

    switch (status) {
      case 'idle':
        this.statusTarget.textContent = '';
        break;
      case 'saving':
        this.statusTarget.textContent = '保存中...';
        break;
      case 'saved':
        const time = savedAt ? this.formatTime(savedAt) : '';
        this.statusTarget.textContent = `保存済み${time ? ` (${time})` : ''}`;
        // Reset to idle after 3 seconds
        setTimeout(() => {
          if (this.status === 'saved') {
            this.updateStatus('idle');
          }
        }, 3000);
        break;
      case 'error':
        this.statusTarget.textContent = '保存失敗';
        break;
    }
  }

  private formatTime(isoString: string): string {
    const date = new Date(isoString);
    return date.toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit' });
  }

  private valuesEqual(a: string | string[], b: string | string[]): boolean {
    if (Array.isArray(a) && Array.isArray(b)) {
      return JSON.stringify(a.sort()) === JSON.stringify(b.sort());
    }
    return a === b;
  }

  // Public method to trigger save manually
  saveNow() {
    this.clearDebounce();
    this.save();
  }
}
