import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  HostListener,
  signal,
} from '@angular/core';

@Component({
  selector: 'cog-header-menu-overlay',
  imports: [CommonModule],
  templateUrl: './header-menu-overlay.component.html',
  styleUrl: './header-menu-overlay.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    '[class.show]': 'show()',
  },
})
export class HeaderMenuOverlayComponent {
  @HostListener('window:resize')
  handleResize() {
    if (window.innerWidth > 768) {
      this.dismiss();
    }
  }

  readonly show = signal(false);

  present() {
    this.show.set(true);
  }

  dismiss() {
    this.show.set(false);
  }
}
