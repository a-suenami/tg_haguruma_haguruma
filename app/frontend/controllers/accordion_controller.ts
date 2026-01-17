import { Controller } from '@hotwired/stimulus';

/**
 * Accordion controller for exclusive open/close behavior with animation
 * Animation is handled by CSS using grid-template-rows
 *
 * Usage:
 * <div data-controller="accordion">
 *   <details data-accordion-target="item">
 *     <summary>...</summary>
 *     <div class="answer">
 *       <div><p>...</p></div>
 *     </div>
 *   </details>
 * </div>
 */
export default class AccordionController extends Controller {
  static targets = ['item'];

  declare readonly itemTargets: HTMLDetailsElement[];

  private animatingItems = new Set<HTMLDetailsElement>();
  private boundHandleClick = this.handleClick.bind(this);

  connect() {
    this.itemTargets.forEach((item) => {
      const summary = item.querySelector('summary');
      if (summary) {
        summary.addEventListener('click', this.boundHandleClick);
      }
    });
  }

  disconnect() {
    this.itemTargets.forEach((item) => {
      const summary = item.querySelector('summary');
      if (summary) {
        summary.removeEventListener('click', this.boundHandleClick);
      }
    });
  }

  private handleClick(event: Event) {
    event.preventDefault();

    const summary = event.currentTarget as HTMLElement;
    const item = summary.closest('details') as HTMLDetailsElement;

    if (this.animatingItems.has(item)) {
      return;
    }

    if (item.open) {
      // Closing animation
      this.closeWithAnimation(item);
    } else {
      // Close other items first
      this.itemTargets.forEach((otherItem) => {
        if (otherItem !== item && otherItem.open) {
          this.closeWithAnimation(otherItem);
        }
      });
      // Open this item
      item.open = true;
    }
  }

  private closeWithAnimation(item: HTMLDetailsElement) {
    this.animatingItems.add(item);

    const answer = item.querySelector('.answer') as HTMLElement;
    if (answer) {
      // Trigger closing animation by setting grid-template-rows to 0fr
      answer.style.gridTemplateRows = '0fr';

      const onTransitionEnd = () => {
        item.open = false;
        answer.style.gridTemplateRows = '';
        this.animatingItems.delete(item);
        answer.removeEventListener('transitionend', onTransitionEnd);
      };

      answer.addEventListener('transitionend', onTransitionEnd, { once: true });

      // Fallback in case transitionend doesn't fire
      setTimeout(() => {
        if (this.animatingItems.has(item)) {
          item.open = false;
          answer.style.gridTemplateRows = '';
          this.animatingItems.delete(item);
        }
      }, 150);
    } else {
      item.open = false;
      this.animatingItems.delete(item);
    }
  }
}
