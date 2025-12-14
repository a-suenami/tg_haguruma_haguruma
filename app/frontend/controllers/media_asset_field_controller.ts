import { Controller } from '@hotwired/stimulus';
import { uploadMedia, type MediaUploadResponse } from '../utils/mediaUpload';

interface MediaAsset {
  id: string;
  url: string;
  filename: string;
  media_type: 'image' | 'video' | 'audio' | 'document';
  file_size_bytes: number;
  mime_type: string;
}

/**
 * Media Asset Field Controller
 *
 * Handles file upload and media library selection for media_asset fields
 *
 * Usage:
 * <div data-controller="media-asset-field"
 *      data-media-asset-field-current-media-id-value="uuid"
 *      data-media-asset-field-upload-url-value="/admin/media/upload"
 *      data-media-asset-field-library-url-value="/admin/media.json">
 *   <input type="hidden" data-media-asset-field-target="hiddenInput" ... />
 *   <div data-media-asset-field-target="preview">...</div>
 *   <input type="file" data-media-asset-field-target="fileInput" ... />
 * </div>
 */
export default class extends Controller {
  static values = {
    currentMediaId: String,
    currentMediaUrl: String,
    currentMediaType: String,
    currentFilename: String,
    uploadUrl: { type: String, default: '/admin/media/upload' },
    libraryUrl: { type: String, default: '/admin/media.json' },
  };

  static targets = [
    'hiddenInput',
    'preview',
    'thumbnail',
    'filename',
    'typeBadge',
    'fileInput',
    'uploadProgress',
    'progressFill',
    'actions',
  ];

  declare readonly currentMediaIdValue: string;
  declare readonly currentMediaUrlValue: string;
  declare readonly currentMediaTypeValue: string;
  declare readonly currentFilenameValue: string;
  declare readonly uploadUrlValue: string;
  declare readonly libraryUrlValue: string;

  declare readonly hiddenInputTarget: HTMLInputElement;
  declare readonly previewTarget: HTMLElement;
  declare readonly thumbnailTarget: HTMLElement;
  declare readonly filenameTarget: HTMLElement;
  declare readonly typeBadgeTarget: HTMLElement;
  declare readonly fileInputTarget: HTMLInputElement;
  declare readonly uploadProgressTarget: HTMLElement;
  declare readonly progressFillTarget: HTMLElement;
  declare readonly actionsTarget: HTMLElement;

  declare readonly hasPreviewTarget: boolean;
  declare readonly hasThumbnailTarget: boolean;
  declare readonly hasFilenameTarget: boolean;
  declare readonly hasTypeBadgeTarget: boolean;
  declare readonly hasUploadProgressTarget: boolean;
  declare readonly hasProgressFillTarget: boolean;

  private modal: HTMLElement | null = null;
  private selectedMediaId: string | null = null;

  connect() {
    // If we have a current media ID, fetch and display it
    if (this.currentMediaIdValue) {
      this.fetchAndDisplayCurrentMedia();
    }
  }

  disconnect() {
    this.closeModal();
  }

  // Action: Trigger file input click
  selectFile() {
    this.fileInputTarget.click();
  }

  // Action: Handle file selection and upload
  async uploadFile(event: Event) {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];

    if (!file) return;

    this.showUploadProgress();

    try {
      const result = await uploadMedia(file);
      console.log('Upload result:', result);
      this.setMedia(result.id, result.url, result.media_type, result.original_filename);
      this.hideUploadProgress();
      this.triggerAutosave();
    } catch (error) {
      console.error('Upload failed:', error);
      this.hideUploadProgress();
      alert('アップロードに失敗しました。もう一度お試しください。');
    }

