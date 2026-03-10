import { Controller } from '@hotwired/stimulus';

/**
 * Mobile menu controller for toggling the header overlay
 *
 * Usage:
 * <div data-controller="mobile-menu">
 *   <button data-mobile-menu-target="button" data-action="click->mobile-menu#toggle">
 *     <span class="icon" data-mobile-menu-target="icon">...</span>
 *     <span class="text" data-mobile-menu-target="text">MENU</span>
 *   </button>
 *   <div data-mobile-menu-target="overlay">...</div>
 * </div>
 */
export default class MobileMenuController extends Controller {
  static targets = ['overlay', 'button', 'menuIcon', 'closeIcon', 'text'];

  declare readonly overlayTarget: HTMLElement;
  declare readonly hasOverlayTarget: boolean;
  declare readonly buttonTarget: HTMLElement;
  declare readonly hasButtonTarget: boolean;
  declare readonly menuIconTarget: HTMLElement;
  declare readonly hasMenuIconTarget: boolean;
  declare readonly closeIconTarget: HTMLElement;
  declare readonly hasCloseIconTarget: boolean;
  declare readonly textTarget: HTMLElement;
  declare readonly hasTextTarget: boolean;

  private isOpen = false;

  toggle() {
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  }

  open() {
    this.isOpen = true;

    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add('show');
    }

    if (this.hasMenuIconTarget) {
      this.menuIconTarget.style.display = 'none';
    }

    if (this.hasCloseIconTarget) {
      this.closeIconTarget.style.display = 'flex';
    }

    if (this.hasTextTarget) {
      this.textTarget.textContent = 'CLOSE';
    }

    document.body.style.overflow = 'hidden';
  }

  close() {
    this.isOpen = false;

    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove('show');
    }

    if (this.hasMenuIconTarget) {
      this.menuIconTarget.style.display = 'flex';
    }

    if (this.hasCloseIconTarget) {
      this.closeIconTarget.style.display = 'none';
    }

    if (this.hasTextTarget) {
      this.textTarget.textContent = 'MENU';
    }

    document.body.style.overflow = '';
  }
}
