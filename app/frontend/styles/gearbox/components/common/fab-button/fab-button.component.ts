import { CommonModule } from '@angular/common';
import {
  booleanAttribute,
  ChangeDetectionStrategy,
  Component,
  HostBinding,
  input,
} from '@angular/core';

@Component({
  selector: 'button[cogFabButton]',
  imports: [CommonModule],
  templateUrl: './fab-button.component.html',
  styleUrl: './fab-button.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    '[attr.type]': '"button"',
  },
})
export class FabButton {
  readonly disabled = input(false, { transform: booleanAttribute });

  @HostBinding('attr.disabled')
  get isDisabled(): boolean | null {
    return this.disabled() || null;
  }
}
