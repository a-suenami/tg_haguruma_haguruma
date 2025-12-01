import { Controller } from '@hotwired/stimulus';

type AutosaveStatus = 'idle' | 'saving' | 'saved' | 'error';

export default class extends Controller {
  static values = {
    url: String,
    intervalMs: { type: Number, default: 10000 }, // 10秒ごとに保存
  };

  static targets = ['status', 'form'];

  declare readonly urlValue: string;
  declare readonly intervalMsValue: number;
  declare readonly statusTarget: HTMLElement;
  declare readonly formTarget: HTMLFormElement;
  declare readonly hasStatusTarget: boolean;
  declare readonly hasFormTarget: boolean;

  private intervalId: ReturnType<typeof setInterval> | null = null;
  private lastSavedData: string = '';
  private status: AutosaveStatus = 'idle';
  private isDirty: boolean = false;

  connect() {
    this.setupEventListeners();
    this.startAutoSaveInterval();
  }

  disconnect() {
    this.stopAutoSaveInterval();
  }

  private setupEventListeners() {
    const form = this.hasFormTarget ? this.formTarget : this.element.querySelector('form');
    if (!form) return;

    // Listen for input changes - mark as dirty
    form.addEventListener('input', this.handleInput.bind(this));
    form.addEventListener('change', this.handleInput.bind(this));

    // Listen for blur events on form fields - save immediately
    form.addEventListener('focusout', this.handleBlur.bind(this));

    // Listen for custom event from Lexical editor
    this.element.addEventListener('lexical:change', this.handleInput.bind(this));
  }

  private handleInput() {
    this.isDirty = true;
  }

  private handleBlur(event: FocusEvent) {
    const target = event.target as HTMLElement;
    // Only save on blur from actual form fields
    if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA' || target.tagName === 'SELECT') {
      if (this.isDirty) {
        this.save();
      }
    }
  }

  private startAutoSaveInterval() {
    this.intervalId = setInterval(() => {
      if (this.isDirty) {
        this.save();
      }
    }, this.intervalMsValue);
  }

  private stopAutoSaveInterval() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  private async save() {
    const form = this.hasFormTarget ? this.formTarget : this.element.querySelector('form');
    if (!form) return;

    const formData = new FormData(form as HTMLFormElement);
    const currentData = this.serializeFormData(formData);

    // Skip if data hasn't changed
    if (currentData === this.lastSavedData) {
      this.isDirty = false;
      return;
    }

    this.updateStatus('saving');

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

      const response = await fetch(this.urlValue, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': csrfToken || '',
        },
        body: formData,
      });

      if (response.ok) {
        const data = await response.json();
        this.lastSavedData = currentData;
        this.isDirty = false;
        this.updateStatus('saved', data.saved_at);
      } else {
        console.error('Autosave failed:', response.statusText);
        this.updateStatus('error');
      }
    } catch (error) {
      console.error('Autosave error:', error);
      this.updateStatus('error');
    }
  }

  private serializeFormData(formData: FormData): string {
    const params = new URLSearchParams();
    formData.forEach((value, key) => {
      params.append(key, value.toString());
    });
    return params.toString();
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
        this.statusTarget.textContent = `保存済み ${time ? `(${time})` : ''}`;
        break;
      case 'error':
        this.statusTarget.textContent = '保存に失敗しました';
        break;
    }
  }

  private formatTime(isoString: string): string {
    const date = new Date(isoString);
    return date.toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit' });
  }

  // Public method to trigger save manually
  saveNow() {
    this.save();
  }
}
