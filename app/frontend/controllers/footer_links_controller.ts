import { Controller } from '@hotwired/stimulus';

export default class FooterLinksController extends Controller {
  static targets = ['mainLinksBody', 'subLinksBody', 'mainLinkTemplate', 'subLinkTemplate'];

  declare mainLinksBodyTarget: HTMLTableSectionElement;
  declare subLinksBodyTarget: HTMLTableSectionElement;
  declare mainLinkTemplateTarget: HTMLTemplateElement;
  declare subLinkTemplateTarget: HTMLTemplateElement;

  private mainLinkCounter = 100;
  private subLinkCounter = 100;

  connect(): void {
    // Initialize counters based on existing rows
    this.mainLinkCounter = this.mainLinksBodyTarget.querySelectorAll('tr').length + 100;
    this.subLinkCounter = this.subLinksBodyTarget.querySelectorAll('tr').length + 100;

    // Setup sortable callbacks
    this.setupSortableCallbacks();
  }

  setupSortableCallbacks(): void {
    // UIkit sortable fires 'moved' event when item is reordered
    this.mainLinksBodyTarget.addEventListener('moved', () => this.updatePositions('main'));
    this.subLinksBodyTarget.addEventListener('moved', () => this.updatePositions('sub'));
  }

  addMainLink(event: Event): void {
    event.preventDefault();
    const template = this.mainLinkTemplateTarget;
    const clone = template.content.cloneNode(true) as DocumentFragment;

    // Replace INDEX placeholder with actual index
    const html = (clone.firstElementChild as HTMLElement).outerHTML.replace(/INDEX/g, String(this.mainLinkCounter));
    this.mainLinksBodyTarget.insertAdjacentHTML('beforeend', html);

    this.mainLinkCounter++;
    this.updatePositions('main');
  }

  addSubLink(event: Event): void {
    event.preventDefault();
    const template = this.subLinkTemplateTarget;
    const clone = template.content.cloneNode(true) as DocumentFragment;

    // Replace INDEX placeholder with actual index
    const html = (clone.firstElementChild as HTMLElement).outerHTML.replace(/INDEX/g, String(this.subLinkCounter));
    this.subLinksBodyTarget.insertAdjacentHTML('beforeend', html);

    this.subLinkCounter++;
    this.updatePositions('sub');
  }

  removeMainLink(event: Event): void {
    event.preventDefault();
    const row = (event.currentTarget as HTMLElement).closest('tr');
    if (row) {
      row.remove();
      this.updatePositions('main');
    }
  }

  removeSubLink(event: Event): void {
    event.preventDefault();
    const row = (event.currentTarget as HTMLElement).closest('tr');
    if (row) {
      row.remove();
      this.updatePositions('sub');
    }
  }

  updatePositions(type: 'main' | 'sub'): void {
    const tbody = type === 'main' ? this.mainLinksBodyTarget : this.subLinksBodyTarget;
    const rows = tbody.querySelectorAll('tr');

    rows.forEach((row, index) => {
      const positionInput = row.querySelector('.position-input') as HTMLInputElement;
      if (positionInput) {
        positionInput.value = String(index);
      }
    });
  }
}
