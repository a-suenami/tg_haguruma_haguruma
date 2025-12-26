import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  HostListener,
  output,
  signal,
} from '@angular/core';

import { MobileHeaderMenuIcon } from '../../icons/icon-mobile-header-menu/mobile-header-menu.icon';

@Component({
  selector: 'button[cog-header-menu-button]',
  imports: [CommonModule, MobileHeaderMenuIcon],
  templateUrl: './header-menu-button.component.html',
  styleUrl: './header-menu-button.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    '[attr.aria-label]': '"Toggle navigation menu"',
    '[attr.aria-expanded]': 'currentState() === "present" ? "true" : "false"',
  },
})
export class HeaderMenuButton {
  @HostListener('click')
  handleClick() {
    this.handleToggle();
  }

  readonly present = output<void>();
  readonly dismiss = output<void>();
  readonly currentState = signal<'present' | 'dismissed'>('dismissed');

  handleToggle() {
    this.currentState.set(
      this.currentState() === 'present' ? 'dismissed' : 'present',
    );
    if (this.currentState() === 'present') {
      this.present.emit();
    } else {
      this.dismiss.emit();
    }
  }
}
