import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['uploadArea', 'fileInput', 'filePreview', 'filename', 'meta', 'submitBtn'];

  declare readonly uploadAreaTarget: HTMLElement;
  declare readonly fileInputTarget: HTMLInputElement;
  declare readonly filePreviewTarget: HTMLElement;
  declare readonly filenameTarget: HTMLElement;
  declare readonly metaTarget: HTMLElement;
  declare readonly submitBtnTarget: HTMLButtonElement;

  dragover(event: DragEvent) {
    event.preventDefault();
    this.uploadAreaTarget.classList.add('dragover');
  }

  dragleave(event: DragEvent) {
    event.preventDefault();
    this.uploadAreaTarget.classList.remove('dragover');
  }

  drop(event: DragEvent) {
    event.preventDefault();
    this.uploadAreaTarget.classList.remove('dragover');
    const files = event.dataTransfer?.files;
    if (files?.length) {
      this.fileInputTarget.files = files;
      this.showPreview(files[0]);
    }
  }

  selectFile() {
    const files = this.fileInputTarget.files;
    if (files?.length) {
      this.showPreview(files[0]);
    }
  }

  clearFile() {
    this.fileInputTarget.value = '';
    this.uploadAreaTarget.style.display = '';
    this.filePreviewTarget.style.display = 'none';
    this.submitBtnTarget.disabled = true;
  }

  private showPreview(file: File) {
    this.filenameTarget.textContent = file.name;
    this.metaTarget.textContent = `${this.formatFileSize(file.size)} - ${file.type}`;
    this.uploadAreaTarget.style.display = 'none';
    this.filePreviewTarget.style.display = 'block';
    this.submitBtnTarget.disabled = false;
  }

  private formatFileSize(bytes: number): string {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }
}
