import { CommonModule } from '@angular/common';
import {
  booleanAttribute,
  ChangeDetectionStrategy,
  Component,
  HostBinding,
  input,
} from '@angular/core';

@Component({
  selector: 'button[cog-button], a[cog-button]',
  imports: [CommonModule],
  templateUrl: './button.component.html',
  styleUrl: './button.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    '[attr.type]': 'type()',
    '[attr.primary]': 'primary() ? "" : null',
    '[attr.secondary]': 'secondary() ? "" : null',
    '[attr.filled]': 'filled() ? "" : null',
    '[attr.outlined]': 'outlined() ? "" : null',
    '[attr.disabled]': 'disabled() ? "" : null',
  },
})
export class Button {
  readonly type = input<'button' | 'submit' | 'reset'>('button');
  readonly primary = input(false, { transform: booleanAttribute });
  readonly secondary = input(false, { transform: booleanAttribute });
  readonly filled = input(false, { transform: booleanAttribute });
  readonly outlined = input(false, { transform: booleanAttribute });
  readonly disabled = input(false, { transform: booleanAttribute });

  @HostBinding('class.cog-button') readonly hostClass = true;
}
