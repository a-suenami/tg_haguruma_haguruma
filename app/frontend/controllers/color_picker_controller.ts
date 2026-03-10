import { Controller } from '@hotwired/stimulus';

/**
 * Color picker controller for syncing color input with text input
 *
 * Usage:
 * <div data-controller="color-picker">
 *   <input type="color" data-color-picker-target="color" />
 *   <input type="text" data-color-picker-target="text" />
 * </div>
 */
export default class ColorPickerController extends Controller {
  static targets = ['color', 'text'];

  declare readonly colorTarget: HTMLInputElement;
  declare readonly textTarget: HTMLInputElement;

  private static readonly HEX_COLOR_PATTERN = /^#[0-9A-Fa-f]{6}$/;

  connect() {
    this.textTarget.setAttribute('pattern', '#[0-9A-Fa-f]{6}');
    this.textTarget.setAttribute('title', '#RRGGBB形式で入力してください（例: #FF0000）');
  }

  syncToText() {
    this.textTarget.value = this.colorTarget.value.toUpperCase();
    this.textTarget.setCustomValidity('');
  }

  syncToColor() {
    const value = this.textTarget.value.toUpperCase();
    if (ColorPickerController.HEX_COLOR_PATTERN.test(value)) {
      this.colorTarget.value = value;
      this.textTarget.value = value;
      this.textTarget.setCustomValidity('');
    } else {
      this.textTarget.setCustomValidity('#RRGGBB形式で入力してください（例: #FF0000）');
    }
  }

  restoreOnBlur() {
    if (!ColorPickerController.HEX_COLOR_PATTERN.test(this.textTarget.value)) {
      this.textTarget.value = this.colorTarget.value.toUpperCase();
      this.textTarget.setCustomValidity('');
    }
  }
}