    // Clear input for re-selection
    input.value = '';
  }

  // Action: Open media library modal
  async openLibrary() {
    await this.createModal();
    await this.loadMediaLibrary();
  }

  // Action: Remove selected media
  removeMedia() {
    this.hiddenInputTarget.value = '';
    this.clearPreview();
    this.triggerAutosave();
  }

  private setMedia(id: string, url: string, mediaType: string, filename: string) {
    this.hiddenInputTarget.value = id;
    this.updatePreview(url, mediaType, filename);
  }

  private updatePreview(url: string, mediaType: string, filename: string) {
    console.log('updatePreview called:', { url, mediaType, filename });
    console.log('hasPreviewTarget:', this.hasPreviewTarget);
    console.log('hasThumbnailTarget:', this.hasThumbnailTarget);

    if (!this.hasPreviewTarget) {
      console.warn('Preview target not found!');
      return;
    }

    this.previewTarget.style.display = '';

    if (this.hasThumbnailTarget) {
      if (mediaType === 'image') {
        this.thumbnailTarget.innerHTML = `<img src="${url}" alt="${filename}" />`;
      } else {
        const icon = this.getIconForMediaType(mediaType);
        this.thumbnailTarget.innerHTML = `<i class="fas ${icon} fa-2x"></i>`;
      }
    }

    if (this.hasFilenameTarget) {
      this.filenameTarget.textContent = filename;
      this.filenameTarget.setAttribute('title', filename);
    }

    if (this.hasTypeBadgeTarget) {
      this.typeBadgeTarget.textContent = mediaType;
      this.typeBadgeTarget.className = `media-type-badge media-type-${mediaType}`;
    }

    console.log('Preview updated successfully');
  }

  private clearPreview() {
    if (!this.hasPreviewTarget) return;
    this.previewTarget.style.display = 'none';

    if (this.hasThumbnailTarget) {
      this.thumbnailTarget.innerHTML = '';
    }

    if (this.hasFilenameTarget) {
      this.filenameTarget.textContent = '';
    }

    if (this.hasTypeBadgeTarget) {
      this.typeBadgeTarget.textContent = '';
      this.typeBadgeTarget.className = 'media-type-badge';
    }
  }

  private getIconForMediaType(mediaType: string): string {
    switch (mediaType) {
      case 'video':
        return 'fa-video';
      case 'audio':
        return 'fa-music';
      case 'document':
        return 'fa-file';
      default:
        return 'fa-image';
    }
  }

  private showUploadProgress() {
    if (this.hasUploadProgressTarget) {
      this.uploadProgressTarget.style.display = '';
    }
    this.actionsTarget.style.display = 'none';
  }

  private hideUploadProgress() {
    if (this.hasUploadProgressTarget) {
      this.uploadProgressTarget.style.display = 'none';
    }
    this.actionsTarget.style.display = '';
  }

  private triggerAutosave() {
    // Dispatch change event to trigger autosave
    this.hiddenInputTarget.dispatchEvent(new Event('change', { bubbles: true }));
  }

  private async fetchAndDisplayCurrentMedia() {
    // If we have URL/type/filename from data attributes, use them directly
    if (this.currentMediaUrlValue && this.currentMediaTypeValue && this.currentFilenameValue) {
      this.updatePreview(
        this.currentMediaUrlValue,
        this.currentMediaTypeValue,
        this.currentFilenameValue,
      );
      return;
    }

    // Otherwise fetch from API
    try {
      const response = await fetch(`/admin/media/${this.currentMediaIdValue}.json`);
      if (response.ok) {
        const media: MediaAsset = await response.json();
        this.updatePreview(media.url, media.media_type, media.filename);
      }
    } catch (error) {
      console.error('Failed to fetch current media:', error);
    }
  }

  // Modal methods
  private async createModal() {
    if (this.modal) return;

    this.modal = document.createElement('div');
    this.modal.className = 'media-library-modal-overlay';
    this.modal.innerHTML = `
      <div class="media-library-modal">
        <div class="media-library-modal-header">
          <h3>メディアライブラリ</h3>
          <button type="button" class="modal-close-btn" data-action="click->media-asset-field#closeModal">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="media-library-modal-filters">
          <select class="filter-select" data-media-asset-field-target="typeFilter">
            <option value="">すべて</option>
            <option value="image">画像</option>
            <option value="video">動画</option>
            <option value="audio">音声</option>
            <option value="document">ドキュメント</option>
          </select>
          <input type="search" placeholder="ファイル名で検索..." class="search-input" data-media-asset-field-target="searchInput" />
          <button type="button" class="btn btn-secondary btn-sm" data-action="click->media-asset-field#filterLibrary">
            <i class="fas fa-search"></i>
          </button>
        </div>
        <div class="media-library-modal-content">
          <div class="media-library-grid" data-media-asset-field-target="libraryGrid">
            <div class="loading-indicator">読み込み中...</div>
          </div>
        </div>
        <div class="media-library-modal-footer">
          <button type="button" class="btn btn-secondary" data-action="click->media-asset-field#closeModal">
            キャンセル
          </button>
          <button type="button" class="btn btn-primary" data-action="click->media-asset-field#confirmSelection" disabled data-media-asset-field-target="confirmBtn">
            選択
          </button>
        </div>
      </div>
    `;

    document.body.appendChild(this.modal);

    // Close on overlay click
    this.modal.addEventListener('click', (e) => {
      if (e.target === this.modal) {
        this.closeModal();
      }
    });

    // Close on Escape key
    document.addEventListener('keydown', this.handleEscapeKey);
  }

  private handleEscapeKey = (e: KeyboardEvent) => {
    if (e.key === 'Escape') {
      this.closeModal();
    }
  };

  closeModal() {
    if (this.modal) {
      document.body.removeChild(this.modal);
      this.modal = null;
      this.selectedMediaId = null;
      document.removeEventListener('keydown', this.handleEscapeKey);
    }
  }

  private async loadMediaLibrary(type = '', query = '') {
    if (!this.modal) return;

    const grid = this.modal.querySelector('[data-media-asset-field-target="libraryGrid"]');
    if (!grid) return;

    grid.innerHTML = '<div class="loading-indicator">読み込み中...</div>';

    try {
      const params = new URLSearchParams();
      if (type) params.append('type', type);
      if (query) params.append('q', query);

      const url = `${this.libraryUrlValue}${params.toString() ? `?${params}` : ''}`;
      const response = await fetch(url);

      if (!response.ok) throw new Error('Failed to load media');

      const mediaAssets: MediaAsset[] = await response.json();

      if (mediaAssets.length === 0) {
        grid.innerHTML = `
          <div class="empty-state">
            <i class="fas fa-images fa-3x"></i>
            <p>メディアがありません</p>
          </div>
        `;
        return;
      }

      grid.innerHTML = mediaAssets
        .map(
          (media) => `
        <div class="media-library-item ${this.selectedMediaId === media.id ? 'selected' : ''}"
             data-media-id="${media.id}"
             data-media-url="${media.url}"
             data-media-type="${media.media_type}"
             data-media-filename="${media.filename}"
             data-action="click->media-asset-field#selectLibraryItem">
          <div class="media-library-item-preview">
            ${
              media.media_type === 'image'
                ? `<img src="${media.url}" alt="${media.filename}" />`
                : `<i class="fas ${this.getIconForMediaType(media.media_type)} fa-2x"></i>`
            }
          </div>
          <div class="media-library-item-info">
            <span class="media-library-item-name" title="${media.filename}">${this.truncateFilename(media.filename)}</span>
            <span class="media-type-badge media-type-${media.media_type}">${media.media_type}</span>
          </div>
        </div>
      `,
        )
        .join('');
    } catch (error) {
      console.error('Failed to load media library:', error);
      grid.innerHTML = `
        <div class="error-state">
          <i class="fas fa-exclamation-circle fa-3x"></i>
          <p>読み込みに失敗しました</p>
        </div>
      `;
    }
  }

  filterLibrary() {
    if (!this.modal) return;

    const typeFilter = this.modal.querySelector(
      '[data-media-asset-field-target="typeFilter"]',
    ) as HTMLSelectElement;
    const searchInput = this.modal.querySelector(
      '[data-media-asset-field-target="searchInput"]',
    ) as HTMLInputElement;

    const type = typeFilter?.value || '';
    const query = searchInput?.value || '';

    this.loadMediaLibrary(type, query);
  }

  selectLibraryItem(event: Event) {
    const target = (event.target as HTMLElement).closest('.media-library-item') as HTMLElement;
    if (!target) return;

    // Remove selection from all items
    const allItems = this.modal?.querySelectorAll('.media-library-item');
    allItems?.forEach((item) => item.classList.remove('selected'));

    // Select clicked item
    target.classList.add('selected');
    this.selectedMediaId = target.dataset.mediaId || null;

    // Enable confirm button
    const confirmBtn = this.modal?.querySelector(
      '[data-media-asset-field-target="confirmBtn"]',
    ) as HTMLButtonElement;
    if (confirmBtn) {
      confirmBtn.disabled = false;
    }
  }

  confirmSelection() {
    if (!this.modal || !this.selectedMediaId) return;

    const selectedItem = this.modal.querySelector(
      `.media-library-item[data-media-id="${this.selectedMediaId}"]`,
    ) as HTMLElement;
    if (!selectedItem) return;

    const url = selectedItem.dataset.mediaUrl || '';
    const mediaType = selectedItem.dataset.mediaType || '';
    const filename = selectedItem.dataset.mediaFilename || '';

    this.setMedia(this.selectedMediaId, url, mediaType, filename);
    this.triggerAutosave();
    this.closeModal();
  }

  private truncateFilename(filename: string, maxLength = 20): string {
    if (filename.length <= maxLength) return filename;
    const ext = filename.split('.').pop() || '';
    const nameWithoutExt = filename.slice(0, filename.lastIndexOf('.'));
    const truncatedName = nameWithoutExt.slice(0, maxLength - ext.length - 4) + '...';
    return `${truncatedName}.${ext}`;
  }
}
