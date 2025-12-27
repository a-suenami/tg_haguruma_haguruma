import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'cog-header-logo-button',
  imports: [CommonModule],
  templateUrl: './header-logo-button.component.html',
  styleUrl: './header-logo-button.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    '[attr.aria-label]': 'ariaLabel()',
  },
})
export class HeaderLogoButton {
  readonly href = input<string>('/');
  readonly ariaLabel = input<string>('Home');
}
