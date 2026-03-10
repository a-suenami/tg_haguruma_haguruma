import { Controller } from '@hotwired/stimulus';

export default class PcFeaturesController extends Controller {
  static targets = ['container'];

  declare containerTarget: HTMLElement;

  connect(): void {
    this.initSortable();
  }

  private initSortable(): void {
    // UIkit sortable fires 'moved' event when item is reordered
    this.containerTarget.addEventListener('moved', () => {
      this.updatePositions();
    });
  }

  updatePositions(): void {
    const items = this.containerTarget.querySelectorAll('[data-pc-features-target="item"]');
    items.forEach((item, index) => {
      const positionInput = item.querySelector('[data-menu-order-input]') as HTMLInputElement;
      if (positionInput) {
        positionInput.value = String(index + 1);
      }
    });
  }
}
