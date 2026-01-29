import { Controller } from '@hotwired/stimulus';

export default class ImageProtectionController extends Controller {
  connect() {
    this.attachProtection();
  }

  private attachProtection() {
    const images = this.element.querySelectorAll('img');
    images.forEach((img) => {
      img.addEventListener('contextmenu', this.preventDefault);
      img.addEventListener('dragstart', this.preventDefault);
    });
  }

  private preventDefault = (e: Event) => {
    e.preventDefault();
    return false;
  };

  disconnect() {
    const images = this.element.querySelectorAll('img');
    images.forEach((img) => {
      img.removeEventListener('contextmenu', this.preventDefault);
      img.removeEventListener('dragstart', this.preventDefault);
    });
  }
}
