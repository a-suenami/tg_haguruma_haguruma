import { Controller } from '@hotwired/stimulus';

export default class MenuSettingsController extends Controller {
  static targets = ['container', 'template'];

  declare containerTarget: HTMLElement;
  declare templateTarget: HTMLTemplateElement;

  private customLinkCounter = 0;

  connect(): void {
    this.initSortable();
    this.customLinkCounter = this.containerTarget.querySelectorAll('[data-item-type="custom"]').length;
  }

  private initSortable(): void {
    // @ts-expect-error UIkit is global
    UIkit.util.on(this.containerTarget, 'stop', () => {
      this.updatePositions();
    });
  }

  addCustomLink(event: Event): void {
    event.preventDefault();

    const template = this.templateTarget.content.cloneNode(true) as DocumentFragment;
    const newIndex = this.customLinkCounter++;

    // Update input names with new index
    template.querySelectorAll('input').forEach((input) => {
      const name = input.getAttribute('name');
      if (name) {
        input.setAttribute('name', name.replace('NEW_INDEX', String(newIndex)));
      }
    });

    this.containerTarget.appendChild(template);
    this.updatePositions();
  }

  removeItem(event: Event): void {
    event.preventDefault();
    const button = event.currentTarget as HTMLElement;
    const item = button.closest('[data-menu-settings-target="item"]') as HTMLElement;

    if (!item) return;

    if (item.dataset.itemType === 'feature') {
      alert('デフォルト機能は削除できません。無効にするには機能設定で設定してください。');
      return;
    }

    item.remove();
    this.updatePositions();
  }

  updatePositions(): void {
    const items = this.containerTarget.querySelectorAll('[data-menu-settings-target="item"]');
    items.forEach((item, index) => {
      const positionInput = item.querySelector('[data-position-input]') as HTMLInputElement;
      if (positionInput) {
        positionInput.value = String(index + 1);
      }
    });
  }
}
